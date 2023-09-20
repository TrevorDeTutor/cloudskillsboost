#1: Create an instance template.
gcloud compute instance-templates create nginx-template \
    --network=default \
    --subnet=default \
    --tags=allow-health-check \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script=startup.sh

#2: Create a target pool
gcloud compute target-pools create nginx-pool

#3: Create Managed Instance group
gcloud compute instance-groups managed create nginx-group \
    --template=nginx-template \
    --size=2 \
    --target-pool=nginx-pool

#4: Create a firewall rume named grant-tcp--rule-413 to allow traffic on port 80
gcloud compute firewall-rules create permit-tcp-rule-733 --allow tcp:80

gcloud compute firewall-rules create grant-tcp-rule-413 \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80

#5: Create a health check (First create a global static IP)
gcloud compute forwarding-rules create nginx-lb \
    --ports=80 \
    --target-pool=nginx-pool

gcloud compute http-health-checks create http-basic-check

gcloud compute target-pools add-health-checks nginx-pool \
    --http-health-check=htt-basic-check \
    --region=europe-west1

#6: Create a backend service, attach the managed instance group
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global

gcloud compute backend-services add-backend web-backend-service \
    --instance-group=lb-backend-group \
    --global

#6: Create a URL map, and target the HTTP proxy to route request to the URL map
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

#7:Create a forwarding rule
gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80