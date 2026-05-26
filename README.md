# Mini SOC with ELK Stack

This project documents the implementation of a small Security Operations Center (SOC) lab built with the ELK Stack to monitor, analyze, and detect security events in a controlled environment.[1]

## Overview

The project investigates how a smaller SOC environment based on Elasticsearch, Logstash, and Kibana can be used to detect and analyze common attack activity in a lab setting. The implementation also uses Fleet Server and Elastic Agent to centrally manage endpoints and collect logs from the environment.[1]

## Purpose

The purpose of the project was to examine how well a mini SOC built on the ELK Stack could detect Nmap scans, brute force attacks, and web-based attacks in a lab environment.[1]

## Lab Environment

The lab environment consisted of an attacker machine, an ELK server running Ubuntu Server 24.04, and Linux and Windows victim machines. Elasticsearch, Kibana, Logstash, Fleet Server, and Elastic Agent were installed and configured to collect, centralize, and visualize security-related events.[1]

## Tools and Components

- Elasticsearch for storing and searching log data.[1]
- Logstash for handling and processing data flows.[1]
- Kibana for visualization and analysis in a graphical interface.[1]
- Fleet Server and Elastic Agent for centralized endpoint management and log collection.[1]
- System integration and Elastic Defend for endpoint telemetry and security monitoring.[1]

## Attack Scenarios

The project tested three types of attack activity in the lab:[1]

- Nmap scanning.[1]
- RDP brute force attempts.[1]
- Web-based attacks using SQL injection techniques.[1]

## Results

The environment was able to collect, store, and visualize security events related to multiple attack types in the lab. Nmap scanning was identified through repeated network-related events over a short period, brute force behavior was observed through repeated failed login attempts, and web-based attack activity was detected through traffic analysis and a custom Elastic Security query rule.[1]

## Discussion

The results indicate that the configured mini SOC can serve as a practical foundation for simpler security monitoring and analysis. At the same time, detection capability depends heavily on correct installation, relevant data sources, and well-configured rules and integrations.[1]

A key strength of the solution is centralized log management and visualization in Kibana, which supports analysis of network events and authentication attempts. A limitation is that the project was performed in a small lab environment and only covered a limited number of attack types, so the results cannot be directly generalized to larger production environments.[1]

## Conclusion

The project shows that it is possible to build a smaller SOC environment with the ELK Stack and use it to monitor and analyze security events in a lab setting. The work demonstrates that a mini SOC can be a useful educational and practical approach for understanding basic security monitoring and incident handling.[1]

## Scope Limitations

The work is limited to a small lab environment and focuses on a restricted set of tools and attack types. It does not cover full-scale production deployment, advanced attack chains, or a broader range of threats.

## Notes

This repository is intended for educational and lab use. Any deployment outside a controlled environment would require additional hardening, validation, and environment-specific adjustments.[1]

