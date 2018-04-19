Penetration Tester's Zsh
========================

Goal: make the life of a hacker / penetration tester faster, more convinient, transparent and efficient.

Usability features: tor trigger (ton/tof), external ip check, tor check... and more to be added.

Works on Debian if the dependencies are met or on Kali "out of box". If the dependencies are not met, the functions will still run, but outputs will be empty or you get an alert.


Install
=======

cd /tmp/ && git clone https://github.com/51x/PTZ && cd PTZ && cp profile_files/.* -R ~/ && cd

Using only the pentest functions can be done by including just: pentest_functions.zsh
If you want also the notes/knowledge database, you should add the v3das folder to you ~/.ptz/ folder.


General function of PTZ
=======================

pawnpls   - Automatically enumerate and start predefined attacks such as brute force. Output goes to ~/.ptz/$target/
            Example for single target: autopawn n0nexi-stent.com
            Example for multiple targets: autopawn "n0nex-1.com n0nex-2.com"


ptzdepchk - check if all dependencies are installed or not, print if something is missing


Notes functions
===============

n         - query notes about a topic, use tab auto complete

nls       - list all the notes

rnd       - get random strings (lengths: 8,16,32,64)

tmp       - open vim with a random file name to be written under /tmp/


chk functions
=============

chkhttpz  - HTTP response check
            Example: chkhttpz itsec.lu 443

chkcrt    - SSL certificate dump
            Example: chkcrt gentoo.org 443


cracking functions
==================

johnzip   - Crack zip files using john
            Example: johnzip data.zip rockyou.txt

johnrar   - Crack rar files using john
            Example: johnrar data.rar rockyou.txt
