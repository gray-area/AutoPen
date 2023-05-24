#! /bin/bash

# To check your $GOPATH, enter "go env" into terminal.
# To add to script, place entry in dir creation, recon or enumerate function and table output

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

# Function to display the menu
show_menu() {
    echo "========= MENU ========="
    echo "1. Recon"
    echo "2. Enumerate"
    echo "3. YOLO (BOTH)"
    echo "4. Exit"
    echo "========================"
}

    if [ ! -d "$url" ];then
        mkdir $url
fi

# Function to run Recon
run_recon() {

# Recon Dir Creation

if [ ! -d "$url/recon" ];then
        mkdir $url/recon
fi
if [ ! -d "$url/recon/gowitness" ];then
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

blue "[+] Recon directory structure has been created!"

echo

echo "Running Recon..."
echo
purple "[+] Harvesting subdomains with AssetFinder..."
(assetfinder $url &> $url/recon/final.txt) &
spinner $!
printf "\n"
 
purple "[+] Double checking for subdomains with Amass..."
(amass enum -d $url &> $url/recon/f.txt
sort -u $url/recon/f.txt &> $url/recon/final.txt
rm $url/recon/f.txt) &
spinner $!
printf "\n"
 
purple "[+] Probing for alive domains..."
(cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' &> $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt &> $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt) &
spinner $!
printf "\n"

purple "[+] Checking for possible subdomain takeover..."
( 
if [ ! -f "$url/recon/potential_takeovers/potential_takeovers.txt" ];then
	touch $url/recon/potential_takeovers/potential_takeovers.txt
fi
 
subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c /usr/share/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt) &
spinner $!
printf "\n"
 
purple "[+] Scanning for open ports..."
(nmap -sV -Pn -n -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned &> scanned.txt) &
spinner $!
printf "\n"

purple "[+] Scraping wayback data..."
(cat $url/recon/final.txt | waybackurls &> $url/recon/wayback/wayback_output.txt | sort -u -o $url/recon/wayback/wayback_output.txt) &
spinner $!
printf "\n"

purple "[+] Pulling and compiling all possible params found in wayback data..."
(cat $url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u &> $url/recon/wayback/params/wayback_params.txt)
#for line in $(cat $url/recon/wayback/params/wayback_params.txt);do echo $line'=' ;done) &
spinner $!
printf "\n"

purple "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
(for line in $(cat $url/recon/wayback/wayback_output.txt);do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line &>> $url/recon/wayback/extensions/js1.txt
		cat $url/recon/wayback/extensions/js1.txt | sort -u &> $url/recon/wayback/extensions/js.txt
	fi
	if [[ "$ext" == "html" ]];then
		echo $line &>> $url/recon/wayback/extensions/jsp1.txt
		cat $url/recon/wayback/extensions/jsp1.txt | sort -u &> $url/recon/wayback/extensions/jsp.txt
	fi
	if [[ "$ext" == "json" ]];then
		echo $line &>> $url/recon/wayback/extensions/json1.txt
		cat $url/recon/wayback/extensions/json1.txt | sort -u &> $url/recon/wayback/extensions/json.txt
	fi
	if [[ "$ext" == "php" ]];then
		echo $line &>> $url/recon/wayback/extensions/php1.txt
		cat $url/recon/wayback/extensions/php1.txt | sort -u &> $url/recon/wayback/extensions/php.txt
	fi
	if [[ "$ext" == "aspx" ]];then
		echo $line &>> $url/recon/wayback/extensions/aspx1.txt
		cat $url/recon/wayback/extensions/aspx1.txt | sort -u &> $url/recon/wayback/extensions/aspx.txt
	fi
done
 
rm $url/recon/wayback/extensions/js1.txt
rm $url/recon/wayback/extensions/jsp1.txt
rm $url/recon/wayback/extensions/json1.txt
rm $url/recon/wayback/extensions/php1.txt
rm $url/recon/wayback/extensions/aspx1.txt) & 
spinner $!
printf "\n"

purple "[+] Running DNSRecon w/ zonewalk, crt and axfr..."
(dnsrecon -d $url -t zonewalk,crt,axfr &> $url/recon/dnsrecon/dnsrecon.txt) &
spinner $!
printf "\n"

purple "[+] Running GoWitness against all compiled domains..."
(gowitness file -f $url/recon/httprobe/alive.txt -P $url/recon/gowitness --delay 3 &> /dev/null) &
spinner $!
printf "\n"

    echo
	echo "Recon executed."
    echo
}

# END OF RECON FUNCTION
#
#
#

# Function to run Enumerate
run_enum() {
    echo "Running Enumerate..."
	echo
# Enumerate Dir Creation	

if [ ! -d "$url/enumeration" ];then
        mkdir $url/enumeration
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
if [ ! -d "$url/enumeration/wpscan" ];then
        mkdir $url/enumeration/wpscan
fi
if [ ! -d "$url/enumeration/searchsploit" ];then
        mkdir $url/enumeration/searchsploit
fi

echo
blue "[+] Enumeration directory structure has been created!"

purple "[+] Running WhatWeb..."
(whatweb www.$url &> $url/enumeration/whatweb/whatweb.txt

cat relax 
echo
echo) &
spinner $!
printf "\n"

purple "[+] Running Nikto..."
(nikto -h www.$url &> $url/enumeration/nikto/nikto.txt) &
spinner $!
printf "\n"

purple "[+] Running Nuclei..."
(nuclei -u https://www.$url &> $url/enumeration/nuclei/n.txt
cat $url/enumeration/nuclei/n.txt | sort &> $url/enumeration/nuclei/nuclei.txt
rm $url/enumeration/nuclei/n.txt) &
spinner $!
printf "\n"

purple "[+] Running WPScan..."
(grep wordpress-detect $url/enumeration/nuclei/nuclei.txt | grep -o 'https\?://[^ ]*' | sed '/$url/!d' | sort -u &> $url/enumeration/wpscan/wp_urls.txt
cat $url/enumeration/wpscan/wp_urls.txt | while true ; do read url; if [ "" = "$wpscanned" ] ; then break; fi ; wpscan --url $wpscanned -e -o $wpscanned_results.txt; done) &
spinner $!
printf "\n"

purple "[+] Running Searchsploit..."
(searchsploit --nmap $url/recon/scans/scanned.xml 2> /dev/null | tee $url/enumeration/searchsploit/sploits.txt) &
spinner $!
printf "\n"

    echo
	echo "Enumerate executed."
    echo


}

# END OF EUMERATE FUNCTION




# Main program loop
while true; do
    show_menu
    read -p "Enter your choice (1-4): " choice
    echo

    case $choice in
        1)
            echo
			echo "Lets get to work..."
			run_recon
			break
            ;;
        2)
            echo
			echo "Lets get to work..."
			run_enum
			break
            ;;
        3)
            echo
			echo "Lets get to work..."
			run_recon && run_enum
			break
            ;;
        4)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice. Please enter a number from 1 to 4."
            echo
            ;;
    esac
done

# Function to print Directories and Files created to a table
echo
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
print_row "/recon/wayback/params" "$url/recon/wayback/params"
print_row "/recon/wayback/extensions" "$url/recon/wayback/extensions"
print_row "/enumeration/whatweb" "$url/enumeration/whatweb"
print_row "/enumeration/nikto" "$url/enumeration/nikto"
print_row "/enumeration/nuclei" "$url/enumeration/nuclei"
print_row "/enumeration/wpscan" "$url/enumeration/wpscan"
print_row "/enumeration/searchsploit" "$url/enumeration/searchsploit"


echo
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

