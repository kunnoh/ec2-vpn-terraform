# ec2 OpenVpn Access Server Terraform
**Create openvpn server using terraform.**


### Steps
1. Create AWS account.
2. Install aws-cli & login.
3. Install terraform.
4. Initialize terraform.
5. Configure terraform.
6. Verify configuration.
7. Provision vpn-server using terraform.
8. Destroy aws resources.


## Prerequsistes
- [AWS account](https://aws.amazon.com/free/?gclid=EAIaIQobChMIoYGWjbzChwMVO5RoCR3v7QTxEAAYASAAEgKWQPD_BwE&trk=2d3e6bee-b4a1-42e0-8600-6f2bb4fcb10c&sc_channel=ps&ef_id=EAIaIQobChMIoYGWjbzChwMVO5RoCR3v7QTxEAAYASAAEgKWQPD_BwE:G:s&s_kwcid=AL!4422!3!645125273261!e!!g!!aws!19574556887!145779846712&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all)
- [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


## Create new user in AWS and configure AWS CLI
Create a new user. Don't use root account when it's not required. Create a new IAM user that has admin access.

## Install aws-cli
**Download source code and install.**
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Verify
```sh
aws -v
```
or
```sh
aws -version
```

**Login**
```sh
aws configure
```


## Install terraform
### debian/ubuntu
**Install required dependencies**
```sh
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```
Verify
```sh
terraform -v
```
or
```sh
terraform -version
```

**Add the official HashiCorp repository to your system**

The lsb_release -cs command finds the distribution release codename for your current system, such as `buster`, `groovy`, or `sid`.
```sh
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```


## Reference

**Aws**
- [AWS](https://aws.amazon.com)

- [ec2 instance](https://docs.aws.amazon.com/ec2/?nc2=h_ql_doc_ec2)

- [aws VPC](https://docs.aws.amazon.com/vpc/?icmpid=docs_homepage_featuredsvcs)

**Terraform**
- [Terraform providers](https://registry.terraform.io/browse/providers)

- [Terraform aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)

- [Terraform aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

- [Terraform aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

- [Terraform aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)

- [Terraform aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

- [Terraform aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

- [Terraform aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

- [Terraform aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

