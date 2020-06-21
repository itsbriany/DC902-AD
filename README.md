# DC 902 Active Directory Environment

## Prerequisites

### Context

The puropose of this project is to provide a cost-effective solution to help people learn about security in active directory. This solution uses the `Microsoft Azure` cloud provider and therefore requires you to install a few tools to automate the infrastructure provisioning processes.

### Tools of the trade

You will need to install all the tools below if you wish to provision your own Active Directory environment.

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) -> You will need this to authenticate this tool with your azure account.
* [Packer](https://learn.hashicorp.com/packer) -> Required to configure the virtual machine images.
* [Terraform](https://www.terraform.io/downloads.html) -> Required for provisioning the cloud infrastructure.

Once you have finished installing the tools above, be sure to add them to your `PATH` environment variable.

### Configuring Azure

1. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) before you begin.
2. Download and install the [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
3. Create a Service Principal to act as the provisioning identity. `az ad sp create-for-rbac --name ServicePrincipalName`.
4. Keep the results for the `ServicePrincipalName` in a safe place. You will need that information for configuring `packer` and `terraform` for the next steps.
5. You should be able to verify that you have added the service principal name with `az account list`.

### Arming your Shell Environment

Copy `environment.ps1.example`/`environment.sh.example` as `environment.ps1`/`environment.sh`.

In `environment.ps1`/`environment.sh`, you will want to configure all variables that end in `CHANGE_ME` to match your settings. Once you have done that, you will want to load those variables into your existing powershell/shell session by executing the `environment.ps1` script if you are using PowerShell or `source environment.sh` if you are using Bash. This is required so that `terraform` and `packer` can provision an environment that is best suited to your needs.

### Provisioning the Packer Resource Group

1. Go to the `PROJECT_ROOT/packer` directory
2. Run `terraform apply`, confirm there are no errors. You will notice all the changes that will occur in the environment. If you are comfortable with that, enter `yes`.
3. If all went well, you should see no errors.

### Building the DC01 Virtual Machine Image

1. Go to the `PROJECT_ROOT/packer` directory
2. Run `packer build main.json`. This should build the image which we will provision in the next step.
3. You should be able to confirm that the image was built with:
   1. `az image show --resource-group $env:TF_VAR_AZURE_PACKER_RESOURCE_GROUP --name $env:TF_VAR_DC01_MANAGED_IMAGE_NAME` on PowerShell
   2. `az image show --resource-group $TF_VAR_AZURE_PACKER_RESOURCE_GROUP --name $TF_VAR_DC01_MANAGED_IMAGE_NAME` on Bash

### Provisioning the DC902 Environment

1. Go to the `PROJECT_ROOT/dc902` directory
2. Run `terraform apply`, confirm there are no errors. You will notice all the changes that will occur in the environment. If you are comfortable with that, enter `yes`.
3. If all went well, you should see no errors.

### Accessing the DC902 Environment

1. You should be able to access your `DC01` domain controller via RDP using the `TF_VAR_DC01_ADMIN_USERNAME:TF_VAR_DC01_ADMIN_PASSWORD` environment variables as credentials.

### Destroying the DC902 Environment

**SUPER IMPORTANT!!**

Be sure to destroy your environment so that your wallet doesn't bleed for too long.

`terraform destroy`

If any issues occur, you should be able to clean up the resources manually via the [azure portal](https://portal.azure.com/).

### Troubleshooting

* I cannot establish an RDP connection. What's the catch?
  * Check the `TF_VAR_WHITELISTED_CIDR` environment variable in `environment.ps1`/`environment.sh` to ensure that the CIDR range holds your **public** IP address. E.g `100.100.100.100/32` is a valid CIDR range that only accepts the `100.100.100.100` IP address.
  * Your virtual machine image may still be booting. Give it a couple more minutes and try reconnecting.
* My environment won't tear down. I get some error involving azure network interfaces... heeelp!!!
  * Unfortunately, the DC01 virtual machine depends on a network interface card. Azure then refuses to delete the network interface BEFORE the DC01 virtual machine, resulting in the error. TL;DR go delete the DC01 virtual machine with 

## Appendix

### Terraform Basics

`terraform init` -> Downloads the Azure modules required to create an Azure resource group.

`terraform plan` -> Command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files.

`terraform apply` -> Apply the execution plan.

`terraform destroy` -> Tear down the infrastructure. **MAKE SURE YOU DON'T MAKE ANY MANUAL CHANGES TO THE ENVIRONMENT!!**

### Q/As

* What is the difference between Azure Active Directory and Windows Server Active Directory?
  * Azure AD -> Uses SAML 2.0, OAuth 2.0, OpenID Connect, and WS-Federation to provide authentication.
  * On Premise AD -> Uses kerberos and NTML authentication.

### References

* Preparing your Azure account (you don't necessarily have to use the cloud shell):
  * https://docs.microsoft.com/en-us/azure/developer/terraform/getting-started-cloud-shell


### Contributions

* This whole project is meant to provide infrastructure-as-code to the community, so if you figured out how to make the environment more interesting, please feel welcome to send a pull request!
