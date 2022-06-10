#!/usr/bin/env bash

VER=0.1

echo -ne "Building Maven project ... "
mvn clean package -DskipTests > /dev/null 2>&1
echo "Done."

echo -ne "Logging into the container registry ... "
docker login container-registry.oracle.com > /dev/null 2>&1
echo -ne "Building JAR-based containers ... "
docker build -f ./Dockerfiles/Dockerfile.jvm -t localhost/primes:openjdk.${VER} . > /dev/null 2>&1
docker build -f ./Dockerfiles/Dockerfile.graalee -t localhost/primes:graalee.${VER} . > /dev/null 2>&1
echo "Done."
echo -ne "Building Native Image Executable container (please be patient) ... "
docker build -f ./Dockerfiles/Dockerfile.stage-native --build-arg APP_FILE=prime -t localhost/primes:native.${VER} . > /dev/null 2>&1
echo "Done."
echo -ne "Building Native Image Executable with G1GC container (please be patient) ... "
docker build -f ./Dockerfiles/Dockerfile.stage-g1 --build-arg APP_FILE=prime-g1 -t localhost/primes:nativeg1.${VER} . > /dev/null 2>&1
echo "Done."
echo -ne "Building Instrumented Native Image Executable container (please be patient) ... "
docker build -f ./Dockerfiles/Dockerfile.stage-inst --build-arg APP_FILE=prime-inst -t localhost/primes:nativeinst.${VER} . > /dev/null 2>&1

echo "Docker docker containers - DONE"