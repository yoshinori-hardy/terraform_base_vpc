# No Frills Terraform
This is a basic AWS terraform templates for launching a 2 tier VPC.  
This was built as a learning excercise when first experimenting with TF.

# Pre-Requisites
Ensure that you've installed the TF binary

https://www.terraform.io/docs/configuration/

I have a secrets.tf which is omitted by git ignore

{
   variable "access_key" {
     default     = "REDACTED"
     description = "access key"
   }
   variable "secret_key" {
     default     = "REDACTED"
     description = "access secret"
   }
}

# Resources
source examples used can be found here:

https://github.com/hashicorp/terraform/tree/master/examples

# Purpose
This repo aims to provide you with the tools to get an environment up and
running quickly.

# General usage

- **Review the variable**: The idea is that all the environment configuration is
done here.  Sert the environment name, ip schema's, aws-regions and AZs

- **Enable/Disable Features**: append anythign that is not required with a
.disabled and TF will ignore this file.
