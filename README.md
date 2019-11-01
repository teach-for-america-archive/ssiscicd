# ssiscicd
Demo code for SQL Server Integration Services Continuous Integration Continuous Delivery on Microsoft Azure Cloud

ANNOYANCE @MICROSOFT: To compile dockerFiles on Visual Studio 2019, you must have Docker Desktop setup on your VM. However Docker Desktop is not available for Windows Server 2019, only Windows 10. You must use Windows Server 2019 as the base OS for windows containers running on AKS. So despite including container support in VS2019, that support is meaningless when trying to build windows containers for AKS.

ANNOYANCE @MICROSOFT: In order to deploy dacpacs which reference the master db, the master.dacpac (and probably msdb.dacpac) are required to be included in the project. Why is this? It seems like sqlpackage should be smart enough to allow users to circumvent the errors, and assume that a master db exists, as an option.

ANNOYANCE @MICROSOFT: Why does the Powershell@1 task wait for the script to finish and Powershell@2 does not? Very confusing, please explain. "This is a breaking change."

ANNOYANCE @MICROSOFT: Why is not possible to extract the commandOutput easily into a variable when using Kubernetes@1? Not being able to do this means that get and describe are basically worthless when used in this task. You must write a script task instead.

## Setup Agent for DevOps Pipeline
1. Create a Dev Test Lab environment
1. Create a new VM within the environment on the Windows Server 2019 Data Center image
1. RDP into the machine
1. Install and configure the tools needed for your build pipeline
    1. Install the SQL Server Data Tools for Visual Studio 2017 using the Standalone installer, https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-ver15#ssdt-for-vs-2017-standalone-installer 
        1. Find devenv.exe. On my build box, it is here: "C:\Program Files (x86)\Microsoft Visual Studio\2017\SQL\Common7\IDE\devenv.com"
    1. Install kubectl by following these instructions https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows
        1. I add kubectl to C:\agentTools\kubernetes
        1. Add this to your path
    1. Install OpenJDK because Java is required by Maven (https://jdk.java.net/13/)
        1. I unpack to C:\agentTools\java
        1. Add C:\agentTools\java\jdk-13.0.1\bin to your path
    1. Install maven by downloading and following these instructions
        1. https://maven.apache.org/download.cgi
        1. https://maven.apache.org/install.html
    1. Install the Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest
    1. Install sqlpackage.exe to deploy dacpacas https://docs.microsoft.com/en-us/sql/tools/sqlpackage-download?view=sql-server-ver15
    1. Install sqlcmd.exe to run unit tests from self-hosted agent https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15
1. Setup the agent on the VM, so that Azure DevOps Pipelines can run builds on this machine (https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops)




## Setup VM for compiling container image
- Make sure to clone the master.dacpac and msdb.dacpac to the server, otherwise tsqlt will not deploy.

## Setup Developer Database/AKS
- https://docs.microsoft.com/en-us/azure/aks/windows-container-cli
- https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-2017

### Creates AKS -- note that we removed monitoring
```PASSWORD_WIN="<Y0u4Passwo3dGo3sH!r!>"

az aks create \ 
    -g <yourResourceGroup> \ 
    --name ssiscicdAKS \
    --node-count 1 \
    --kubernetes-version 1.14.6 \
    --generate-ssh-keys \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username azureuser \
    --vm-set-type VirtualMachineScaleSets \
    --network-plugin azure
```

### Add a windows node pool
```az aks nodepool add \
    --resource-group <yourResourceGroup> \
    --cluster-name ssiscicdAKS \
    --os-type Windows \
    --name npwin \
    --node-count 1 \
    --kubernetes-version 1.14.6
```
    
### Configure kubectl to hit our AKS
`az aks get-credentials --resource-group <yourResourceGroup> --name ssiscicdAKS`	
