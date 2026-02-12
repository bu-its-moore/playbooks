ESSENTIALSERVICES="postgres|listen|pmon|ora_|commvault|appworx|cbagent|apache|pmon|banner|banjob|autofs|gcstartup|httpd|oracle|jenkins|mysqld|appworx|badm|banjob|cbagent|commvault|oni|rabbit|tomcat"
echo -e "### Services \n" >  /var/log/before_reboot_services.log;
systemctl --type=service --state=enabled,running,active --no-pager | awk '{
for (i = 1; i <= NF; i++) {
   printf "%s ", $i
   if ($i ~ /^(running)$/) {
       break
   }
}
print ""
}' | grep -E "${ESSENTIALSERVICES}" | grep "running" | awk '{print "- " $0 }' | uniq | sort >> /var/log/before_reboot_services.log;
echo -e "### Volumes \n" >  /var/log/before_reboot_volumes.log;
df -h | grep -v -E 'tmpfs|cgroup' | awk '{if (NR!=1) {print "- " $1 " => " $NF }}'| uniq | sort  >>  /var/log/before_reboot_volumes.log;
echo -e "\n#### Essential Databases and Apps\n" >  /var/log/before_reboot_apps.log;
ps h -o user,cgroup,egroup,sgroup,cmd,priority -N -u root,gdm | awk '{print "- "$1": "$5}'| grep -E "$ESSENTIALSERVICES" | uniq | sort >>  /var/log/before_reboot_apps.log;