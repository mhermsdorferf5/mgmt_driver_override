#!/bin/bash

mgmt_driver_override_service_file="W1VuaXRdDQpEZXNjcmlwdGlvbj0iT3ZlcnJpZGVzIG1nbXQgZHJpdmVyIGZvciBtbHg2IGNhcmRzIHRvIHVzZSBtbHg1X2NvcmUgZHJpdmVyLiINCkJlZm9yZT1uZXR3b3JrLnRhcmdldA0KV2FudHM9bG9jYWwtZnMudGFyZ2V0DQoNCltTZXJ2aWNlXQ0KVHlwZT1zaW1wbGUNCkV4ZWNTdGFydD0iL3NoYXJlZC9tZ210X2RyaXZlcl9vdmVycmlkZS5zaCINClN0YW5kYXJkT3V0cHV0PWpvdXJuYWwNCg0KW0luc3RhbGxdDQpXYW50ZWRCeT1tdWx0aS11c2VyLnRhcmdldA=="
mgmt_driver_override_sh_file="IyEgL2Jpbi9iYXNoCiMgVGhpcyBzY3JpcHQgd2lsbCBvdmVycmlkZSB0aGUgbWFnZW1lbnQgaW50ZXJmYWNlIGRyaXZlciBhdCBib290IHRpbWUsIHNob3VsZCBiZSBjYWxsZWQgZnJvbSBhIHN5c3RlbWQgc2VydmljZS4KbG9nZ2VyIC1wIGxvY2FsMC5ub3RpY2UgIm1nbXRfZHJpdmVyX292ZXJyaWRlOiBSdW5uaW5nIE1YNS82IE1nbXQgRHJpdmVyIE92ZXJyaWRlIFNjcmlwdCIKZWNobyAibWdtdF9kcml2ZXJfb3ZlcnJpZGU6IHN0YXJ0aW5nIHNjcmlwdCBydW4iCmRyaXZlcj0ibWx4NV9jb3JlIgpwY2lfYWRkcj0kKGxzcGNpIHwgZ3JlcCAtbTEgTWVsbGFub3ggfCBhd2sgJ3sgcHJpbnQgIjAwMDA6IiQxIH0nKQpwY2lfcGF0aD0iL3N5cy9idXMvcGNpL2RldmljZXMvJHtwY2lfYWRkcn0iCiMgQWRkIGRyaXZlciBvdmVycmlkZSBlbnRyeQppZiBbWyAtZCAkcGNpX3BhdGggXV07IHRoZW4KICBlY2hvICJtZ210X2RyaXZlcl9vdmVycmlkZTogV3JpdGluZyBkcml2ZXIgdG8gJHtwY2lfcGF0aH0vZHJpdmVyX292ZXJyaWRlIgogIGxvZ2dlciAtcCBsb2NhbDAubm90aWNlICJtZ210X2RyaXZlcl9vdmVycmlkZTogV3JpdGluZyAke2RyaXZlcn0gdG8gJHtwY2lfcGF0aH0vZHJpdmVyX292ZXJyaWRlIgogIGVjaG8gJHtkcml2ZXJ9ID4gJHtwY2lfcGF0aH0vZHJpdmVyX292ZXJyaWRlCmVsc2UKICBlY2hvICJtZ210X2RyaXZlcl9vdmVycmlkZTogRVJST1I6IFBDSSBkZXZpY2UgcGF0aCAoJHBjaV9wYXRoKSBub3QgZm91bmQuIEV4aXRpbmcuLi4iCiAgbG9nZ2VyIC1wIGxvY2FsMC5lcnIgIm1nbXRfZHJpdmVyX292ZXJyaWRlOiBFUlJPUjogUENJIGRldmljZSBwYXRoICgkcGNpX3BhdGgpIG5vdCBmb3VuZC4iCiAgZXhpdCAxCmZpCiMgZm9yY2libHkgcHJvYmUgdGhhdCBQQ0kgc2xvdAplY2hvICJtZ210X2RyaXZlcl9vdmVycmlkZTogRm9yY2luZyBkcml2ZXIgcHJvYmUgb2YgJHBjaV9hZGRyIgpsb2dnZXIgLXAgbG9jYWwwLm5vdGljZSAibWdtdF9kcml2ZXJfb3ZlcnJpZGU6IEZvcmNpbmcgZHJpdmVyIHByb2JlIG9mICR7cGNpX2FkZHJ9IgplY2hvICIkcGNpX2FkZHIiID4gL3N5cy9idXMvcGNpL2RyaXZlcnNfcHJvYmU="

