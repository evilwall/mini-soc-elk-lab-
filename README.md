# Mini SOC with ELK Stack

This project documents the implementation of a small Security Operations Center (SOC) lab built with the ELK Stack to monitor, analyze, and detect security events in a controlled environment. 

## Overview

The project investigates how a smaller SOC environment based on Elasticsearch, Logstash, and Kibana can be used to detect and analyze common attack activity in a lab setting. The implementation also uses Fleet Server and Elastic Agent to centrally manage endpoints and collect logs from the environment. 

## Purpose

The purpose of the project was to examine how well a mini SOC built on the ELK Stack could detect Nmap scans, brute force attacks, and web-based attacks in a lab environment. 

## Lab Environment

The lab environment consisted of an attacker machine, an ELK server running Ubuntu Server 24.04, and Linux and Windows victim machines. Elasticsearch, Kibana, Logstash, Fleet Server, and Elastic Agent were installed and configured to collect, centralize, and visualize security-related events.  <img width="1133" height="417" alt="Pasted image 20260421152433" src="https://github.com/user-attachments/assets/4c8b20fe-853a-46e4-bf5e-6e633dbab601" />


## Tools and Components

- Elasticsearch for storing and searching log data. 
- Logstash for handling and processing data flows. 
- Kibana for visualization and analysis in a graphical interface. 
- Fleet Server and Elastic Agent for centralized endpoint management and log collection. 
- System integration and Elastic Defend for endpoint telemetry and security monitoring. 

## Attack Scenarios

The project tested three types of attack activity in the lab: 

- Nmap scanning. 
- RDP brute force attempts. 
- Web-based attacks using SQL injection techniques. 

## Results

The environment was able to collect, store, and visualize security events related to multiple attack types in the lab. Nmap scanning was identified through repeated network-related events over a short period, brute force behavior was observed through repeated failed login attempts, and web-based attack activity was detected through traffic analysis and a custom Elastic Security query rule. 

### Nmap scanning
The environment was able to identify Nmap scanning through repeated network-related events over a short period.
<img width="2502" height="1132" alt="Pasted image 20260417133226" src="https://github.com/user-attachments/assets/624ae3bf-8722-4e3c-8db8-1a9cee3d32dc" />

### Brute force detection
Brute force behavior was observed through repeated failed login attempts in the collected logs.
<img width="2202" height="861" alt="Pasted image 20260417174707" src="https://github.com/user-attachments/assets/82418fc4-5c17-47e3-b4c2-e49c1aa65004" />

### Web-based attack detection
Web-based attack activity was detected through traffic analysis and a custom Elastic Security query rule.
<img width="2207" height="600" alt="Pasted image 20260417174440" src="https://github.com/user-attachments/assets/6b4b8519-233d-42ad-a8fa-61ba1999448f" />



## Discussion

The results indicate that the configured mini SOC can serve as a practical foundation for simpler security monitoring and analysis. At the same time, detection capability depends heavily on correct installation, relevant data sources, and well-configured rules and integrations. 

A key strength of the solution is centralized log management and visualization in Kibana, which supports analysis of network events and authentication attempts. A limitation is that the project was performed in a small lab environment and only covered a limited number of attack types, so the results cannot be directly generalized to larger production environments. 

## Conclusion

The project shows that it is possible to build a smaller SOC environment with the ELK Stack and use it to monitor and analyze security events in a lab setting. The work demonstrates that a mini SOC can be a useful educational and practical approach for understanding basic security monitoring and incident handling. 

## Scope Limitations

The work is limited to a small lab environment and focuses on a restricted set of tools and attack types. It does not cover full-scale production deployment, advanced attack chains, or a broader range of threats.

## Notes

This repository is intended for educational and lab use. Any deployment outside a controlled environment would require additional hardening, validation, and environment-specific adjustments. 

## Tools and commands
### Nmap
```
nmap {ipaddress}

```
### SQL Injections
```
sqlmap -u "http://{ipaddress}/api/products/1*"
 
```
### RDP Brute force
```
┌──(root㉿kali)-[/home/kali]
└─# hydra -L username.txt -P passwords.txt -vV rdp://{ipaddress}

```


# Mini SOC ELK Install Script (Ubuntu 24.04)

This guide explains how to use the provided Bash script to automatically install and configure a mini SOC based on the Elastic Stack (Elasticsearch, Kibana, Logstash, Fleet Server, and Elastic Agent) on Ubuntu Server 24.04.  

