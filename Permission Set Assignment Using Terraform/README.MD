## Permission Set Assignment using Terraform

The repository contains Terraform code to assign permission sets to AWS accounts.

The code is from my blog post about how Terraform can be used to automate the assignment of permission sets to AWS accounts using the ```aws_ssoadmin_account_assignment``` Terraform resource.

**NOTE** The account numbers are placeholders and should be replaced with your own if you are going to deploy this within your own environment.

### locals.tf

Contains local variables to create permission sets and to create a map of permission set assignments using the flatten function in combination with a nested for loop.

### main.tf

Contains the resources to create the permission sets, groups, and assign permission sets to accounts.

### outputs.tf

Output to show the value of the map created using in the locals.tf file.

### variables.tf 

Variables required for the creation of the groups and the map variable indicating the permission set assignments.

