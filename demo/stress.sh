#!/usr/bin/env bash

hey -z 10m http://localhost:8085/primes &
hey -z 10m http://localhost:8086/primes &
hey -z 10m http://localhost:8087/primes &
hey -z 10m http://localhost:8088/primes &
hey -z 10m http://localhost:8089/primes &