systemctl is-enabled mgmt_driver_override
override_service_enabled=$?
if [ ${override_service_enabled} -ne 0 ]; then
    echo "install_mgmt_driver_override.sh: Did not find mgmt_driver_override service, isntalling now."
    base64 -d > /etc/systemd/system/mgmt_driver_override.service <<< ${mgmt_driver_override_service_file}
    base64 -d > /shared/mgmt_driver_override.sh <<< ${mgmt_driver_override_sh_file}
    chmod +x /shared/mgmt_driver_override.sh
    systemctl enable mgmt_driver_override
fi

# Check if the driver is currently used or if this is first install, and we need to reboot.
lspci -k -d 15b3:101e | grep --silent -i "driver in use"
driver_in_use=$?
if [ ${driver_in_use} -ne 0 ]; then
    # If driver isn't in use, we should reboot once, but use a file to not get into a reboot loop.
    # Check if we've got multiple reboots then we're in an error condition and need not reboot.
    if [ ! -f /shared/mgmt_driver_override_reboot ]; then
        # touch file, to be able to check for a reboot loop.
        touch /shared/mgmt_driver_override_reboot
        reboot
    fi
else
    # if driver is in use, and reboot file still exists, the driver override worked, and we should clean up the reboot file.
    if [ -f /shared/mgmt_driver_override_reboot ]; then
        rm /shared/mgmt_driver_override_reboot
    fi
fi

# Check for install script in user_alert.conf, if it's not there isntall it.
# This will re-install the driver override when big-ip upgrades occur.
grep --silent install_mgmt_driver_override.sh /config/user_alert.conf
if [ $? -ne 0 ]; then
    echo -en "\nalert tmm_startup \"Full configuration initialization phase triggered\" {\n    exec command=\"/bin/bash /shared/install_mgmt_driver_override.sh\"\n}\n" >> /config/user_alert.conf
    echo -en "\nalert tmm_startup \"Initial provisioning successful\" {\n    exec command=\"/bin/bash /shared/install_mgmt_driver_override.sh\"\n}\n" >> /config/user_alert.conf
fi


# Check if files are the latest from the install script:
service_md5sum_from_install=$(echo -en $mgmt_driver_override_service_file | base64 -d | md5sum | awk '{print $1}')
service_md5sum_from_file=$(md5sum /etc/systemd/system/mgmt_driver_override.service | awk '{print $1}')
if [ ${service_md5sum_from_install} != ${service_md5sum_from_file} ]; then
    echo "md5sum for /etc/systemd/system/mgmt_driver_override.service doesn't match current install script, replacing from install script."
    base64 -d > /etc/systemd/system/mgmt_driver_override.service <<< ${mgmt_driver_override_service_file}
fi

sh_md5sum_from_install=$(echo -en $mgmt_driver_override_sh_file | base64 -d | md5sum | awk '{print $1}')
sh_md5sum_from_file=$(md5sum /shared/mgmt_driver_override.sh | awk '{print $1}')
if [ ${service_md5sum_from_install} != ${service_md5sum_from_file} ]; then
    echo "md5sum for /shared/mgmt_driver_override.sh doesn't match current install script, replacing from install script."
    base64 -d > /shared/mgmt_driver_override.sh <<< ${mgmt_driver_override_sh_file}
fi
