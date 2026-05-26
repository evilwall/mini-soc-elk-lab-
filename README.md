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

