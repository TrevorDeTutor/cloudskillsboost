#1. Create a Docker image and store the Dockerfile.
# valkyrie-app
gcloud source repos clone valkyrie-app

docker build -t valkyrie-prod:v0.0.3 .


#2. Test the created Docker image.
docker run -p 8080:8080 --name valkyrie-prod-app -d valkyrie-prod:v0.0.3

curl http://localhost:8080


#3. Push the Docker image into the Artifact Registry.
gcloud auth configure-docker us-central1-docker.pkg.dev

# tag the image [ LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE . ]
docker build -t us-central1-docker.pkg.dev/qwiklabs-gcp-03-2c28f3ec5b84/valkyrie-repo/valkyrie-prod:v0.0.3 .

docker push us-central1-docker.pkg.dev/qwiklabs-gcp-03-2c28f3ec5b84/valkyrie-repo/valkyrie-prod:v0.0.3


#4. Use the image to create and expose a deployment in Kubernetes
gcloud config set compute/zone "us-east1-d"
gcloud container clusters get-credentials valkyrie-dev

kubectl create -f deployment.yaml
kubectl create -f service.yaml

# confirm deployments:
kubectl get pods
kubectl get services



