#!/usr/bin/env bash

hey -z 10m http://localhost:8085/primes/9999999999 &
hey -z 10m http://localhost:8086/primes/9999999999 &
hey -z 10m http://localhost:8087/primes/9999999999 &
hey -z 10m http://localhost:8088/primes/9999999999 &
hey -z 10m http://localhost:8089/primes/9999999999 &
