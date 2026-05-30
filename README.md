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

# Mini SOC with ELK Stack on Ubuntu 24.04 installations guide

This guide describes how to install and configure a small SOC environment using the Elastic Stack (Elasticsearch, Logstash, Kibana) together with Fleet Server and Elastic Agent on Ubuntu Server 24.04.  

> Lab use only. Do not use real credentials, tokens, or production data in this environment.

---

## 1. Prerequisites

- Ubuntu Server 24.04 (fresh or up to date)  
- Root or `sudo` access  
- Internet access to reach Elastic package repositories  

---

## 2. System update and dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y gnupg2 apt-transport-https curl wget
```

---

## 3. Add Elastic 8.x APT repository

Import the Elastic GPG key:

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch \
  | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
```

Add the Elastic repository:

```bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main
EOF
```

Update package lists:

```bash
sudo apt update
```

---

## 4. Install and configure Elasticsearch (single node)

Install:

```bash
sudo apt install -y elasticsearch
```

Backup and edit config:

```bash
sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak
sudo nano /etc/elasticsearch/elasticsearch.yml
```

Add or ensure these lines exist:

```yaml
discovery.type: single-node
network.host: 0.0.0.0
#cluster.initial_master_nodes:
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
```

Test after ~30 seconds:

```bash
curl -k https://localhost:9200
```

> During installation, Elasticsearch may generate a password for the `elastic` user. Store it securely and never commit it to Git.

---

## 5. Install and configure Kibana

Install:

```bash
sudo apt install -y kibana
```

Backup and edit config:

```bash
sudo cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak
sudo nano /etc/kibana/kibana.yml
```

Ensure at least:

```yaml
server.host: "0.0.0.0"
server.port: 5601
```

Generate encryption keys and append to `kibana.yml`:

```bash
sudo /usr/share/kibana/bin/kibana-encryption-keys generate -q \
  | sudo tee -a /etc/kibana/kibana.yml
```

Enable and start:

```bash
sudo systemctl enable kibana
sudo systemctl start kibana
```

Check status:

```bash
curl http://localhost:5601/status
```

Open in browser:

```text
http://<SERVER_IP>:5601
```

---

## 6. Reset `elastic` password and create Kibana enrollment token

Reset `elastic` if needed:

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

Create Kibana enrollment token:

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

Then:

1. Open `http://<SERVER_IP>:5601`
2. Paste the enrollment token
3. Log in with:
   - Username: `elastic`
   - Password: (from the reset command)

---

## 7. Install Logstash (optional)

```bash
sudo apt install -y logstash
sudo systemctl enable logstash
sudo systemctl start logstash
```

---

## 8. Set up Fleet Server in Kibana

1. In Kibana, go to **Management → Fleet**  
2. Click **Add Fleet Server → Quick start**  
3. Copy the generated `elastic-agent install` command (similar to):

   ```bash
   sudo elastic-agent install \
     --url=https://<SERVER_IP>:8220 \
     --enrollment-token=<ENROLLMENT_TOKEN> \
     --fleet-server-es=https://localhost:9200 \
     --fleet-server-service-token=<SERVICE_TOKEN> \
     --fleet-server-policy=fleet-server-policy
   ```

4. Run that command on the ELK server

---

## 9. Create agent policy and add integrations

1. **Management → Fleet → Agent policies → Create agent policy**  
2. Name it e.g. `SOC-Endpoints`  
3. Add integrations:
   - `System` (logs and metrics)
   - `Elastic Defend` (endpoint security)

---

## 10. Enroll lab endpoints

For each endpoint (Kali, Linux, Windows):

1. Go to **Management → Fleet → Agents → Add agent**  
2. Select `SOC-Endpoints` policy  
3. Copy the install command for the target OS  

Example Linux:

```bash
sudo ./elastic-agent install \
  --url=https://<FLEET_SERVER_IP>:8220 \
  --enrollment-token=<ENROLLMENT_TOKEN>
```

Example Windows (MSI):

```powershell
elastic-agent-<VERSION>-windows-x86_64.msi `
  INSTALLARGS="--url=https://<FLEET_SERVER_IP>:8220 --enrollment-token=<ENROLLMENT_TOKEN>"
```

Verify in Kibana:

- `Security → Hosts`
- `Security → Alerts`

---

## 11. Open firewall ports (if UFW is enabled)

```bash
sudo ufw allow 9200/tcp    # Elasticsearch
sudo ufw allow 5601/tcp    # Kibana
sudo ufw allow 8220/tcp    # Fleet Server
sudo ufw reload
```

---

## 12. Troubleshooting

Elasticsearch logs:

```bash
sudo journalctl -u elasticsearch -f
```

Kibana logs:

```bash
sudo journalctl -u kibana -f
```

Test Elasticsearch:

```bash
curl -k -u elastic:<PASSWORD> https://localhost:9200
```

Test Kibana:

```bash
curl http://localhost:5601/status
```

Config files:

- `/etc/elasticsearch/elasticsearch.yml`
- `/etc/kibana/kibana.yml`

---

## 13. Lab attack commands

### Nmap

```bash
nmap <target-ip>
```

### SQL injection with sqlmap

```bash
sqlmap -u "http://<target-ip>/api/products/1*"
```

### RDP brute force with hydra

```bash
hydra -L username.txt -P passwords.txt -vV rdp://<target-ip>
```

> Only use these against systems you own or are explicitly allowed to test.
