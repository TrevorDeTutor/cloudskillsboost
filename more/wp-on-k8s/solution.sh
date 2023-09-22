# enable APIs
gcloud services enable container.googleapis.com sqladmin.googleapis.com

# setting up your environment
gcloud config set compute/region us-central1
export PROJECT_ID=<project-id>

# App manifests
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples

#1. Create a GKE cluster.
CLUSTER_NAME=persistent-disk-tutorial
gcloud container clusters create-auto $CLUSTER_NAME

#2. Create a PV and a PVC backed by Persistent Disk.

#3. Create a Cloud SQL for MySQL instance.

#4. Deploy WordPress.

#5. Set up your WordPress blog.