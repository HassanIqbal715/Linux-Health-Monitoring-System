red='\033[0;31m'
yellow='\033[0;33m'
green='\033[0;32m'
blue='\033[0;36m'
white='\033[0m'

echo -e "------------------------------------------------------------------------------------------------------"
echo -e "                                  Welcome to System Health Check Monitor"
echo -e "------------------------------------------------------------------------------------------------------"

echo -e "------------------------------------------------------------------------------------------------------"
echo -e "                                      Basic User and System Details"
echo -e "------------------------------------------------------------------------------------------------------"

echo -e "User name: $(whoami)"
echo -e "Host name: $(hostname)"
echo -e "IP Address: ${yellow}$(hostname -I)${white}\n"

echo -e "Operating system: $(printenv DESKTOP_SESSION)"
echo -e "System Language: ${blue}$(printenv LANG)${white}"
echo -e "Date and Time:${green}"  $(date +"%A, %B %d, %Y %I:%M %p")${white}
echo -e "System Uptime: ${green}$(uptime -p)${white}\n"

echo -e "-----------------------------------------------------------------------------------------------------"
echo -e "                                                Hardware"
echo -e "-----------------------------------------------------------------------------------------------------"

echo -e "System:$(sudo lshw -C 'System' | grep 'product' | cut -d ':' -f2) ${white}\n"

echo -e "Processor: $(lscpu | grep 'Model name' | cut -d ':' -f2 | xargs) ${white}\n"

echo -e "CPU Architecture:${green} $(lscpu | grep -i 'architecture' | cut -d ':' -f2 | xargs) ${white}\n"

echo -e "Memory size:${yellow} $(sudo lshw -C 'memory' | grep -i 'gib' | cut -d ':' -f2 | xargs) ${white}\n"

echo -e "Graphics adapter: $(lspci | grep -i 'vga' | cut -d ':' -f3 | xargs) (${yellow}$(lspci -v -s 00:02.0 | 
	grep -i 'memory' -m 1 | cut -d '=' -f2 | cut -d ']' -f1)${white})\n"

echo -e "Ethernet adapter: $(lspci | grep -i 'ethernet' | cut -d ':' -f3 | xargs)\n"

echo -e "Batteries: "
echo -e "\t$(acpi | cut -d '%' -f1)%\n"

echo -e "Disks: "
echo -e "$(sudo lshw | grep -i 'disk')\n"

echo -e "----------------------------------------------------------------------------------------------------"
echo -e "                                            Current status"
echo -e "----------------------------------------------------------------------------------------------------"
echo -e "Disk Space usage: "
df -h
echo -e "\nTop 5 cpu consuming processes: "
ps -eo pid,comm,user,%cpu, --sort=-%cpu | head -n 6
echo -e "\nTop 5 memory consuming processes: "
ps -eo pid,comm,user,%mem --sort=-%mem | head -n 6
echo -e "\nMemory details:"
free -h
echo -e "\nPing: ${green}"
ping -c 4 www.google.com
echo -e "\n${white}Network details:"
ifconfig | grep -E 'inet | eth|wlan'
echo -e '\n'

echo -e "----------------------------------------------------------------------------------------------------"
echo -e "                                          Final Analysis"
echo -e "----------------------------------------------------------------------------------------------------"

counter=0

memory_usage=$(free -h | grep -i "Mem" | awk '{print $3+0}')
available_memory=$(free -h | grep -i "Mem" | awk '{print $2+0}')
ratio_mem=$(echo "$memory_usage / $available_memory" | bc -l)

charging=$(acpi | grep -i 'Battery 0' | cut -d ',' -f2 | cut -d '%' -f1)

Pong=$(ping -c 1 www.google.com | grep -i 'time' -m 1| cut -d '=' -f4 | awk '{print $1+0}')

ratio_disk=$( df -h | grep -i 'sda' | awk '{print $5+0}')

echo -n "Memory Test: "
if (( $(echo "$ratio_mem < 0.7" | bc -l) )); then
	echo -e "${green} PASS"
	((counter++))
else 
	echo -e "${red} FAIL"
fi

echo -n -e "${white}Charging Test:"
if (( $(echo "$charging > 20" | bc -l) )); then
	echo -e "${green} PASS"
	((counter++))
else 
	echo -e "${red} FAIL"
fi


echo -n -e "${white}Ping Test: "
if (( $(echo "$Pong < 100" | bc -l) )); then
	echo -e "${green} PASS"
	((counter++))
else
	echo -e "${red} FAIL"
fi

echo -n -e "${white}Disk Test: "
if (( $(echo "$ratio_disk < 70" | bc -l) )); then
	echo -e "${green} PASS"
	((counter++))
else
	echo -e "${red} FAIL"
fi

echo -n -e "\n${white}Verdict: "
if (( $(echo "$counter > 2" | bc -l) )); then
	echo -e "Your system seems to be doing well! have an apple"
	echo -e "(\\_(\\"
	echo -e "( ^ ^)"
	echo -e "(> 🍎"
else 
	echo -e "Your system needs some care... :("
fi
