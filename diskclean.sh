#!/bin/bash


# this program find all zip file that modify over 3 days ago and delete it.

# This method is for saving the result of the program in message format.
function log_message () {
case $? in
        1)
                echo -e "$(date +"%a-%b-%d-%Y/%H:%M:%S") $(hostname) $(hostname -I) system coudn't remove $file " >> /home/barayeiran_diskclean_plan/diskclean.err
                ;;
        0)
                echo -e "$(date +"%a-%b-%d-%Y/%H:%M:%S") $(hostname) $(hostname -I) $file is removed successfuly" >> /home/barayeiran_diskclean_plan/diskclean.suc
                ;;
        *)
                echo "$(date +"%a-%b-%d-%Y/%H:%M:%S") $(hostname) $(hostname -I) The error message was not detected" >> /home/barayeiran_diskclean_plan/diskclean.err
                exit 5
                ;;
esac
}

# When the disk consumption reaches more than 80%, the deletion of extra files will start.

used=$(df -lh | egrep "/dev/sda3" | awk '{print $5}' | cut -f1 -d "%")

if [ $used -le 70 ]; then
        echo -e "$(date +"%a-%b-%d-%Y/%H:%M:%S") $(hostname) $(hostname -I) disk usage is: $used% and there was no need to run the diskclean program" >> /home/barayeiran_diskclean_plan/diskclean.suc
else
        echo -e "$(date +"%a-%b-%d-%Y/%H:%M:%S") $(hostname) $(hostname -I) disk is very full and disk usage is: $used% ; then diskclean is run" >> /home/barayeiran_diskclean_plan/diskclean.err
        my_find=$(find /home/barayeiran_backup -depth -iname "*.zip" -mtime +2 | sort)
        my_array=($my_find)
        for file in ${my_array[@]}
        do
                sudo rm -rvf $file || exit 1
                log_message $file $?
        done
	disk_space_reached=$(df -lh | egrep "/dev/sda3" | awk '{print $5}' | cut -f1 -d "%")
        echo -e "$(date +"%a-%b-%d-%Y/%H:%M:%S") $(hostname) $(hostname -I) The diskclean program was executed and the disk space reached: $disk_space_reached% " >> /home/barayeiran_diskclean_plan/diskclean.suc
fi

