cd $HOME/.ssh
ssh-keygen -t rsa -b 2048 -v  #name your key #ec2-key
cp ec2-key.pub $OLDPWD # copy key to the project directory
cd $OLDPWD
terraform init #initialize
terraform plan #resources to be created
terraform apply #run and outputs server ip for ubuntu ami used
ssh -i <path_to_private_key> ubuntu@<server_ip>
