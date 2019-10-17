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
