# Terraform Examples

Ready-to-deploy `.tfvars` configurations for the App Service Landing Zone Accelerator, designed for integration with the [ALZ Platform Landing Zone](https://aka.ms/alz/acc).

Each example includes ALZ hub integration (VNet peering, route table, private DNS), diagnostic settings, and production-grade defaults.

## Examples

| File | OS | Hosting | Container | Description |
|------|----|---------|-----------|-------------|
| [`managed-instance.tfvars`](managed-instance.tfvars) | Windows | Managed Instance | No | Dedicated VNet-integrated Windows instances with RDP support (P1v4 SKU) |
| [`ase-windows-app.tfvars`](ase-windows-app.tfvars) | Windows | ASE v3 | No | App Service Environment v3 with Windows .NET code-based app (I1v2 SKU) |
| [`ase-windows-container.tfvars`](ase-windows-container.tfvars) | Windows | ASE v3 | Yes | ASE v3 with Windows container from ACR (I1v2 SKU) |
| [`ase-linux-app.tfvars`](ase-linux-app.tfvars) | Linux | ASE v3 | No | ASE v3 with Linux .NET code-based app (I1v2 SKU) |
| [`ase-linux-container.tfvars`](ase-linux-container.tfvars) | Linux | ASE v3 | Yes | ASE v3 with Linux container from ACR (I1v2 SKU) |
| [`asp-windows-app.tfvars`](asp-windows-app.tfvars) | Windows | App Service Plan | No | Premium v3 Windows plan with .NET code-based app (P1v3 SKU) |
| [`asp-windows-container.tfvars`](asp-windows-container.tfvars) | Windows | App Service Plan | Yes | Premium v3 Windows container plan with Docker from ACR (P1v3 SKU) |
| [`asp-linux-app.tfvars`](asp-linux-app.tfvars) | Linux | App Service Plan | No | Premium v3 Linux plan with .NET code-based app (P1v3 SKU) |
| [`asp-linux-container.tfvars`](asp-linux-container.tfvars) | Linux | App Service Plan | Yes | Premium v3 Linux plan with Docker container from ACR (P1v3 SKU) |

## Usage

1. Copy the desired example to the parent directory as `terraform.tfvars`:

   ```bash
   cp examples/asp-linux-app.tfvars terraform.tfvars
   ```

2. Edit `terraform.tfvars` to replace placeholder values:
   - **Subscription ID** — replace `00000000-0000-0000-0000-000000000000` with your subscription ID
   - **Resource group** — update the resource group name to match your environment
   - **Hub VNet ID** — set to your ALZ hub VNet resource ID (or remove for standalone deployment)
   - **Firewall IP** — set to your hub firewall private IP (or remove if not routing through a firewall)
   - **Container registry URL** — for container scenarios, update the ACR login server URL
   - **Tags** — adjust tags to match your organisation's tagging policy

3. Deploy:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## ALZ Hub Integration

All examples are pre-configured for ALZ Platform Landing Zone integration:

- **Hub VNet Peering** — bi-directional peering to the hub VNet specified by `hub_virtual_network_id`
- **Route Table** — default route (0.0.0.0/0) through the hub firewall at `hub_firewall_private_ip`
- **Private DNS Zones** — privatelink zones created and linked to the spoke VNet
- **Diagnostics** — Application Insights and Log Analytics enabled by default

To deploy **without** ALZ hub integration, remove or comment out the `hub_virtual_network_id` and `hub_firewall_private_ip` lines.

## Choosing an Example

| Need | Recommended Example |
|------|-------------------|
| Most cost-effective Linux deployment | `asp-linux-app.tfvars` |
| Most cost-effective Windows deployment | `asp-windows-app.tfvars` |
| Full network isolation (compliance) | Any `ase-*` example |
| Custom Docker containers | Any `*-container` example |
| Legacy Windows apps with RDP access | `managed-instance.tfvars` |
