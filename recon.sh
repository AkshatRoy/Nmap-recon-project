#! /usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

correct_ip="n"
while [ "$correct_ip" == "n" ]; do
    read -p "Please enter IP Address: " ip_add
    echo "IP Address entered: $ip_add"
    
    read -p "Please confirm if it is correct (y/n): " correct_ip

    while [ "$correct_ip" != "y" ] && [ "$correct_ip" != "n" ]; do
        read -p "Please enter y/n: " correct_ip
    done
done


report_file="nmap_recon_report.txt"
current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

echo -e "Traget IP: $ip_add | $current_datetime \n" 

echo -e "======= Conducting Intital Scan ======= \n" 

echo -e "Traget IP: $ip_add | $current_datetime \n" > "$report_file" 


# HOST STATUS 

host_status=$(nmap -sn $ip_add -Pn | awk '/Host is/{print$3}' )

if [ "$host_status" == "up." ]; then
    echo -e "Host Status : Up \n" >> "$report_file"
    echo -e "Host Status : ${GREEN}UP${NC}" 
elif [ "$host_status" == "down."];then 
    echo -e "Host Status : Down\n" >> "$report_file"
    echo -e "Host Status : ${RED}Down ${NC}"
else
    echo -e "Host Status : Un-determined \n" >> "$report_file"
    echo -e "Host Status : ${YELLOW}Un-detrmined${NC}"
fi


# PORT SCANNING

open_ports=$(nmap "$ip_add" -Pn -sV | awk '/PORT/,/^$|Not shown/{print} /SF/ {exit}' )
echo -e "=== Port Scanning === \n$open_ports" >> "$report_file"
echo -e "\n$open_ports" 



# OS DETERMINING


echo -e "\n======= OS Determination ======= \n" 

os_detect=$(sudo nmap -O "$ip_add" -Pn | awk '/Warning:/{flag=1; next} flag && NF{print} !NF{exit}')
echo "$os_detect"
echo -e "\n=== OS DETECTION === \n$os_detect" >>  "$report_file"



# FIREWALL DETECTION 

echo -e "\n======= Firewall Detection =======\n" 

firewall_detect=$(sudo nmap -sA $ip_add -Pn | awk '/Host is up/{flag=1; next} flag && NF{print} !NF{exit}')
echo "$firewall_detect"
echo -e "\n=== Firewall Detection === \n$firewall_detect" >> "$report_file"


# VULNERABILITY SCAN

echo -e "\n======= Vulnerability Scan =======\n"

vuln_scan=$(sudo nmap --script vuln,discovery $ip_add)
echo "$vuln_scan"
echo -e "\n=== Vulnerability Scan === \n$vuln_scan" >> "$report_file"




echo -e "\n${GREEN}Report saved${NC}"
  
