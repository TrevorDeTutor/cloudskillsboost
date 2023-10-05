#0. Configure the cloud shell
gcloud config set project [PROJECT_ID]

gcloud config set compute/region "us-east1"
export REGION=$(gcloud config get compute/region)
gcloud config set compute/zone "us-east1-b"
export ZONE=$(gcloud config get compute/zone)

#1. Create a development VPC with three subnets manually
gcloud compute networks create griffin-dev-vpc --subnet-mode=custom
gcloud compute networks subnets create griffin-dev-wp --network=griffin-dev-vpc --region=$REGION --range=192.168.16.0/20
gcloud compute networks subnets create griffin-dev-mgmt --network=griffin-dev-vpc --region=$REGION --range=192.168.32.0/20

# add firewall rules
gcloud compute firewall-rules create griffin-dev-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=griffin-dev-vpc --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

#2. Create a production VPC with three subnets manually
gcloud compute networks create griffin-prod-vpc --subnet-mode=custom
gcloud compute networks subnets create griffin-prod-wp --network=griffin-prod-vpc --region=$REGION --range=192.168.48.0/20
gcloud compute networks subnets create griffin-prod-mgmt --network=griffin-prod-vpc --region=$REGION --range=192.168.64.0/20

# add firewall rules
gcloud compute firewall-rules create griffin-prod-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=griffin-prod-vpc --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0


#3. Create a bastion that is connected to both VPCs
gcloud compute instances create griffin-bastion-host \
    --network-interface network=griffin-dev-vpc,subnet=griffin-dev-mgmt \
    --network-interface network=griffin-prod-vpc,subnet=griffin-prod-mgmt \
    --machine-type=e2-medium \
    --zone=$ZONE 


#4. Create a development Cloud SQL Instance and connect and prepare the WordPress environment
gcloud sql instances create griffin-dev-db \
    --database-version=MYSQL_8_0
    --cpu=1 \
    --memory=4GB \
    --region=$REGION

# create wordpress DB
gcloud sql databases create wordpress --instance=griffin-dev-db

# create db user + password
gcloud sql users create wp_user --password=stormwind_rules --instance=griffin-dev-db

# OR: ON CONSOLE
# connect to the instance & create a database in Cloud Shell
gcloud auth login --no-launch-browser

gcloud sql connect graffin-dev-db --user=root --quiet

CREATE DATABASE wordpress;
CREATE USER "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%";
FLUSH PRIVILEGES;

#5. Create a Kubernetes cluster in the development VPC for WordPress
gcloud container clusters create griffin-dev \
    --machine-type=e2-standard-4 \
    --num-nodes=2 \
    --zone=$ZONE \
    --network=griffin-dev-vpc \
    --subnetwork=griffin-dev-wp


#6. Prepare the Kubernetes cluster for the WordPress environment
gsutil cp -r gs://cloud-training/gsp321/wp-k8s .

gcloud container clusters get-credentials griffin-dev --zone=$ZONE

#create k8s volume & db creds as secrets
kubectl apply -f wp-env.yaml

# DB service account
gcloud iam service-accounts keys create key.json \
    --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
kubectl create secret generic cloudsql-instance-credentials \
    --from-file key.json

#7. Create a WordPress deployment using the supplied configuration
#  edit YOUR_SQL_INSTANCE with SQL DB name
kubectl apply -f wp-deployment.yaml

kubectl apply -f wp-service.yaml


#8. Enable monitoring of the cluster via stackdriver
# In Google Cloud console, select Monitoring, and then select  Uptime checks
# Click Create Uptime Check.
# Follow steps in the console


#9. Provide access for an additional engineer
gcloud projects add-iam-policy-binding qwiklabs-gcp-03-2753a41a3a5b \
    --member=student-03-1c26ea0dbc88@qwiklabs.net --role=editor