#!/bin/bash
# script vatiables
APP_DIR=./app/*
PACKAGES_DIR=./env/lib/python3.7/site-packages/*
TEMPORARY_DIR=./temp

# creating temporary folder to zip
rm -rf $TEMPORARY_DIR
mkdir $TEMPORARY_DIR
cp -r $PACKAGES_DIR $TEMPORARY_DIR
cp -r $APP_DIR $TEMPORARY_DIR
echo "New temp folder created"

# call terraform to deploy on AWS
terraform init
terraform init
terraform apply

# Test call to API endpoint
echo " "
echo "Testing API endpoint"
echo "..."
API_URL=$(terraform output -raw deployment_invoke_url)
curl $API_URL
echo " "

# delete temporary folder
#rm -rf ./temp