> Lab use only. Do not store real passwords, enrollment tokens, service tokens, or log files with sensitive data in this repository.

---

## 1. Requirements

- Ubuntu Server 24.04
- Root access or a user with `sudo` privileges
- Internet access to reach Elastic package repositories  
- The installation script saved on the server (for example as `install_elk.sh`)

Make the script executable:

```bash
chmod +x install_elk.sh
```

---

## 2. Run the script

Run the script as root (or with sudo):

```bash
sudo ./install_elk.sh
```

The script will:

- Update the system and install required dependencies  
- Add the Elastic 8.x APT repository and GPG key  
- Install Elasticsearch, Kibana, and Logstash  
- Configure Elasticsearch as a single-node lab instance  
- Configure Kibana to listen on all interfaces and generate encryption keys  
- Enable and start Elasticsearch, Kibana, and Logstash services  
- Print next steps for securing access and setting up Fleet Server and agents  

> If you are not root, the script will exit and ask you to run it with `sudo`.

---

## 3. What the script configures

### Elasticsearch

- Single-node mode:
  ```yaml
  discovery.type: single-node
  ```
- Listens on all interfaces (lab only):
  ```yaml
  network.host: 0.0.0.0
  ```
- Comments out `cluster.initial_master_nodes` for single-node setups  

After installation, the script:

- Enables and starts the `elasticsearch` service  
- Waits ~30 seconds and checks that `https://localhost:9200` is responding  

### Kibana

- Backs up the original `kibana.yml`  
- Sets:
  ```yaml
  server.host: "0.0.0.0"
  server.port: 5601
  ```
- Generates encryption keys using `kibana-encryption-keys` and appends them to `kibana.yml`  
- Enables and starts the `kibana` service  
- Waits ~60 seconds and prints the service status  

### Logstash

- Installs Logstash (optional but included)  
- Enables and starts the `logstash` service  

---

## 4. Next steps after the script finishes

When the script completes, it prints a summary with important next steps, including:

### 4.1. Reset `elastic` user password

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

Note the generated password and keep it secure.[web:60]

### 4.2. Create Kibana enrollment token

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

### 4.3. Log in to Kibana

1. Check the server IP:
   ```bash
   hostname -I
   ```
2. Open Kibana in your browser (HTTP, not HTTPS):
   ```text
   http://<SERVER_IP>:5601
   ```
3. Paste the enrollment token
4. Log in with:
   - Username: `elastic`
   - Password: (from the reset command above)

---

## 5. Set up Fleet Server and Elastic Agent

Inside Kibana:

1. Go to **Management → Fleet**  
2. Click **Add Fleet Server → Quick start**  
3. Copy the `elastic-agent install` command shown in the UI, which will look similar to:

   ```bash
   sudo elastic-agent install \
     --url=https://<SERVER_IP>:8220 \
     --enrollment-token=<ENROLLMENT_TOKEN> \
     --fleet-server-es=https://localhost:9200 \
     --fleet-server-service-token=<SERVICE_TOKEN> \
     --fleet-server-policy=fleet-server-policy
   ```

4. Run this command on the same server where you ran the script  
5. When Fleet Server is enrolled, create an **Agent policy** (e.g. `SOC-Endpoints`) and add:
   - `System` integration (logs and metrics)
   - `Elastic Defend` integration (endpoint security)

Then enroll your lab endpoints (Kali, Linux, Windows) via **Fleet → Agents → Add agent** using the `SOC-Endpoints` policy.[web:41]

---

## 6. Firewall (if UFW is enabled)

If `ufw` is installed and active, open the required ports:

```bash
sudo ufw allow 9200/tcp    # Elasticsearch
sudo ufw allow 5601/tcp    # Kibana
sudo ufw allow 8220/tcp    # Fleet Server
sudo ufw reload
```

---

## 7. Troubleshooting

Useful commands if something is not working:

```bash
# Elasticsearch logs
sudo journalctl -u elasticsearch -f

# Kibana logs
sudo journalctl -u kibana -f

# Test Elasticsearch
curl -k -u elastic:<PASSWORD> https://localhost:9200

# Test Kibana
curl http://localhost:5601/status
```

Config files to check:

- `/etc/elasticsearch/elasticsearch.yml`  
- `/etc/kibana/kibana.yml`  
- `/tmp/elasticsearch_install.log` (install log created by the script)
