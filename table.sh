#/bin/bash

dir=~/Tools/AutoPen/elephant.com

scans=$dir/recon/scans
        number=$(find $scans -maxdepth 1 -not -type d | grep -v ^d | wc -l)
httprobe=$dir/recon/httprobe
        number1=$(find $httprobe -maxdepth 1 -not -type d | grep -v ^d | wc -l)
takeo=$dir/recon/potential_takeovers
        number2=$(find $takeo -maxdepth 1 -not -type d | grep -v ^d | wc -l)
wayback=$dir/recon/wayback
        number3=$(find $wayback -maxdepth 1 -not -type d | grep -v ^d | wc -l)
dnsrecon=$dir/recon/dnsrecon
        number4=$(find $dnsrecon -maxdepth 3 -not -type d | grep -v ^d | wc -l)
whatweb=$dir/enumeration/whatweb
        number5=$(find $whatweb -maxdepth 1 -not -type d | grep -v ^d | wc -l)
nikto=$dir/enumeration/nikto
        number6=$(find $nikto -maxdepth 1 -not -type d | grep -v ^d | wc -l)
nuclei=$dir/enumeration/nuclei
        number7=$(find $nuclei -maxdepth 1 -not -type d | grep -v ^d | wc -l)
wbparams=$dir/recon/wayback/params
        number8=$(find $wbparams -maxdepth 1 -not -type d | grep -v ^d | wc -l)
wbext=$dir/recon/wayback/extensions
        number9=$(find $wbext -maxdepth 1 -not -type d | grep -v ^d | wc -l)

seperator=--------------------
seperator=$seperator$seperator
#rows="%-15s| %-7s| %c\n"
rows="%-15s| %5d \n"
TableWidth=37

printf "%-15s| %-7s %s\n" Directory Files
printf "%.${TableWidth}s\n" "$seperator"
printf "$rows" "$scans " $number
printf "$rows" "$httprobe " $number1
printf "$rows" "$takeo " $number2
printf "$rows" "$wayback " $number3
printf "$rows" "$dnsrecon " $number4
printf "$rows" "$whatweb " $number5
printf "$rows" "$nikto " $number6
printf "$rows" "$nuclei " $number7
printf "$rows" "$wbparams " $number8
printf "$rows" "$wbext " $number9
