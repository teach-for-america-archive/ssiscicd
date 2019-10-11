# ssiscicd - aks
Basics to setup a mssql ssis enabled container in AKS

## Setup your deployment
`kubectl apply -f mssqlssis.deployment.yaml`

## Setup your service
`kubectl apply -f mssqlssis.service.yaml`

## Setup your endpoint
1. Inspect your pods to determine their IP addresses. `kubectl get pods -o wide`
1. Update the mssql.endpoints.yaml file with the IP address(es)
1. Run `kubectl apply -f mssqlssis.endpoints.yaml`
