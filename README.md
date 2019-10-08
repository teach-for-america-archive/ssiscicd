# ssiscicd
Demo code for SQL Server Integration Services Continuous Integration Continuous Delivery on Microsoft Azure Cloud


Setup Agent
- Create a Dev Test Lab environment and new Dev Test Lab VM "Visual Studio 2019 Community (latest release) on Windows 10 Enterprise N (x64)"
- Sign in
- Update to latest version of Visual Studio 2019 (Why isn't this the latest version already, Microsoft?)
- Open up Visual Studio 2019 Community Edition "Extensions" Menu > Manage Extensions
- Search for and start install of SQL Server Integration Services Projects. It will require you to close VS2019. Wait like 10 minutes.
- Install docker on the VM (https://docs.docker.com/install/windows/docker-ee/)

Setup Developer Database/AKS
- https://docs.microsoft.com/en-us/azure/aks/windows-container-cli
- https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-2017

Creates AKS -- note that we removed monitoring
- az aks create \
    -g SED-RG \
    --name ssiscicdAKS \
    --node-count 2 \
    --kubernetes-version 1.14.6 \
    --generate-ssh-keys \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username azureuser \
    --vm-set-type VirtualMachineScaleSets \
    --network-plugin azure

Add a windows node pool
-	az aks nodepool add \
    --resource-group SED-RG \
    --cluster-name ssiscicdAKS \
    --os-type Windows \
    --name npwin \
    --node-count 1 \
    --kubernetes-version 1.14.6 
    
Configure kubectl to hit our AKS
- az aks get-credentials --resource-group SED-RG --name ssiscicdAKS


	
