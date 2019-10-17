# ssiscicd - aks
Basics to setup a mssql ssis enabled container in AKS

## Setup your deployment
`kubectl apply -f mssqlssis.deployment.yaml`

## Setup your service
`kubectl apply -f mssqlssis.service.yaml`
Alternatively, you can setup a service with a selector and skip the endpoint, if you are using one and only one pod with the following command: `kubectl expose deployment mssqlssis-deployment --type=LoadBalancer --name=mssqlssis-service --port=21433 --target-port=1433`

## Setup your endpoint
1. Inspect your pods to determine their IP addresses. `kubectl get pods -o wide`
1. Update the mssql.endpoints.yaml file with the IP address(es)
1. Run `kubectl apply -f mssqlssis.endpoints.yaml`

## Thoughts on how to use AKS for CICD pipelines
Documentation here for namespaces
https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace

1. kubectl create namespace pipeline-<RUN_#>
1. kubectl config set-context p_<RUN_#> --namespace=pipeline-<RUN_#> --cluster=ssiscicdAKS --user=clusterUser_SED-RG_ssiscicdAKS
1. kubectl config use-context p_<RUN_#>
1. Setup the secret so that the container can be created from https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ `kubectl create secret docker-registry regcred --docker-server=<CONTAINER_REGISTRY> --docker-username=<USERNAME> --docker-password=<PASSWORD> --docker-email=<EMAIL>`
1. Create the deployment from the yaml deployment file `kubectl apply -f mssqlssis.deployment.yaml`
1. One line to create the service for a deployment within a namespace `kubectl expose deployment mssqlssis-deployment --type=LoadBalancer --name=mssqlssis-service --port=21433 --target-port=1433`
1. Run the rest of the pipeline
1. Delete the namespace and everything under it `kubectl delete namespaces p_<RUN_#>`
