#Create a vm passing a startup script stored in Cloud storage
gcloud compute instances create apache2-server \
    --zone=us-east1-d \
    --image-project=debian-cloud \
    --image-family=debian-10 \
    --scopes=storage-ro \
    --metadata=startup-script-url=gs://qwiklabs-gcp-03-6b5ada050ff6-bucket/resources-install-web.sh

# add network tag
gcloud compute instances add-tags apache2-server \
    --zone=us-east1-d  \
    --tags=apache2-server

# add firewalls
gcloud compute firewall-rules create http-allow --allow tcp:80 --target-tags=apache2-server

# access vm
http://[EXTERNAL_IP]
