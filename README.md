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

### GitHub Packages Private Repo Setup

To pull images from the GitHub Packages registry, the cluster must be 
authenticated, since GitHub doesn’t support public pulls. The Terraform script
is setup to add the necessary secret from a file. To generate the secret (which 
is a docker config file), run the below script. The script does a dry run of
the relevant kubectl command, parses the output, and saves the config to a file.

For more info refer to this kubernetes doc:
https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

```sh
kubectl create secret docker-registry regcred --dry-run=true -o yaml \
  --docker-server=docker.pkg.github.com \
  --docker-username=$GITHUB_USERNAME \
  --docker-password=$GITHUB_TOKEN | \
  perl -ne '/dockerconfigjson: (.+)/ && print $1' | \
  base64 -d \
  > docker.config.json
```

