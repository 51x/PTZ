#!/usr/bin/python2.7

with open('2_ports_and_service_top1000_on_alive_hosts.out') as f:
    curip=""
    for curline in f:
        if "Nmap scan report for " in curline:
            curip=curline
            curip=curip[21:]
        if "open" in curline:
            print curip.strip('\n') + " " + curline.strip('\n')
