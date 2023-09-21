#1. Create a Kubernetes Cluster
gcloud config set compute/zone "us-east4-a"

gcloud container clusters create echo-cluster \
    --machine-type e2-standard-2 \
    --num-nodes 2

gcloud container clusters get-credentials echo-cluster

#2. Build a tagged Docker Image
# copy app achieve file from storage bucket & unzip
gsutil cp -r gs://[PROJECT_ID] .
tar -xf echo-app.tar.gz

docker build -t echo-app:v1 .

# test the created Docker image locally
docker run -p 8000:8000 --name echo-app-container -d echo-app:v1
curl http://localhost:8000

#3. Push the image to the Google Container Registry
docker tag echo-app:v1 gcr.io/[project-id]/echo-app

gcloud docker -- push echo-app:v1 gcr.io/[project-id]/echo-app

#4. Deploy the application to the Kubernetes Cluster
kubectl create -f manifests/echoweb-deployment.yaml
kubectl create -f manifests/echoweb-service.yaml

# test
kubectl get pods
kubectl get services

