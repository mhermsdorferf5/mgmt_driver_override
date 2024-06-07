# mgmt_driver_override
This script will override the management interface driver on a BIG-IP.  This is useful for forcing mx6 network adapters to use the mlx5_core driver.

This is a workaround for a BIG-IP VE that has Mellanox ConnectX-6 or newer SR-IOV NICs being used for both data-plane and management networks.  The Mellanox ConnectX-6 NIC is fully supported for the data-plane but requires this workaround for the management plane.

The install script also installs hooks into /config/user_alert.conf to re-run the install script upon reboot & new software installation.  This means that the workaround doesn't need to be reinstalled after upgrades, however you may see an extra reboot after upgrades to redeploy the script.

## Installation
To install and/or update the script simply run the following commands:
```
curl -o /shared/install_mgmt_driver_override.sh 'https://raw.githubusercontent.com/mhermsdorferf5/mgmt_driver_override/main/install_mgmt_driver_override.sh'
bash /shared/install_mgmt_driver_override.sh
reboot
```

If your BIG-IP doesn't have direct internet access, you can always copy/paste and/or scp the install_mgmt_driver_override.sh into the /shared/ folder of the BIG-IP, and then run the bash command to install the fix.