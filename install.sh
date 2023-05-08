#! /bin/bash

#Install extras
sudo apt install figlet
sudo apt install libtext-asciitable-perl
sudo apt install wpscan

# Install Go tools required for functions.
# To check your $GOPATH, enter "go env" into terminal.

blue "[+] Installing gowitness..."
go install github.com/sensepost/gowitness@latest
blue "[+] Installing httprobe..."
go install github.com/tomnomnom/httprobe@latest
blue "[+] Installing assetfinder..."
go install github.com/tomnomnom/assetfinder@latest
blue "[+] Installing amass..."
go install github.com/OWASP/Amass/v3/...@latest
blue "[+] Installing subjack..."
go install github.com/haccer/subjack@latest

blue "[+] Installing CMSmap..."
sudo git clone github.com/dionach/CMSmap.git
cd CMSmap
sudo pip3 install .

# Move Go path to user path
sudo cp -r /home/$USER/go/bin/* /usr/sbin
