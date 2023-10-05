# enable APIs
gcloud services enable container.googleapis.com sqladmin.googleapis.com

# setting up your environment
gcloud config set compute/region us-central1
export PROJECT_ID=<project-id>
WORKING_DIR=$(pwd)
CLUSTER_NAME=persistent-disk-tutorial
INSTANCE_NAME=mysql-wordpress-instance

# App manifests
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples

#1. Create a GKE cluster.
gcloud container clusters create-auto $CLUSTER_NAME

gcloud container clusters get-credentials $CLUSTER_NAME --region REGION

#2. Creating a PV and a PVC backed by Persistent Disk:
# create a PVC as the storage required for WordPress. 
kubectl apply -f wordpress-volumeclaim.yaml
kubectl get persistentvolumeclaim

#3. Creating a Cloud SQL for MySQL instance:
gcloud sql instances create $INSTANCE_NAME

export INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME \
    --format='value(connectionName)')

gcloud sql databases create wordpress --instance $INSTANCE_NAME

# create database user
CLOUD_SQL_PASSWORD=$(openssl rand -base64 18)
gcloud sql users create wordpress --host=% --instance $INSTANCE_NAME \
    --password $CLOUD_SQL_PASSWORD
echo $CLOUD_SQL_PASSWORD


#4. Deploy WordPress:
#4a. Configure a service account and create secrets
#You create a Kubernetes secret to hold the service account credentials and 
#another secret to hold the database credentials.
# service account
SA_NAME=cloudsql-proxy
gcloud iam service-accounts create $SA_NAME --display-name $SA_NAME

#svc acc variable
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter=displayName:$SA_NAME \
    --format='value(email)')

# add the cloudsql.client role to your service account:
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --role roles/cloudsql.client \
    --member serviceAccount:$SA_EMAIL

# create a key for the service account:
gcloud iam service-accounts keys create $WORKING_DIR/../../key.json \
    --iam-account $SA_EMAIL

# create a Kubernetes secret for the MySQL credentials
kubectl create secret generic cloudsql-db-credentials \
    --from-literal username=wordpress \
    --from-literal password=$CLOUD_SQL_PASSWORD

# kubernetes secret for the service account credentials
kubectl create secret generic cloudsql-instance-credentials \
    --from-file $WORKING_DIR/../../key.json


#4b. Deploy WordPress
# deploy the wordpress_cloudsql.yaml manifest file
kubectl create -f $WORKING_DIR/wordpress_cloudsql.yaml

kubectl get pod -l app=wordpress --watch
kubectl get pods

#5. Expose the WordPress service
kubectl create -f $WORKING_DIR/wordpress-service.yaml

kubectl get svc -l app=wordpress --watch
kubectl get services

#6. Setting up your WordPress blog
http://external-ip-address