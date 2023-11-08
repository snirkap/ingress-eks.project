# AWS EKS Cluster with Application Deployment And Ingress:
This project automates the deployment of a Kubernetes cluster on AWS using the eksctl tool and a YAML configuration file. It also details the process of deploying two separate applications within this cluster, managing traffic with an Nginx Ingress Controller, and setting up DNS records in AWS Route 53 to route traffic to the applications.
## requirements:
1. aws account
2. installed in your local machine:
   * awscli
   * eksctl
   * kubectl 
### setup:
1. git clone "https://github.com/snirkap/ingress-eks.project.git"
2. eksctl create cluster -f cluster.yml
3. **in ingress.yml file:**
   change in the spec.roles.host the name of the domain and keep the sub domain:
   * web1.yourDomainName
   * web2.yourDomainName
5. kubectl apply -f ingress-nginx.yml deploy-v1.yml deploy-v2.yml ingress.yml
6. in route 53:
   craete 2 records:
   both of the will be a type "A" and piont into the NLB that the nginx controller made with alias.
   * the first sub domain will be: web1.
   * and the second domain will be: web2.
7. and now you can enter into your dns with the sub domains that we made and Each will point you to different service. 
   
