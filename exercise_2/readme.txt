# build
docker build -t aws-cli:1.0 .

# run and test (runs with default axiom iam user with s3 read and list permission)
docker run aws-cli:1.0 s3 ls

# or override env variables
docker run  -e AWS_ACCESS_KEY_ID=<input-your-key> -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION aws-cli s3 ls
