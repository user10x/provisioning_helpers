1. Write a Terraform configuration that provisions an EC2 instance and creates security group rules restricting access to only SSH IP whitelist. Use variables appropriately to allow the instance to be created in any data center, change the instance type, and change the IP whitelist. 


2. Write a Dockerfile that installs the latest Python AWS CLI and allows the container run the AWS CLI tool on the command line. The final container image should contain only the necessary elements for support the AWS CLI execution.


3. Write a bash script that hits the AWS EC2 local metadata API, and can be run on an EC2 instance to produce `export` statements which set environment variables containing the instance type, IP address, region, and availability zone.
