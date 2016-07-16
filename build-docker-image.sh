#!/bin/bash

VERSION=$(cat version.txt)
docker build -t segence/hadoop:$VERSION docker-container
