#! /bin/bash

# To check your $GOPATH, enter "go env" into terminal.
# Script taken from Heath Adams PNPT

figlet AutoPen v.1

# Creating a spinner to notify that task is still running
spinner()
{
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Adding color to output
set +x
#}
function red(){
    echo -e "\x1B[31m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[31m $($2) \x1B[0m"
    fi
}
function blue(){
    echo -e "\x1B[34m $1 \x1B[0m"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[34m $($2) \x1B[0m"
    fi
}
function purple(){
    echo -e "\x1B[35m $1 \x1B[0m \c"
    if [ ! -z "${2}" ]; then
    echo -e "\x1B[35m $($2) \x1B[0m"
    fi
}


red "Enter Domain in format: domain.com. Do not place www before."

read -p "Enter Domain: " url

if [ ! -d "$url" ];then
	mkdir $url
fi
if [ ! -d "$url/recon" ];then
	mkdir $url/recon
fi
if [ ! -d "$url/enumeration" ];then
	mkdir $url/enumeration
fi
if [ ! -d '$url/recon/gowitness' ];then
  	mkdir $url/recon/gowitness
fi
if [ ! -d "$url/recon/scans" ];then
	mkdir $url/recon/scans
fi
if [ ! -d "$url/recon/httprobe" ];then
	mkdir $url/recon/httprobe
fi
if [ ! -d "$url/recon/potential_takeovers" ];then
	mkdir $url/recon/potential_takeovers
fi
if [ ! -d "$url/recon/wayback" ];then
	mkdir $url/recon/wayback
fi
if [ ! -d "$url/recon/dnsrecon" ];then
	mkdir $url/recon/dnsrecon
fi
if [ ! -d "$url/enumeration/whatweb" ];then
	mkdir $url/enumeration/whatweb
fi
if [ ! -d "$url/enumeration/nikto" ];then
	mkdir $url/enumeration/nikto
fi
if [ ! -d "$url/enumeration/nuclei" ];then
	mkdir $url/enumeration/nuclei
fi
if [ ! -d "$url/recon/wayback/params" ];then
	mkdir $url/recon/wayback/params
fi
if [ ! -d "$url/recon/wayback/extensions" ];then
	mkdir $url/recon/wayback/extensions
fi
if [ ! -f "$url/recon/httprobe/alive.txt" ];then
	touch $url/recon/httprobe/alive.txt
fi
if [ ! -f "$url/recon/final.txt" ];then
	touch $url/recon/final.txt
fi

echo

blue "[+] Directory structure has been created!"

echo
echo "Lets get to work..."
echo
 
purple "[+] Harvesting subdomains with assetfinder..."
(assetfinder $url >> $url/recon/final.txt) &
spinner $!
printf "\n"
 
purple "[+] Double checking for subdomains with amass..."
(amass enum -d $url >> $url/recon/f.txt
sort -u $url/recon/f.txt >> $url/recon/final.txt
rm $url/recon/f.txt) &
spinner $!
printf "\n"
 
purple "[+] Probing for alive domains..."
(cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt) &
spinner $!
printf "\n"

purple "[+] Checking for possible subdomain takeover..."
 
if [ ! -f "$url/recon/potential_takeovers/potential_takeovers.txt" ];then
	touch $url/recon/potential_takeovers/potential_takeovers.txt
fi
 
subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c /usr/share/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt
 
purple "[+] Scanning for open ports..."
(nmap -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned.txt) &
spinner $!
printf "\n"

purple "[+] Scraping wayback data..."
(cat $url/recon/final.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
sort -u $url/recon/wayback/wayback_output.txt) &
spinner $!
printf "\n"

purple "[+] Pulling and compiling all possible params found in wayback data..."
(cat $url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
for line in $(cat $url/recon/wayback/params/wayback_params.txt);do echo $line'=';done) &
spinner $!
printf "\n"

purple "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
(for line in $(cat $url/recon/wayback/wayback_output.txt);do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line >> $url/recon/wayback/extensions/js1.txt
		cat $url/recon/wayback/extensions/js1.txt | sort -u >> $url/recon/wayback/extensions/js.txt
	fi
	if [[ "$ext" == "html" ]];then
		echo $line >> $url/recon/wayback/extensions/jsp1.txt
		cat $url/recon/wayback/extensions/jsp1.txt | sort -u >> $url/recon/wayback/extensions/jsp.txt
	fi
	if [[ "$ext" == "json" ]];then
		echo $line >> $url/recon/wayback/extensions/json1.txt
		cat $url/recon/wayback/extensions/json1.txt | sort -u >> $url/recon/wayback/extensions/json.txt
	fi
	if [[ "$ext" == "php" ]];then
		echo $line >> $url/recon/wayback/extensions/php1.txt
		cat $url/recon/wayback/extensions/php1.txt | sort -u >> $url/recon/wayback/extensions/php.txt
	fi
	if [[ "$ext" == "aspx" ]];then
		echo $line >> $url/recon/wayback/extensions/aspx1.txt
		cat $url/recon/wayback/extensions/aspx1.txt | sort -u >> $url/recon/wayback/extensions/aspx.txt
	fi
done
 
rm $url/recon/wayback/extensions/js1.txt
rm $url/recon/wayback/extensions/jsp1.txt
rm $url/recon/wayback/extensions/json1.txt
rm $url/recon/wayback/extensions/php1.txt
rm $url/recon/wayback/extensions/aspx1.txt) &
spinner $!
printf "\n"

purple "[+] Running dnsrecon w/ zonewalk, crt and axfr..."
(dnsrecon -d $url -t zonewalk,crt,axfr > $url/recon/dnsrecon/dnsrecon.txt) &
spinner $!
printf "\n"

purple "[+] Running whatweb..."
(whatweb www.$url > $url/enumeration/whatweb/whatweb.txt

cat relax 
echo
echo) &
spinner $!
printf "\n"

purple "[+] Running nikto..."
(nikto -h www.$url > $url/enumeration/nikto/nikto.txt) &
spinner $!
printf "\n"

purple "[+] Running nuclei..."
(nuclei -l $url/recon/httprobe/alive.txt > $url/enumeration/nuclei/n.txt
cat $url/enumeration/nuclei/n.txt | sort > $url/enumeration/nuclei/nuclei.txt
rm $url/enumeration/nuclei/n.txt) &
spinner $!
printf "\n"

purple "[+] Running gowitness against all compiled domains..."
(gowitness file -f $url/recon/httprobe/alive.txt -P $url/recon/gowitness --delay 3) &
spinner $!
printf "\n"

# Function to print Directories and Files created to a table
blue "[+] Here are the locations and number of files created...Happy Hacking!" echo
print_row() {
  local name="$1" path="$2" 
  local count=$(find "$path" -maxdepth 1 -not -type d | grep -v ^d | wc -l)
  printf "%-30s| %5d\n" "$name" "$count"
}

seperator=$(printf '%.s-' {1..30})
printf "%-30s| %s\n" "Directory" "Files"
printf "%-30s|%s\n" "$seperator" "$seperator"

print_row "/recon/scans" "$url/recon/scans"
print_row "/recon/httprobe" "$url/recon/httprobe"
print_row "/recon/potential_takeovers" "$url/recon/potential_takeovers"
print_row "/recon/wayback" "$url/recon/wayback"
print_row "/recon/dnsrecon" "$url/recon/dnsrecon"
print_row "/enumeration/whatweb" "$url/enumeration/whatweb"
print_row "/enumeration/nikto" "$url/enumeration/nikto"
print_row "/enumeration/nuclei" "$url/enumeration/nuclei"
print_row "/recon/wayback/params" "$url/recon/wayback/params"
print_row "/recon/wayback/extensions" "$url/recon/wayback/extensions"

red "Would you like to browse gowitness images and launch server? (yes or no) "
read yesorno

if [ "$yesorno" == yes ]; then
        #firefox file:///$(pwd)/$url/recon/gowitness
	eog $url/recon/gowitness
	gowitness server -a localhost:4040

elif [ "$yesorno" == no ]; then
        exit 1

else
        red "Not a valid answer."
        exit 1

fi


