#0. Configure the cloud shell
gcloud config set project [PROJECT_ID]

gcloud config set compute/region "us-east1"
export REGION=$(gcloud config get compute/region)
gcloud config set compute/zone "us-east1-b"
export ZONE=$(gcloud config get compute/zone)

#1. Create a development VPC with three subnets manually
gcloud compute networks create griffin-dev-vpc --subnet-mode=custom
gcloud compute networks subnets griffin-dev-wp --network=graffin-dev-vpc --region=REGION --range=192.168.16.0/20
gcloud compute networks subnets griffin-dev-mgt --network=graffin-dev-vpc --region=REGION --range=192.168.32.0/20

# add firewall rules
gcloud compute firewall-rules create graffin-dev-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=graffin-dev-vpc --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

#2. Create a production VPC with three subnets manually
gcloud compute networks create griffin-prod-vpc --subnet-mode=custom
gcloud compute networks subnets griffin-prod-wp --network=graffin-prod-vpc --region=REGION --range=192.168.48.0/20
gcloud compute networks subnets griffin-prod-mgt --network=graffin-prod-vpc --region=REGION --range=192.168.64.0/20

# add firewall rules
gcloud compute firewall-rules create graffin-prod-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=graffin-prod-vpc --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0


#3. Create a bastion that is connected to both VPCs
gcloud compute instances create graffin-bastion-host \
    --zone=ZONE \
    --machine-type=e2-medium \
    --network-interface network=graffin-dev-vpc \
    --network-interface network=graffin-prod-vpc \

#4. Create a development Cloud SQL Instance and connect and prepare the WordPress environment
gcloud sql instances create graffin-dev-db \
    --database-version=MYSQL_8_0
    --cpu=1 \
    --memory=4GB \
    --region=REGION \
    --root-password=admintrevor

gcloud sql databases create wordpress --instance=graffin-dev-db

gcloud sql users create stormwind_rules --instance=graffin-dev-db

# OR: ON CONSOLE
# connect to the instance & create a database in Cloud Shell
gcloud auth login --no-launch-browser

gcloud sql connect graffin-dev-db --user=root --quiet

CREATE DATABASE wordpress;
CREATE USER "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%";
FLUSH PRIVILEGES;

#5. Create a Kubernetes cluster in the development VPC for WordPress
gcloud container clusters create graffin-dev \
    --machine-type=e2-standard-4 \
    --num-nodes=2 \
    --zone=ZONE \
    --subnet=graffin-dev-wp \
    --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

#6. Prepare the Kubernetes cluster for the WordPress environment
gs://cloud-training/gsp321/wp-k8s

#7. Create a WordPress deployment using the supplied configuration

#8. Enable monitoring of the cluster via stackdriver

#9. Provide access for an additional engineer