Penetration Tester's Zsh
========================

Goal: make penetration testing faster, more convinient, transparent and efficient.

Features planned: preconfigured functions (including tools), note knowledge base with practical examples, automated "dumb" pentesting.

Usability features: tor trigger (ton/tof), external ip check, tor check... and more to be added.

Note: this project is a work in progress which we develop with one of my friend in our free time. If you use it, be prepared for some glitches.

Works on Debian if the dependencies are met or on Kali. Probably works on Pentoo also.

Installing full console after you have the dependencies: cp profile_files/.* -R ~/

Using only the pentest function can be done be including: pentest_functions.zsh 


Functions
=========

pawnpls   - Automatically enumerate and start predefined attacks such as brute force.
            Example for single target: autopawn n0nexi-stent.com
            Example for multiple targets: autopawn "n0nex-1.com n0nex-2.com"


everythingworksornot\? - check if everything works or not for this script (tbd)


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


help functions
==============

hlp       - Get help of the hlp command
hlprnd    - Get random strings (lengths: 8,16,32,64)
