# Databricks Workspace Creation with Terraform

#------------------------------------------
# In a nutshell:
Update the variables in terraform.tfvars
terraform init
terraform plan
terraform apply -auto-approve
#------------------------------------------


This Terraform template creates a **new Databricks workspace** in an existing Databricks account on AWS.

## What This Template Creates

- A new Databricks workspace in your existing account
- Uses existing account-level configurations (credentials, storage, network)
- Authenticates via Databricks CLI

## Prerequisites

1. **Databricks Account** on AWS with admin access
2. **Account Console Access** at https://accounts.cloud.databricks.com/
3. **Databricks CLI** installed and configured
4. **Terraform** version 1.0 or higher
5. **Pre-configured Account Resources**:
   - AWS Credentials configuration
   - Storage configuration (S3 root bucket)
   - (Optional) Network configuration

## Setup Instructions

### Step 1: Install and Configure Databricks CLI

Install the Databricks CLI:

```bash
# Using pip
pip install databricks-cli

# Or using Homebrew (macOS)
brew tap databricks/tap
brew install databricks
```

Configure authentication for your Databricks account:

```bash
databricks configure --profile DEFAULT
```

When prompted, enter:
- **Databricks Host**: `https://accounts.cloud.databricks.com`
- **Account ID**: Your account ID (found in Account Console URL)
- **Username**: Your account email
- **Password**: Your account password (or use OAuth)

Verify authentication:

```bash
databricks workspaces list --profile DEFAULT
```

### Step 2: Get Required Configuration IDs

You need to obtain configuration IDs from the Databricks Account Console:

#### Get Credentials ID

1. Go to https://accounts.cloud.databricks.com/
2. Navigate to **Cloud Resources** → **Credentials**
3. Copy the **Credential ID** for your AWS credentials

#### Get Storage Configuration ID

1. In Account Console, go to **Cloud Resources** → **Storage**
2. Copy the **Storage Configuration ID** for your S3 root bucket

#### (Optional) Get Network Configuration ID

1. In Account Console, go to **Cloud Resources** → **Networks**
2. Copy the **Network ID** if you want to use a custom VPC

### Step 3: Configure Terraform

1. **Copy the example variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your values:
   ```hcl
   databricks_cli_profile       = "DEFAULT"
   databricks_account_id        = "your-account-id"
   workspace_name               = "my-new-workspace"
   aws_region                   = "us-east-1"
   credentials_id               = "your-credentials-id"
   storage_configuration_id     = "your-storage-config-id"
   # network_id                 = "your-network-id"  # Optional
   pricing_tier                 = "PREMIUM"
   ```

### Step 4: Deploy the Workspace

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the plan**:
   ```bash
   terraform plan
   ```

3. **Create the workspace**:
   ```bash
   terraform apply -auto-approve
   ```

4. **View the workspace URL**:
   ```bash
   terraform output workspace_url
   ```

## Configuration Variables

### Required Variables

| Variable | Description | Where to Find |
|----------|-------------|---------------|
| `databricks_account_id` | Your Databricks account ID | Account Console URL or Settings |
| `workspace_name` | Name for the new workspace | Your choice (1-64 chars) |
| `credentials_id` | AWS credentials configuration ID | Account Console → Cloud Resources → Credentials |
| `storage_configuration_id` | S3 storage configuration ID | Account Console → Cloud Resources → Storage |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `databricks_cli_profile` | Databricks CLI profile name | `DEFAULT` |
| `aws_region` | AWS region for workspace | `us-east-1` |
| `network_id` | Network configuration ID | `null` (uses default) |
| `pricing_tier` | Workspace pricing tier | `PREMIUM` |

## Outputs

After deployment, you can view the workspace details:

```bash
terraform output
```

Available outputs:
- **workspace_id**: Unique workspace identifier
- **workspace_name**: Name of the workspace
- **workspace_url**: URL to access the workspace
- **workspace_status**: Current workspace status
- **deployment_name**: Deployment identifier
- **aws_region**: AWS region
- **pricing_tier**: Workspace pricing tier

### Access Your Workspace

Get the workspace URL:

```bash
terraform output -raw workspace_url
```

Then open it in your browser and log in with your Databricks credentials.

## Post-Deployment Steps

After the workspace is created, you may want to:

1. **Add Users**: Invite team members via Account Console or workspace admin panel
2. **Configure Unity Catalog**: Set up data governance (if using ENTERPRISE tier)
3. **Create Clusters**: Set up compute resources for notebooks and jobs
4. **Create SQL Warehouses**: Set up serverless SQL endpoints
5. **Configure Git Integration**: Connect to GitHub, GitLab, or Azure DevOps

## Managing the Workspace

### Update Workspace Settings

Modify `terraform.tfvars` and apply changes:

```bash
terraform apply
```

### Delete the Workspace

To remove the workspace:

```bash
terraform destroy
```

**Warning**: This will permanently delete the workspace and all its contents (notebooks, data, jobs, etc.).

## Pricing Tiers

| Tier | Features | Best For |
|------|----------|----------|
| **STANDARD** | Basic features, no audit logs | Development/testing |
| **PREMIUM** | RBAC, audit logs, advanced security | Production workloads |
| **ENTERPRISE** | Unity Catalog, system tables, advanced governance | Enterprise data platforms |

## Troubleshooting

### CLI Authentication Issues

If Databricks CLI authentication fails:

```bash
# Test your CLI configuration
databricks workspaces list --profile DEFAULT

# Reconfigure if needed
databricks configure --profile DEFAULT
```

### Missing Configuration IDs

If you can't find credentials or storage configuration IDs:

1. Verify you have account admin permissions
2. Check the correct account at https://accounts.cloud.databricks.com/
3. Ensure AWS resources are properly configured in Account Console

### Workspace Creation Fails

Common issues:
- **Invalid credentials ID**: Verify the AWS role trust relationship
- **Invalid storage ID**: Check S3 bucket exists and is accessible
- **Network issues**: Verify VPC and subnet configurations if using custom network
- **Region mismatch**: Ensure all resources are in the same AWS region

### Terraform State Issues

If Terraform state gets corrupted:

```bash
# Import existing workspace
terraform import databricks_mws_workspaces.this <workspace_id>
```

## Additional Resources

- [Databricks Terraform Provider - Workspace Resource](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces)
- [Databricks Account Console Setup](https://docs.databricks.com/administration-guide/account-settings/index.html)
- [AWS Account Setup for Databricks](https://docs.databricks.com/administration-guide/cloud-configurations/aws/index.html)
- [Databricks CLI Documentation](https://docs.databricks.com/dev-tools/cli/index.html)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## Examples

### Create Multiple Workspaces

Use Terraform workspaces or modules to create multiple Databricks workspaces:

```bash
# Create dev workspace
terraform workspace new dev
terraform apply -var="workspace_name=dev-workspace"

# Create prod workspace
terraform workspace new prod
terraform apply -var="workspace_name=prod-workspace"
```

### Integrate with CI/CD

Use service principal authentication for automated deployments:

```hcl
provider "databricks" {
  alias      = "account"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  client_id  = var.service_principal_client_id
  client_secret = var.service_principal_client_secret
}
```

## Support

For issues or questions:
- [Databricks Community](https://community.databricks.com/)
- [Terraform Provider Issues](https://github.com/databricks/terraform-provider-databricks/issues)
- [Databricks Support Portal](https://help.databricks.com/)

## License

This template is provided as-is for use with your Databricks account.

