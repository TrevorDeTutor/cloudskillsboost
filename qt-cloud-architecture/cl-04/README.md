## Scale Out and Update a Containerized Application on a Kubernetes Cluster


### Challenge scenario

You are taking over ownership of a test environment and have been given an updated version of a containerized test application to deploy. Your systems' architecture team has started adopting a containerized microservice architecture. 
- You are responsible for managing the containerized test web applications. 
- You will first deploy the initial version of a test application, called echo-app to a Kubernetes cluster called echo-cluster in a deployment called echo-web.


### The Challenge
1. You need to update the running echo-app application in the echo-web deployment from the v1 to the v2 code you have been provided. 
2. You must also scale out the application to 2 instances and confirm that they are all running.


### Tasks:
1. Build and deploy the updated application with a new tag

2. Push the image to the Container Registry