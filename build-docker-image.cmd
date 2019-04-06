
set IMAGE_NAME=segence/hadoop
set VERSION=0.8.0

docker build -t %IMAGE_NAME%:%VERSION% docker-container
docker tag %IMAGE_NAME%:%VERSION% %IMAGE_NAME%:latest

