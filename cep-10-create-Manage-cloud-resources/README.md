## Create and Manage Cloud Resources: Challenge Lab

### Set up an HTTP load balancer
You will serve the site via nginx web servers, but you want to ensure that the environment is fault-tolerant. 

Create an HTTP load balancer with a managed instance group of 2 nginx web servers.

#### STEPS:
1. Create an instance template.
2. Create a target pool.
3. Create a managed instance group.
4. Create a firewall rule named as Firewall rule to allow traffic (80/tcp).
5. Create a health check.
6. Create a backend service, and attach the managed instance group with named port (http:80).
7. Create a URL map, and target the HTTP proxy to route requests to your URL map.
8. Create a forwarding rule