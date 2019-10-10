# ssiscicd
Demo code for SQL Server Integration Services Continuous Integration Continuous Delivery on Microsoft Azure Cloud

ANNOYANCE @MICROSOFT: To use Visual Studio 2019 and Docker together, you must have Docker Desktop setup on your VM. However Docker Desktop is not available for Windows Server 2019, only Windows 10. You must use Windows Server 2019 as the base OS for windows containers running on AKS. So despite including container support in VS2019, that support is meaningless when trying to build windows containers for AKS.

ANNOYANCE @MICROSOFT: In order to deploy dacpacs which reference the master db, the master.dacpac (and probably msdb.dacpac) are required to be included in the project. Why is this? It seems like sqlpackage should be smart enough to allow users to circumvent the errors, and assume that a master db exists, as an option.

## Setup Agent for compiling projects only
1. Create a Dev Test Lab environment and new Dev Test Lab VM "Visual Studio 2019 Community (latest release) on Windows 10 Enterprise N (x64)"
1. Sign in
1. Update to latest version of Visual Studio 2019 (Why isn't this the latest version already, Microsoft?)
1. Open up Visual Studio 2019 Community Edition "Extensions" Menu > Manage Extensions
1. Search for and start install of SQL Server Integration Services Projects. It will require you to close VS2019. Wait like 10 minutes.

## Setup VM for compiling container image
- Make sure to clone the master.dacpac and msdb.dacpac to the server, otherwise tsqlt will not deploy.

## Setup Developer Database/AKS
- https://docs.microsoft.com/en-us/azure/aks/windows-container-cli
- https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-2017

## Creates AKS -- note that we removed monitoring
- az aks create \
    -g SED-RG \
    --name ssiscicdAKS \
    --node-count 1 \
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


	
