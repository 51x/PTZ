#!/bin/zsh
# Agro scanner standalone
# License: GNU GPL v3, see LICENSE file
# Creation date: 2017.01.10. 21:30
# Dependencies: apt-get update && apt-get install zsh nmap python2.7 libxml2-utils -y

# Variables
targetx=(127.0.0.1)  # Space delimited!
ports=(21-23,25-26,53,80-81,110-111,113,135,139,143,179,199,443,445,465,514-515,548,554,587,646,993,995,1025-1027,1433,1720,1723,2000-2001,3306,3389,4443,5060,5666,5900,6001,8000,8008,8080,8443,8888,10000,32768,49152,49154,11211)

# Initialize directory and naming structure
cdate=$(date +"%Y-%m-%d")
mkdir -p result-$cdate
cd result-$cdate
touch scan_history.txt
echo "---- Starting AgroScanner ----" >> scan_history.txt

# Start with standard alive scan and check ports on alive hosts

# Get alive hosts
echo $(date +"%Y-%m-%d-%H-%M-%S") " Starting alive hosts scan." >> scan_history.txt
nmap --randomize-hosts -sn -PS$ports $targetx -oG 1_alive_hosts.out 
alive_hosts=$(grep "Status: Up" 1_alive_hosts.out | cut -d' ' -f2 | tr '\r\n' ' ')
echo $(date +"%Y-%m-%d-%H-%M-%S") " Finished alive hosts scan. Found hosts: " $alive_hosts >> scan_history.txt

# Port scanning on alive hosts and version detection
echo $(date +"%Y-%m-%d-%H-%M-%S") " Starting port scans on alive hosts with top 1000." >> scan_history.txt
nmap --randomize-hosts -sS -sV -n -Pn --top-ports 1000 $targetx > 2_ports_and_service_top1000_on_alive_hosts.out
python ../agro_detection_parser.py | sed -n '/ /s/ \+/ /gp' > 3_ip_port_service.out
number_open_tcp_ports=$(grep -v "Nmap scan report for" 3_ip_port_service.out |wc -l)  # It lists all ports, even unknown and faster to grep from here for this.
echo $(date +"%Y-%m-%d-%H-%M-%S") " Finished port scans on alive hosts with top 1000. Number of open ports: " $number_open_tcp_ports >> scan_history.txt

# Run UDP scan on most common ports
echo $(date +"%Y-%m-%d-%H-%M-%S") " Starting UDP scans." >> scan_history.txt
nmap -sU --top-ports 50 $targetx > 4_udpscan.out
number_open_udp_ports=$(grep "open" 4_udpscan.out |wc -l)
echo $(date +"%Y-%m-%d-%H-%M-%S") " Finished UDP scans. Number of open UDP ports: " $number_open_udp_ports >> scan_history.txt

# Vulnerability scanning
echo $(date +"%Y-%m-%d-%H-%M-%S") " Starting simple vulnerbility scans." >> scan_history.txt
nmap -n -p 21 --script=ftp-anon.nse $targetx > 5_nmap_script_ftpanon.txt
#nmap -sU -sS --script smb-enum-* -p U:137,T:139 $targetx > 6_nmap_sbm_nse_scan.txt  # There is issue with the * askterisk... should be escaped or something
nmap -sS -n -p $ports --script=default,safe,vuln $targetx > 7_nmap_script_default-safe-vuln_scan.txt
echo $(date +"%Y-%m-%d-%H-%M-%S") " Finished vulnerability scans. Lists are in the relevant txt files." >> scan_history.txt


