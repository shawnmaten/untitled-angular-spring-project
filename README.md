# untitled-angular-spring-project

## Infrastructure Config

The project uses a Google Kubernetes Engine cluster setup through Terraform.
The file "./infra.tf" contains the Terraform config. The GCP project ID and
service account key path (not values) are currently hardcoded. The `terraform`
and `kubectl`  binaries need to be installed. Basic Terraform commands:

```sh
terraform init
terraform apply
terraform destroy
```
