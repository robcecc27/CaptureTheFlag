# Capture The Flag (CTF) Environment in AWS

This Terraform project sets up a Capture The Flag (CTF) environment in AWS, consisting of a VPC, public and private subnets, an Internet Gateway, a Route Table, Security Groups, and EC2 instances.

## Prerequisites

- AWS CLI
- Terraform CLI (version 0.13+)

## Getting Started

1. Clone this repository to your local machine.

2. Install the AWS CLI and configure your AWS credentials. For instructions, refer to the [official AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

3. Install the Terraform CLI. For instructions, refer to the [official Terraform documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli).

4. Create the S3 bucket for storing the Terraform state file:

   ```shell
   aws s3api create-bucket --bucket "terraformstate<ACCOUNTNUMBER>" --region "us-east-1"
   ```

   Replace `<ACCOUNTNUMBER>` with your AWS account number.

   Remember this bucket will remain after `Terraform Destroy` so you will need to manually remove if it's no longer needed.

5. Create the DynamoDB table for state locking:

   ```shell
   aws dynamodb create-table \
     --table-name terraform-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
     --region us-east-1
   ```

   Remember this DynamoDB will remain after `Terraform Destroy` so you will need to manually remove if it's no longer needed.

6. Initialize the Terraform working directory:

   ```hcl
   terraform init
   ```

7. Preview the changes to be applied:

   ```hcl
   terraform plan
   ```

8. Apply the changes:

   ```hcl
   terraform apply
   ```

   Review the changes and type `yes` when prompted to create the resources.

9. To connect to the public instances, use the SSH commands provided in the output:

   ```shell
   chmod 400 ctf-key-pair-private.pem
   ssh -i 'ctf-key-pair-private.pem' ec2-user@<public-instance-dns>
   ```

   Replace `<public-instance-dns>` with the public DNS of the desired instance.

10. When you are done with the environment, destroy the resources to avoid unnecessary costs:

    ``` shell
    terraform destroy
    ```

    Review the changes and type `yes` when prompted to destroy the resources.

## Note

Remember to replace `<ACCOUNTNUMBER>` with your actual AWS account number in both the AWS CLI commands and the `main.tf` file.

------

## Infrastructure Overview

This Terraform configuration creates an AWS infrastructure for a Capture the Flag (CTF) environment. The infrastructure consists of the following components:

1. **VPC**: A Virtual Private Cloud (VPC) is created to host the CTF environment. This VPC isolates the environment from other resources in your AWS account.

2. **Subnets**: Two subnets are created within the VPC:
   - A public subnet that hosts instances accessible from the internet.
   - A private subnet that hosts instances that are only accessible from the public subnet.

3. **Internet Gateway**: An Internet Gateway (IGW) is attached to the VPC, allowing internet access for resources within the public subnet.

4. **Route Table**: A custom route table is created and associated with the public subnet. It has a route that directs all internet-bound traffic to the Internet Gateway.

5. **Security Groups**: Two security groups are created to manage the ingress traffic to instances in the public and private subnets:
   - The public security group allows SSH (port 22), HTTP (port 80), and HTTPS (port 443) traffic from any IP address.
   - The private security group allows MySQL (port 3306) traffic from instances within the public security group.

6. **EC2 Instances**: A total of four Amazon EC2 instances are created:
   - Three instances are created in the public subnet for participants to access and attempt to capture the flags.
   - One instance is created in the private subnet, acting as a MySQL server. This instance can only be accessed from the instances in the public subnet.

7. **Key Pair**: An RSA key pair is generated for SSH access to the instances. The public key is imported into AWS, while the private key is saved locally and uploaded to an S3 bucket.

8. **User Data**: A user data script is provided for the private instance, which sets up the MySQL server, creates an admin user, and configures the database.

9. **Tags**: All resources are tagged with `CaptureTheFlag=Challenge` for easier identification and management.

10. **Terraform State**: The Terraform state file is stored in an S3 bucket with a specified name pattern, and a DynamoDB table is used for state locking.
