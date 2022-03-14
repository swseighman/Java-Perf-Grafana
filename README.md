
# Java Performance Comparison Dashboard Demo

The goal of this demo is to compare performance of Java applications running in a virtual environment or deployed in containers.  

To access the system:
```
$ ssh -i ~username/.ssh/ssh-key-graal-demo-1.key opc@129.146.21.243
```

> **NOTE:** You'll need to obtain the necessary key files to access the systems.

### Starting the Demo Environment

If the repository hasn't already been cloned, you can access it here:

```
$ git clone https://github.com/swseighman/Java-Perf-Gafana.git
```

Change to the demo directory:
```
$ cd /home/opc/repos/Java-Perf-Gafana/demo
```

Run `docker-compose` to start all of the services:

```
$ docker-compose up
```

### Demo Apps

A simple `primes` demo has been provided but other applications can be added.

> **NOTE:** 
> The `primes` demo has been compiled using Java 17, make certain you're using Java 17.

The `primes` demo produces data via `spring-actuator` (see source code) and is consumed by Prometheus. The app runs on port **8080**. Once started, you should begin to see data in the Grafana dashboard.

### Running Benchmarks

To help generate real-time data, `hey` has been installed so that you can run benchmark tests. A script has been provided to start the benchmark tests: 

```
$ ./stress.sh
```

To stop all of the services execute:

```
$ docker-compose stop
```

### Accessing the Grafana Dashboard

To access the Grafana dashboard (with application data), browse to: http://129.146.21.243:3000/login

![](images/mocha-dashboard-6.png)

Credentials:

**Login:** admin

**Password:** admin

You can **Skip** changing the admin password:

![](images/mocha-dashboard-5.png)

By default, the **Mocha Optimization and High Performance** dashboard will be displayed which includes a collection of metrics scraped from:

* Prometheus
* Node (system metrics)
* Cadvisor (containers)
* Spring-actuator (demo app)

This first graph represents memory utilization, the second reflects application startup time. The far-right graphs show the percentage improve of resources (memory) and startup time.

The OpenJDK graph on the left represents an optimized application while native image (on the right) represents the high-performant AOT application.

The last graph displays a comparison of application throughput.

![](images/mocha-dashboard-1.png)
