#!/usr/bin/env bash

VER=0.1

echo -ne "Building Java project ... "
mvn clean package -DskipTests > /dev/null 2>&1
echo "Done."

echo -ne "Building Native Image executables (please be patient) ... "
mvn package -Pnative > /dev/null 2>&1
mvn package -Pnative-g1 > /dev/null 2>&1
mvn package -Pnative-inst > /dev/null 2>&1
if test -f "./profiles/primes.iprof"; then
    echo -ne "Building OPTIMISED Native Image ... "
    mvn package -Pnative-opt > /dev/null 2>&1
    echo "Done."
fi
echo "Done."

echo -ne "Logging into the container registry ... "
docker login container-registry.oracle.com > /dev/null 2>&1
echo -ne "Building containers ... "
docker build -f ./Dockerfiles/Dockerfile.jvm -t localhost/primes:openjdk.${VER} . > /dev/null 2>&1
docker build -f ./Dockerfiles/Dockerfile.graalee -t localhost/primes:graalee.${VER} . > /dev/null 2>&1
echo "Done."
echo -ne "Building Native Image Executable container (please be patient) ... "
docker build -f ./Dockerfiles/Dockerfile.native --build-arg APP_FILE=prime -t localhost/primes:native.${VER} . > /dev/null 2>&1
echo "Done."
echo -ne "Building Native Image Executable with G1GC container (please be patient) ... "
docker build -f ./Dockerfiles/Dockerfile.native --build-arg APP_FILE=prime-g1 -t localhost/primes:nativeg1.${VER} . > /dev/null 2>&1
echo "Done."
echo -ne "Building Instrumented Native Image Executable container (please be patient) ... "
docker build -f ./Dockerfiles/Dockerfile.native --build-arg APP_FILE=prime-inst -t localhost/primes:nativeinst.${VER} . > /dev/null 2>&1
if test -f "./target/prime-opt"; then
    echo -ne "Building OPTIMISED docker container for Native Image..."
    docker build -f ./Dockerfiles/Dockerfile.native --build-arg APP_FILE=prime-opt -t localhost/primes:nativeopt.${VER} . > /dev/null 2>&1
    echo "Done."
fi
echo "Done."
echo ""
echo "Container build - Done."
