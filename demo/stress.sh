#!/usr/bin/env bash

hey -z 10m http://localhost:8085/primes?upperBound=99999 &
hey -z 10m http://localhost:8086/primes?upperBound=99999 &
hey -z 10m http://localhost:8087/primes?upperBound=99999 &
hey -z 10m http://localhost:8088/primes?upperBound=99999 &
hey -z 10m http://localhost:8089/primes?upperBound=99999 &
hey -z 10m http://localhost:8090/primes?upperBound=99999 &
