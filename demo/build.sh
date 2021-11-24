#!/usr/bin/env bash

VER=0.1

echo "Building Java..."
mvn clean package -DskipTests
echo "Building Java - DONE"

echo "Building Native Image..."
mvn package -Pnative
mvn package -Pnative-g1
mvn package -Pnative-inst
if test -f "./profiles/primes.iprof"; then
    echo "Building OPTIMISED Native Image..."
    mvn package -Pnative-opt
    echo "Building OPTIMISED Native Image DONE"
fi
echo "Building Native Image - DONE"

echo "Building docker containers..."
docker login container-registry.oracle.com
docker build -f ./Dockerfile.jvm -t localhost/primes:openjdk.${VER} .
docker build -f ./Dockerfile.graalee -t localhost/primes:graalee.${VER} .
docker build -f ./Dockerfile.native -t localhost/primes:native.${VER} .
docker build -f ./Dockerfile.native-g1 -t localhost/primes:nativeg1.${VER} .
docker build -f ./Dockerfile.native-inst -t localhost/primes:nativeinst.${VER} .
if test -f "./target/prime-opt"; then
    echo "Building OPTIMISED docker container for Native Image..."
    docker build -f ./Dockerfile.native-opt -t localhost/primes:nativeinst.${VER} .
    echo "Building OPTIMISED docker container for Native Image DONE"
fi
echo "Docker docker containers - DONE"
