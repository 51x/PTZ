#!/bin/zsh
# Agro scanner standalone
# License: GNU GPL v3, see LICENSE file
# Creation date: 2017.01.10. 21:30
# Dependencies: apt update && apt install zsh nmap python2.7 libxml2-utils -y
# Dependencies for offensive part: apt install theharvester nmap fierce dnsrecon dnsutils hydra dirb sqlmap wget dirb curl nikto libxml2-utils whatweb 
# Requires root, sry.

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



# Offensive part
echo "Usage $0 domain.com [tor] [user wordlist] [password wordlist] [nessusURL:port] [nessususer] [nessuspassword]" 

#echo "Updating searchsploit" 
#searchsploit -u 

# TODO parse arguments correctly 
echo "[DEBUG] number of arguments $#" 


# torify everything on demand 
if [ $2 == "tor" ]; then echo "TOR mode ON" && torrequested=true; fi 


# VARIABLES 
currentdir=$(pwd)
# hydra protocol not bruted by nmap 
hydrabruteprotocol=(cvs firebird icq irc ldap nntp oracle-listener oracle-sid pcanywhere pcnfs postgres rdp redis rtsp ssh sip teamspeak vmauthd)
#TODO provides usernames password in args 
usernames="/usr/share/nmap/nselib/data/usernames.lst"
passwords="/usr/share/nmap/nselib/data/passwords.lst"
# Nessus 
nessusapi=$5
nessususer=$6
nessuspass=$7 


# TODO low priority optimize tools location if not in Kali OS 
# nmap =  which nmap 
# fierce = which fierce ... 


