# Compute Instance Configuration (for new OCI instances)

#### OCI Demo Instances

There are two Oracle Linux 7.9 instances running in OCI, each with 2 CPUs (4 cores) and 32GB of RAM.  

* `graal-demo-01: 132.145.18.207`
* `graal-demo-02: 132.145.21.88`

> **NOTE:** The demo environment is already configured, the following instructions are informational.

To access the systems (assuming your keys are stored in `$HOME/.ssh`):
```
$ ssh -i $HOME/.ssh/ssh-key-graal-demo-1.key opc@132.145.18.207
```
or

```
$ ssh -i $HOME/.ssh/ssh-key-graal-demo-2.key opc@132.145.21.88
```

> **NOTE:** You'll need to obtain the necessary key files to access the systems.


#### Install SDKMAN

```
$ curl -s "https://get.sdkman.io" | bash
$ source "$HOME/.sdkman/bin/sdkman-init.sh"
```

#### Install GraalVM (on Node 2)

Install the base and native image packages:

```
$ sudo yum provides graalvm21-ee-17-sdk*
$ sudo yum install graalvm21-ee-17-jdk-21.3.0-1.el7.x86_64
$ sudo yum install graalvm21-ee-17-native-image-21.3.0-1.el7.x86_64
```

Using SDKMAN, add GraalVM 21.3.0:
```
$ sdk install java 21.3.0-17-ee /usr/lib64/graalvm/graalvm21-ee-java17/
```
Set GraalVM 21.3.0 as the default Java runtime:
```
$ sdk default java 21.3.0-17-ee
```



#### Install Docker 

Docker will be used to support infrastructure services and for deploying demo applications.

> **NOTE:** With Oracle Linux 7.9, begin by editing `/etc/yum.repos.d/oraclelinux-developer-ol7.repo` and change the block `[ol7_developer]` from `enabled=0` to `enabled=1`:
> 
> ```
> [ol7_developer]
> name=Oracle Linux $releasever Development Packages ($basearch)
> baseurl=https://yum$ociregion.$ocidomain/repo/OracleLinux/OL7/developer/$basearch/
> gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
> gpgcheck=1
> enabled=1
> ```

Next, install the `docker-engine` package, add your user to the `docker` group and start/enable `docker`:
```
$ sudo yum install -y docker-engine
$ sudo usermod -aG docker opc
$ newgrp docker
$ sudo systemctl start docker
$ sudo systemctl enable docker
```

### Adding Dashboard Components

We'll need to install/configure the following components to support the demo environment:

* cadvisor
* Node-exporter
* Prometheus
* Grafana
* Firewall Ports


#### Install cadvisor Container

```
$ docker run -d -p 8081:8080 -v /:/rootfs:ro -v /var/run:/var/run:rw -v /sys:/sys:ro -v /var/lib/docker/:/var/lib/docker:ro --name=cadvisor google/cadvisor:latest
```

Confirm the container is processing data: http://132.145.18.207:8081/containers/

#### Install node-exporter

`Node-explorer` is a Prometheus exporter for hardware and OS metrics exposed by Linux kernels (there is also a Windows exxporter).

Download site: https://prometheus.io/download/#node_exporter

```
$ wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
$ tar xvfz node_exporter-*.*-amd64.tar.gz
$ cd node_exporter-*.*-amd64
```
```
$ sudo mv node_exporter /usr/local/bin
```

```
$ sudo useradd -s /sbin/false node_exporter
```


```
$ sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

Create a file called `/etc/systemd/system/node_exporter.service` and add the configuration below:
```
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
```

Reload the system daemon and start `node_exporter`:
```
$ sudo systemctl daemon-reload
$ sudo systemctl start node_exporter
```
Check the `node_exporter service` status using the following command:
```
$ sudo systemctl status node_exporter
```
Enable the service to start automatically:
```
$ sudo systemctl enable node_exporter
```

#### Installing Prometheus

Download the [latest release](https://prometheus.io/download/) of Prometheus for your platform, then extract it (in this example, the file was extracted in `/opt`):

```
$ tar xvfz prometheus-*.tar.gz
```

```
$ cd /opt/prometheus-2.31.0
```

```
$ sudo useradd -s /sbin/false prometheus
$ sudo chown -R prometheus:prometheus /opt/prometheus-2.31.0
```

Next, we'll create a Prometheus service.

Create a file called `/etc/systemd/system/prometheus.service` and add the configuration below:
```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus-2.31.0/prometheus \
    --config.file /opt/prometheus-2.31.0/prometheus.yml \
    --storage.tsdb.path /opt/prometheus-2.31.0/ \
    --web.console.templates=/opt/prometheus-2.31.0/consoles \
    --web.console.libraries=/opt/prometheus-2.31.0/console_libraries

[Install]
WantedBy=multi-user.target
```

A Prometheus configuration file (`prometheus.yml`) is required, here's an example of the configuration for this demo environment:


```
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: "prometheus"
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ["localhost:9090"]
  
  # node-exporter metrics
  - job_name: 'node'
    scrape_interval: 5s
    static_configs:
      - targets: ['132.145.21.88:9100']

  # Demo application metrics
  - job_name: 'spring-actuator'
    metrics_path: '/actuator/prometheus' # Job to scrape application metrics
    scrape_interval: 5s
    static_configs:
      - targets: ['132.145.21.88:8080']
  
  # Container metrics 
  - job_name: 'cadvisor'
    scrape_interval: 5s
    static_configs:
      - targets: [132.145.21.88:8081']
    
```

> **NOTE:** Replace the IP address with that of the compute instance.

Reload the system daemon and start Prometheus:
```
$ sudo systemctl daemon-reload
$ sudo systemctl start prometheus
```
Check the `prometheus service` status using the following command:
```
$ sudo systemctl status prometheus
```
Enable the service to start automatically:
```
$ sudo systemctl enable prometheus
```

#### Installing Grafana

Create the repo file (`/etc/yum.repos.d/grafana.repo`):

```
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
```

```
$ sudo yum install grafana
```

```
$ sudo systemctl daemon-reload
```

```
$ sudo systemctl start grafana-server
```

```
$ sudo systemctl status grafana-server
```

Configure the Grafana server to start automatically:

```
$ sudo systemctl enable grafana-server
```

#### Firewall Configuration

You'll need to add ports to the firewall configuration:

 ```
$ sudo firewall-cmd --add-port=8080/tcp --permanent
$ sudo firewall-cmd --add-port=9090/tcp --permanent
$ sudo firewall-cmd --add-port=9100/tcp --permanent
$ sudo firewall-cmd --add-port=3000/tcp --permanent
$ sudo firewall-cmd --reload
```

Confirm the ports have been added:

```
$ sudo firewall-cmd --list-all
public (active)
   target: default
   icmp-block-inversion: no
   interfaces: ens3
   sources:
   services: dhcpv6-client ssh
   ports: 8080/tcp 9090/tcp 9100/tcp 3000/tcp
   protocols:
   masquerade: no
   forward-ports:
   source-ports:
   icmp-blocks:
   rich rules:
```

### To Do ...

* Automate the installation of all components
* Deploy to Kubernetes environment

