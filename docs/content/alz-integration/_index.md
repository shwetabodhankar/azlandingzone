---
title: "ALZ Integration"
weight: 40
geekdocCollapseSection: true
---

This accelerator deploys a **spoke** only. Hub networking (Azure Firewall, Bastion, hub VNet, peering) is provisioned separately using the [Azure Landing Zone IaC Accelerator](https://aka.ms/alz/acc).

## Connect your spoke to a hub

After deploying your hub, set these parameters to peer the spoke and route traffic through the hub firewall.

### Terraform

```hcl
hub_virtual_network_id         = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet>"
hub_firewall_private_ip        = "10.0.0.4"
hub_route_table_address_spaces = ["10.0.0.0/16"]
```

### Bicep

```bicep
param hubVnetResourceId = '/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet>'
param firewallInternalIp = '10.0.0.4'
```

These values come from the ALZ IaC Accelerator deployment outputs. The spoke VNet is peered to the hub and a UDR routes all outbound traffic through Azure Firewall.
