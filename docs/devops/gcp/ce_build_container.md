# Create Compute Engine instance and build docker container

## Console
Project: (use project for lazarus)
LOCATION: "us-west3"
ZONE: "us-west3-c"
REPO: "lazarus-docker-repo"

### Setup environment
Set region/zone
https://cloud.google.com/compute/docs/gcloud-compute#default-region-zone
https://cloud.google.com/compute/docs/regions-zones
us-west1 The Dalles, OR
us-west2 LA, CA
us-west3 SLC, UT
us-west4 LV, NV

### Upload container to Artifact Repository
https://cloud.google.com/artifact-registry/docs/docker/store-docker-container-images

### Create Compute Engine instance
Navigate to Cloud Engine: VM instances
Create instance
name: lazarus
Machine type: e2-micro
Container section: click Deploy Container. 
Container image:
$LOCATION-docker.pkg.dev/$PROJECT/$REPO/lazarus:1.7

In search bar, search for "firewall rules"
Click "Firewall: VPC network"
Click "Create Firewall Rule"
name it: "allow-flask"
target tags "allow-flask"
source IPv4 ranges: 0.0.0.0/0
check TCP and include port 3000
click Create

Navigate to Cloud Engine: VM Instances
Collect the "Internal IP" for the lazarus container
Click on "SSH" for lazarus container

```sh
docker ps # see container running
docker stop (container number)

docker run \
--name lazarus_1_7 \
-e FLASK_ENV=production \
-d \
$LOCATION-docker.pkg.dev/$PROJECT/$REPO/lazarus:1.7
```

## CLI

### Setup environment
```shell
export PROJECT_ID=$(gcloud config get-value project)
export LOCATION="us-west3"
export ZONE="us-west3-c"
export REPO="lazarus-docker-repo"

gcloud compute project-info add-metadata \
--metadata google-compute-default-region=$LOCATION,google-compute-default-zone=$ZONE

gcloud init   

# Confirm region and zone
gcloud config get-value compute/region
gcloud config get-value compute/zone
```

### Upload container to Artifact Repository
```shell
gcloud services list

# if artifactregistry not activated, then run:
gcloud services enable \
artifactregistry.googleapis.com \
--project=${PROJECT_ID}

gcloud artifacts repositories create $REPO \
--repository-format=docker \
--location=${LOCATION} --description="Lazarus Docker repository"

gcloud artifacts repositories list
gcloud auth configure-docker ${LOCATION}-docker.pkg.dev
docker tag registry.hub.docker.com/ej838639/lazarus:1.7 \
${LOCATION}-docker.pkg.dev/${PROJECT_ID}/$REPO/lazarus:1.7

docker push ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/$REPO/lazarus:1.7

docker pull ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/$REPO/lazarus:1.7
```

### Create Compute Engine instance
```shell
export INSTANCE_NAME="lazarus"

gcloud services list

# if compute not activated, then run:
gcloud services enable compute.googleapis.com 

gcloud compute instances create-with-container $INSTANCE_NAME \
--machine-type e2-micro \
--container-image $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPO/lazarus:1.7 \
--container-env FLASK_ENV=production \
--tags allow-flask,http-server

# note external IP for lazarus instance, or use the following command
gcloud compute instances list

gcloud compute firewall-rules create allow-flask \
--source-ranges 0.0.0.0/0 \
--allow tcp:3000 \
--target-tags allow-flask
```
