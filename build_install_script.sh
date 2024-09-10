#!/bin/bash

# Update base64 encoded mgmt_driver_override.service file in install script:
mgmt_driver_override_service_file=`cat mgmt_driver_override.service | base64 -w0 | perl -pe 's/\\//\\\\\\//g'` 
perl -p -i -e 's/^mgmt_driver_override_service_file.*$/mgmt_driver_override_service_file=\"'$mgmt_driver_override_service_file'\"/g' install_mgmt_driver_override.sh

# Update base64 encoded mgmt_driver_override.sh file in install script:
mgmt_driver_override_sh_file=`cat mgmt_driver_override.sh | base64 -w0 | perl -pe 's/\\//\\\\\\//g'` 
perl -p -i -e 's/^mgmt_driver_override_sh_file.*$/mgmt_driver_override_sh_file=\"'$mgmt_driver_override_sh_file'\"/g' install_mgmt_driver_override.sh

# Update base64 encoded install_mgmt_driver_override.sh file in README file:
install_script=`cat install_mgmt_driver_override.sh | base64 -w0 | perl -pe 's/\\//\\\\\\//g'`
perl -p -i -e 's/^echo \-en \".*\" \| base64 \-d \> \/shared\/install_mgmt_driver_override\.sh/echo \-en \"'$install_script'\" \| base64 \-d \> \/shared\/install_mgmt_driver_override\.sh/g' README.md
