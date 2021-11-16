# Prime Numbers Project

Prime Numbers is a Spring Boot based project with a RESTful Prime Numbers API service. 

## How to build

This is a standard Maven project, so just run `mvn clean install` and the project will be compiled and the tests will run.

You require the following to build the project:

* [Oracle JDK 17](http://www.oracle.com/technetwork/java/)
* [Apache Maven](http://maven.apache.org/)

JDK 17 is required to build and run this project.

## Running the Project

The project uses [Spring Boot](http://projects.spring.io/spring-boot/) which makes configuring and running a web based application a breeze.

In order to run the project from the command line follow the [steps](http://docs.spring.io/spring-boot/docs/current/reference/html/using-boot-running-your-application.html#using-boot-running-with-the-maven-plugin) provided by Spring Boot.

From the project base directory you can run `mvn spring-boot:run` which will start the application on `http://localhost:8080`

## Using the Project API

The project is configured with two RESTful API operations:

* [Generate Primes](#generate-primes)
* [Prime Number Validator](#prime-number-validator)

### Generate Primes

When called, this API operation will generate prime numbers from `2` to `upperBound` (inclusive).

#### Operation Examples

The example below will return a JSON array of prime numbers from `2` to the `default upperBound` (the default is `20`) 

```
$ curl -v http://localhost:8080/primes

*   Trying ::1...
* Connected to localhost (::1) port 8080 (#0)
> GET /primes HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.43.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Server: Apache-Coyote/1.1
< Content-Type: application/json;charset=UTF-8
< Transfer-Encoding: chunked
< Date: Thu, 23 Jun 2016 10:12:59 GMT
< 
* Connection #0 to host localhost left intact
[2,3,5,7,11,13,17,19]
```

The example below will return a JSON array of prime numbers from `2` to the given `upperBound`

```
$ curl -v http://localhost:8080/primes?upperBound=100
*   Trying ::1...
* Connected to localhost (::1) port 8080 (#0)
> GET /primes?upperBound=100 HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.43.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Server: Apache-Coyote/1.1
< Content-Type: application/json;charset=UTF-8
< Transfer-Encoding: chunked
< Date: Thu, 23 Jun 2016 10:15:58 GMT
< 
* Connection #0 to host localhost left intact
[2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97]
```

### Prime Number Validator

When called, this API operation will determine whether or not the supplied number is prime.

If the number supplied is prime, the operation will return a `200 OK` HTTP status response.

If the number supplied is not prime, the operation will return a `404 Not Found` HTTP status response.

In addition, there are three possible algorithms (sieve, slow, and fast) to use when determining if the number supplied is prime. You can switch between them by specifying `algorithm=1`, `algorithm=2`, or `algorithm=3` as a request parameter in the query string. A value of `2` will use the fast, `3` will use the slow, and any other whole number will use the sieve algorithm. By default the API operation uses the sieve algorithm.

#### Operation Examples

The example below checks to see if the number `121` is prime using the sieve algorithm. As you will see it returns a `404 Not Found` response as `121` is not prime

```
$ curl -v http://localhost:8080/primes/121
*   Trying ::1...
* Connected to localhost (::1) port 8080 (#0)
> GET /primes/121 HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.43.0
> Accept: */*
> 
< HTTP/1.1 404 Not Found
< Server: Apache-Coyote/1.1
< Content-Length: 0
< Date: Thu, 23 Jun 2016 10:22:41 GMT
< 
* Connection #0 to host localhost left intact
```

The example above can be executed again, using the fast algorithm.

```
$ curl -v http://localhost:8080/primes/121?algorithm=2
*   Trying ::1...
* Connected to localhost (::1) port 8080 (#0)
> GET /primes/121?algorithm=2 HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.43.0
> Accept: */*
> 
< HTTP/1.1 404 Not Found
< Server: Apache-Coyote/1.1
< Content-Length: 0
< Date: Thu, 23 Jun 2016 10:23:25 GMT
< 
* Connection #0 to host localhost left intact
```

Similarly, the example above can be executed again, using the slower algorithm.

```
$ curl -v http://localhost:8080/primes/121?algorithm=3
*   Trying ::1...
* Connected to localhost (::1) port 8080 (#0)
> GET /primes/121?algorithm=3 HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.43.0
> Accept: */*
> 
< HTTP/1.1 404 Not Found
< Server: Apache-Coyote/1.1
< Content-Length: 0
< Date: Thu, 23 Jun 2016 10:23:25 GMT
< 
* Connection #0 to host localhost left intact
```

The following example demonstrates what is returned when the number supplied is prime. As you will see it returns a `200 OK` response. 

```
$ curl -v http://localhost:8080/primes/7919?algorithm=1
*   Trying ::1...
* Connected to localhost (::1) port 8080 (#0)
> GET /primes/7919?algorithm=1 HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.43.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Server: Apache-Coyote/1.1
< Content-Length: 0
< Date: Thu, 23 Jun 2016 10:24:46 GMT
< 
* Connection #0 to host localhost left intact
```