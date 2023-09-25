#1. Build
gcloud container clusters get-credentials echo-cluster

gsutil cp -r gs://qwiklabs-gcp-04-df219e91ac3c .
tar -xf echo-web-v2.tar.gz 

docker build -t echo-app:v2 .
docker tag echo-app:v2 gcr.io/qwiklabs-gcp-04-df219e91ac3c/echo-app:v2

#2. Push the image to the Container Registry
gcloud docker -- push gcr.io/qwiklabs-gcp-04-df219e91ac3c/echo-app:v2

#3. Deploy the updated application with a new tag
#- Edit deployment YAML from cloud shell, replace the link to the deployed v2 image

#4. Scale the deployment
kubectl scale --replicas=5 deployment/demo-deployment

#Same as lab 3