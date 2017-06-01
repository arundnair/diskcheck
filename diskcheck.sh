#!/bin/bash
#script by Arun D
#Running SmartCtl, HdParm and DD commands to check the disks
# Requires a CentOS installed server.


#To check if logged in user is root

if [ $(id -u) -ne 0 ]; then
	echo "Run this script as a Root user only" >&2
	exit 1
else	
	echo "Root user logged in"
fi

#Check if smartmontools is installed

rpm -q smartmontools
exit_status=$?
if [ $exit_status -gt 0 ];then
        echo "Installing Smartmontools"
        yum -y install smartmontools
else
        echo "SmartMontools already installed."
fi

echo "Initiating SmartCtl check"

for i in `lsblk | grep -i disk | awk '{print $1}'`
do
    echo "======/dev/$i========="
	smartctl -a /dev/$i|grep -E -A 1 'Device Model'
	smartctl -t long /dev/$i | grep "minutes" | echo "Test for /dev/$i will be completed in `awk '{print $3}'` minutes";
done

disk_status=100
while [ $disk_status -gt 0 ]
do
        for i in `lsblk | grep -i disk | awk '{print $1}'`
        do
                while [ `smartctl -c /dev/$i |grep "Self-test execution status:"| awk '{print $5}'|sed 's/.$//'` -ge 0 ]
                        do
                        if [ `smartctl -c /dev/$i |grep "Self-test execution status:"| awk '{print $5}'|sed 's/.$//'` -eq 0 ];then
                                echo "Smartctl test completed for /dev/$i"
                                disk_status=0
								break;
                        fi
						if [ `smartctl -c /dev/$i |grep "Self-test execution status:"| awk '{print $5}'|sed 's/.$//'` -gt 0 ];then
                                echo "`smartctl -a /dev/$i|grep  -A 1 'Self-test execution status:' | awk 'FNR==2{print $1}'` remaining for /dev/$i"
                                disk_status=100
                         fi
                done
        done
sleep 2;
echo $disk_status
done


/**** To complete ***//


#hdparm --direct -Tt /dev/sda | grep ' disk reads'| awk '{printf "%7s %7s\n",$11,$12}'; done




	

	

	
