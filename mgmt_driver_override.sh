#! /bin/bash

logger -p local0.notice "mgmt_driver_override: Running MX5/6 Mgmt Driver Override Script"
echo "mgmt_driver_override: starting script run"

driver="mlx5_core"

pci_addr=$(lspci | grep -m1 Mellanox | awk '{ print "0000:"$1 }')
pci_path="/sys/bus/pci/devices/${pci_addr}"


# Add driver override entry
if [[ -d $pci_path ]]; then
  echo "mgmt_driver_override: Writing driver to ${pci_path}/driver_override"
  logger -p local0.notice "mgmt_driver_override: Writing ${driver} to ${pci_path}/driver_override"
  echo ${driver} > ${pci_path}/driver_override
else
  echo "mgmt_driver_override: ERROR: PCI device path ($pci_path) not found. Exiting..."
  logger -p local0.err "mgmt_driver_override: ERROR: PCI device path ($pci_path) not found."
  exit 1
fi

# forcibly probe that PCI slot
echo "mgmt_driver_override: Forcing driver probe of $pci_addr"
logger -p local0.notice "mgmt_driver_override: Forcing driver probe of ${pci_addr}"
echo "$pci_addr" > /sys/bus/pci/drivers_probe