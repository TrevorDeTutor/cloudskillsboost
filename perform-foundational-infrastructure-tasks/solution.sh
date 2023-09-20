#0. Configure the cloud shell
gcloud config set project [PROJECT_ID]

gcloud config set compute/zone "us-central1-b"
export ZONE=$(gcloud config get compute/zone)
gcloud config set compute/region "us-central1"
export REGION=$(gcloud config get compute/region)

#Task 1. Create a bucket for storing the photographs
gsutil mb gs://qwiklabs-gcp-01-bbb622eb4ab0-bucket

#Task 2. Create a Pub/Sub topic
gcloud pubsub topics create topic-memories-880

#Task 3. Create the thumbnail Cloud Function
# Use the Console
# or:
gcloud functions deploy memories-thumbnail-generator \
    --entry-point memories-thumbnail-generator \
    --gen2 \
    --stage-bucket qwiklabs-gcp-01-bbb622eb4ab0-bucket \
    --trigger-topic topic-memories-880 \
    --runtime nodejs20

# test the function
gcloud functions describe memories-thumbnail-generator

#Task 4. Test the Infrastructure
curl https://storage.googleapis.com/cloud-training/gsp315/map.jpg --output map.jpg
gsutil cp map.jpg gs://qwiklabs-gcp-01-bbb622eb4ab0-bucket

#Task 5. Remove the previous cloud engineer
# Delete user from IAM console