if [ $# -eq 0 ]; then echo "please provide something to pentest you dumb bear (ᵔᴥᵔ) ! :D" ; exit ; fi 

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root for Nmap scripting and syn scan." 1>&2
   exit 1
fi

# Attacked domain 
domainattacked=$1;
echo "Domain attacked is : $domainattacked !" 


# START RECON PART 

# Enum domain with std wordlist 
echo "Enumerating domains "; 
fierce -dns $1 -wide -file targets.fierce 
# Dnsreconing 
dnsrecon -d $domainattacked -t std,brt,srv,axfr,goo --iw -a -s -c $currentdir/targets.dnsrecon 
echo "Enumerating domains ... DONE";
# Robtex graph 
echo "Getting graph of the domain infrastructure"
wget -qO $domainattacked.png "https://gfx.robtex.com/gfx/graph.png?dns=$domainattacked"
# getting a traceroute for network device mapping 
traceroute $domainattacked > $domainattacked.traceroute
tcptraceroute $domainattacked 80  >> $domainattacked.traceroute
tcptraceroute $domainattacked 25  >> $domainattacked.traceroute


# extract IPs 
cat targets.dnsrecon | grep -v 'hostnames found' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u  > ips.lst; 
echo "IPs extracted ! Ready to shoot." 
#extract IP ranges 
cat targets.fierce  | grep 'hostnames found'  | grep -E -o "([0-9]{1,3}[\.-]){4}[0-9]{1,3}" | sort -u > ipranges.lst
echo "IPs ranges extracted as well. If you want to extend scan."; 

# LEGACY add dig ANY targets , NS , SRV , ...  done by dnsrecon now 
# dig +recurse +authority $domainattacked ANY | grep -v 'SERVER' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u >> ips.lst; 


# TODO extend IP detection with 
# rwhois ? SPF IP ? 


# TODO building custom userlist with harvester, add vhost and add ips ? 
echo "Harvesting info about domain $domainattacked"  
#theharvester -d $domainattacked -b all -v > $domainattacked.harvester 
#grep IP inside .harvester 

# EXTENDING if requested  extend scan to ip ranges 
# nmap -sL >> ips.lst 

# CLEANING before starting if IPs added with other scripts 
# cat ips.lst | sort -u > finalips.lst 


# START SERVICES PART  

# SERVICES ENUM FINGERPRINT + NSE VULN PART 
# main loop for IP 
for x in `cat ips.lst`; do 



# create a dir per IP for db txt files 
 mkdir $x;
 echo "Enumerating ports and services, vuln scanning and brute forcing ... jeez thats alota work"; 

# full scan 
# echo "Full nmap scan start" 
# nmap -sSU -p T:1-65535,U:7,9,11,13,17,19,20,37,39,42,49,52-54,65-71,81,111,161,123,136-170,514-518,630,631,636-640,650,653,921,1023-1030,1900,2048-2050,27900,27960,32767-32780,32831 -sV --script="(default or vuln or auth or brute or discovery) and not (broadcast or dos)" --script-args="unsafe=1,userdb=$usernames,passwd=$passwords" --host-timeout=180m --max-hostgroup=1 -Pn -v $x -oA $x/nmapresults
# reduced scan for TESTING 
 echo "[DEBUG] TEST MODE for nmap sS top1k ONLY"  
 nmap -sS -sV --script="(default or vuln or auth or brute or discovery) and not (broadcast or dos)" --host-timeout=30m --max-hostgroup=1 -Pn $x -oA $x/nmapresults
 echo "Nmap fingerprinting and NSE for $x... DONE"; 

# TODO 

 echo "[UNDER CONSTRUCTION] Nessus API Scan"; 
 echo "Starting the Nessus scan ..." 
 token=`curl -k -X POST -H 'Content-Type: application/json' -d '{"username":"$nessususer","password":"$nessuspassword"}' "https://$nessusurl/session"`
 
# echo "Adding targets to FULL scan" 
#+ call nessus  api  
# get results in the end 


# TODO service / version detection for smarter brute force and searchsploit  
 # echo "[UNDER CONSTRUCTION] Smart protocol detection for hydra ..." 
 # cat nmapresults.xml | grep "port protocol" | cut -d '"' -f12


#getting nmap CPE version of services and using Searchsploit  
# REPORT services version and cleaning the file 
 echo -n "" > $x/version.services
 for z in `cat $x/nmapresults.xml | grep '<cpe>'`; do echo $z | grep -ozP "(?s)<cpe>.*?(?=</cpe>)" >> $x/version.services && echo "" >> $x/version.services; done

# REPORT exploitdb search from nmap 
 echo "Searching interesting vulnerabilities for target $x" 
 #legacy searchsploit for a in $(cat $x/version.services); do echo $a | cut -d : -f3-5 | tr ":" " "  | cut -d '.' -f1 >> $x/version.exploits; done
 searchsploit -v --nmap $x/nmapresults.xml > $x/version.exploits; 

# TODO ADD  default credentials 


#### Brute force non nmap 
# TODO optimtize per port 
 echo "STARTING additional BRUTE FORCE PART with hydra"; 
 echo "[DEBUG] not bruting for faster testing"; 
 for b in ${hydrabruteprotocol[@]}; do hydra -L $usernames -P $passwords -o $x/validuserpass.hydra $b://$x; done; 
 echo "FINISHED additional hydra BRUTE FORCE"; 


 echo "Enumerating ports and services, fingerprinting, vuln scanning and brute forcing .... DONE "; 


##################### STOP SERVICES PART 


###################### START WEB PART 
#### WEB VULNS PART 
 echo "Web pentesting now ..."; 
# vhost enum 
 echo "Vhost enum" 
# adding the IP as vhost , often forgotten  
 echo "$x" >> $x/vhost.list; 
# manual reverse PTR in case there is none 
 cat targets.dnsrecon | grep $x | grep '^A' | cut -d ',' -f2 >> $x/vhost.list;  
# reverse PTR  
 dig +short -x $x >> $x/vhost.list;
# using robtex from nmap 
 awk '/hostmap-robtex/{f=1;next} /ip-geolocation-geoplugin/{f=0} f' $x/nmapresults.nmap >> $x/vhost.list; # extract vhosts from NMAP robtex script 
# adding hackertarget  vhost 
 timeout 2m curl "http://api.hackertarget.com/reverseiplookup/?q=$x" >> vhost.list;
# TO DO add harvester ? 
# sorting vhosts  
 sort -u $x/vhost.list > $x/vhost.sorted; 
 
echo "Start port loop for $x" 

# if HTTP port test 
 for y in `cat $x/nmapresults.nmap |  grep '/tcp' | grep ' http ' | cut -d '/' -f1`; 
    ### WEB RECON   
  do echo "start vhost loop for IP $y"; 
  for z in `cat $x/vhost.sorted`; 
    # dirb  for each vhost 
   do dirb "http://$z:$y" -f -l > "$x/enum$z.dirb"; 
    ### WEB fingerprint 
   whatweb -v "http://$z:$y"; 
    # nikto  for each vhost 
   nikto -host "http://$z:$y" > "$x/$z.nikto"; 

    # arachni 
    # arachni 

    # sqlmap for earch vhost 
   #sqlmap --crawl=2 --forms --batch  

    done;  ## end vhost loop 
  done;  ## end nmap port loop 


# if HTTPS port 
# TO DO again 
# copy pasta 
#  for y in `cat $x/nmapresults.nmap |  grep '/tcp' | grep 'ssl/http' | cut -d '/' -f1`; 

done; ## end IP loop 


# REPORT VULNS FOUND  
echo "======================================"
echo "Vulnerability summary from NSE Scripts"
echo ""
grep -i "vulner" -B1 */nmapresults.nmap 
echo "You might also need to read manually also the .nmap as vulnerable state is not harmonized through NSE" 
echo ""

echo "======================================"
echo "ExploitDB research results"
echo ""
echo "Interesting exploits found: " 
cat */version.exploits
echo ""

echo "======================================"
echo "Bruteforce results"
echo ""
echo "Valid passwords found: " 
cat */validuserpass.hydra      
echo ""
