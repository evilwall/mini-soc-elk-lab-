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




Here is a concise installation guide in English, in Markdown format, based on your lab and script.

You can paste this directly into your README and adjust any wording you want.

---

# Mini SOC with ELK Stack on Ubuntu 24.04

This guide describes how to install and configure a small SOC environment using the Elastic Stack (Elasticsearch, Logstash, Kibana) together with Fleet Server and Elastic Agent on Ubuntu Server 24.04.[[linuxtechi](https://www.linuxtechi.com/how-to-install-elk-stack-on-ubuntu/)]

## 1. Prerequisites

- Ubuntu Server 24.04 (fresh or up-to-date)
    
- Root access or a user with `sudo` privileges
    
- Internet access to reach Elastic package repositories[[itnixpro](https://itnixpro.com/install-elk-stack-8-on-ubuntu/)]
    
    > Lab use only. Do not use real credentials, tokens, or production data in this environment.
    

## 2. Update the system and install dependencies

bash

`sudo apt update && sudo apt upgrade -y sudo apt install -y gnupg2 apt-transport-https curl wget`

## 3. Add Elastic 8.x APT repository

1. Import the Elastic GPG key:
    
    bash
    
    `wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch \   | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg`
    
2. Add the Elastic repository:
    
    bash
    
    `cat <<EOF | sudo tee /etc/apt/sources.list.d/elastic-8.x.list deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main EOF`
    
3. Update package lists:
    
    bash
    
    `sudo apt update`
    
    Elastic 8.x packages are now available via APT.[[ultahost](https://ultahost.com/knowledge-base/install-elk-stack-ubuntu/)]
    

## 4. Install Elasticsearch

bash

`sudo apt install -y elasticsearch`

Enable and start the service:

bash

`sudo systemctl daemon-reload sudo systemctl enable elasticsearch sudo systemctl start elasticsearch`

Wait about 30 seconds, then verify:

bash

`curl -k https://localhost:9200`

If the service responds with basic cluster info, Elasticsearch is running.[[linuxcapable](https://linuxcapable.com/how-to-install-elasticsearch-8-on-ubuntu-linux/)]

> During the first install, Elasticsearch may generate a password and security credentials. Store any generated passwords securely and never commit them to Git or share them publicly.

## 5. Configure Elasticsearch (single-node lab)

Backup the default config:

bash

`sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak`

Edit `/etc/elasticsearch/elasticsearch.yml` and ensure at least:

text

`discovery.type: single-node network.host: 0.0.0.0 #cluster.initial_master_nodes:`

- `discovery.type: single-node` allows a simple, single-node lab deployment.[[itnixpro](https://itnixpro.com/install-elk-stack-8-on-ubuntu/)]
    
- `network.host: 0.0.0.0` makes the service listen on all interfaces (lab use only; for production, restrict this).
    

Restart Elasticsearch for changes to take effect:

bash

`sudo systemctl restart elasticsearch`

## 6. Install Kibana

bash

`sudo apt install -y kibana`

Backup and configure:

bash

`sudo cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak`

Ensure at least:

text

`server.host: "0.0.0.0" server.port: 5601`

Generate and add Kibana encryption keys (for saved objects, alerts, etc.):[[linuxtechi](https://www.linuxtechi.com/how-to-install-elk-stack-on-ubuntu/)]

bash

`sudo /usr/share/kibana/bin/kibana-encryption-keys generate -q | sudo tee -a /etc/kibana/kibana.yml`

Enable and start Kibana:

bash

`sudo systemctl enable kibana sudo systemctl start kibana`

After ~60 seconds, check:

bash

`curl http://localhost:5601/status`

On a remote machine, open:

text

`http://<SERVER_IP>:5601`

Use the `elastic` user and the password you reset in the next step.

## 7. Reset elastic password and create Kibana enrollment token

Reset the `elastic` user password (if needed):

bash

`sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic`

Create a Kibana enrollment token:

bash

`sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana`

Then:

1. Open `http://<SERVER_IP>:5601` in a browser.
    
2. Paste the Kibana enrollment token.
    
3. Log in with:
    
    - Username: `elastic`
        
    - Password: (from the reset command above)[[itnixpro](https://itnixpro.com/install-elk-stack-8-on-ubuntu/)]
        

## 8. Install Logstash (optional for this lab)

If you want Logstash for additional pipelines:

bash

`sudo apt install -y logstash sudo systemctl enable logstash sudo systemctl start logstash`

Logstash can later be used for custom ingestion and transformation before data is sent to Elasticsearch.[[linuxtechi](https://www.linuxtechi.com/how-to-install-elk-stack-on-ubuntu/)]

## 9. Set up Fleet Server in Kibana

To centrally manage Elastic Agents, configure Fleet and Fleet Server in Kibana:[[elastic](https://www.elastic.co/guide/en/fleet/8.3/add-a-fleet-server.html)]

1. In Kibana, go to:
    
    - `Management` → `Fleet`.
        
2. Click **Add Fleet Server**, then choose **Quick start**.
    
3. Kibana will display a pre-built `elastic-agent install` command similar to:
    
    bash
    
    `sudo elastic-agent install \   --url=https://<SERVER_IP>:8220 \  --enrollment-token=<ENROLLMENT_TOKEN> \  --fleet-server-es=https://localhost:9200 \  --fleet-server-service-token=<SERVICE_TOKEN> \  --fleet-server-policy=fleet-server-policy`
    
4. Run this command on the ELK server to install Elastic Agent and Fleet Server there.
    
5. Once finished, Fleet Server should appear as an agent in the Fleet UI.
    

## 10. Create an Agent Policy and add integrations

1. In Kibana, go to:
    
    - `Management` → `Fleet` → `Agent policies`.
        
2. Click **Create agent policy** and name it something like `SOC-Endpoints`.
    
3. Add integrations to the policy:
    
    - **System** (logs and metrics)
        
    - **Elastic Defend** (endpoint protection and telemetry)[[elastic](https://www.elastic.co/docs/reference/fleet/add-fleet-server-on-prem)]
        

This policy will be used by your lab endpoints.

## 11. Enroll endpoints with Elastic Agent

For each lab endpoint (Kali, Linux, Windows):

1. In Kibana, go to:
    
    - `Management` → `Fleet` → `Agents` → **Add agent**.
        
2. Select the `SOC-Endpoints` agent policy.
    
3. Choose the correct OS tab (Linux or Windows) and copy the installation command.
    

Example for Linux:[[discuss.elastic](https://discuss.elastic.co/t/need-help-with-elastic-agent-installation/338570)]

bash

`sudo ./elastic-agent install \   --url=https://<FLEET_SERVER_IP>:8220 \  --enrollment-token=<ENROLLMENT_TOKEN>`

Example for Windows MSI:[[elastic](https://www.elastic.co/guide/en/fleet/8.14/install-agent-msi.html)]

powershell

``elastic-agent-<VERSION>-windows-x86_64.msi `   INSTALLARGS="--url=https://<FLEET_SERVER_IP>:8220 --enrollment-token=<ENROLLMENT_TOKEN>"``

After installation, check in Kibana:

- `Security` → `Hosts` to see enrolled endpoints.
    
- `Security` → `Alerts` to see detection alerts from Elastic Defend.
    

## 12. Open firewall ports (if UFW is enabled)

If `ufw` is active on the ELK server, open the standard ports:[[linuxcapable](https://linuxcapable.com/how-to-install-elasticsearch-8-on-ubuntu-linux/)]

bash

`sudo ufw allow 9200/tcp    # Elasticsearch sudo ufw allow 5601/tcp    # Kibana sudo ufw allow 8220/tcp    # Fleet Server sudo ufw reload`

## 13. Basic troubleshooting

Useful commands if something is not working:

- Elasticsearch logs:
    
    bash
    
    `sudo journalctl -u elasticsearch -f`
    
- Kibana logs:
    
    bash
    
    `sudo journalctl -u kibana -f`
    
- Test Elasticsearch:
    
    bash
    
    `curl -k -u elastic:<PASSWORD> https://localhost:9200`
    
- Test Kibana:
    
    
    ```bash
    curl http://localhost:5601/status
    ```
    

Check configuration files if services fail to start:

- `/etc/elasticsearch/elasticsearch.yml`
    
- `/etc/kibana/kibana.yml`
    

## 14. Lab attack commands (examples)

These are the main tools and commands used in the lab to generate security events.

## Nmap scan

```bash
nmap <target-ip>
```

## SQL injection with sqlmap

```bash
sqlmap -u "http://<target-ip>/api/products/1*"
```

## RDP brute force with hydra

```bash
hydra -L username.txt -P passwords.txt -vV rdp://<target-ip>
```


> Use these commands only in a controlled lab against systems you own or are authorized to test.

---
