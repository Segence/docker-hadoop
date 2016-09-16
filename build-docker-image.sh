#!/bin/bash

IMAGE_NAME=segence/hadoop
VERSION=$(cat version.txt)

docker build -t $IMAGE_NAME:$VERSION docker-container
docker tag -f $IMAGE_NAME:$VERSION $IMAGE_NAME:latest

