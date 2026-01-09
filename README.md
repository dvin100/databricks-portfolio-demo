## Portfolio Management app

### Description

The demo is an application that provides various tools for a Portfolio
manager

It deploys the following components:

- Serverless workspace and metastore

- Unity Catalog

- Lakeflow job (creates tables, volume, functions)

- Lakeflow pipeline (Streaming table and Materialized view)

- Marketplace integration

- AI/BI (Dashboard and Genie)

- Agent Bricks Knowledge Assistant

- Agent Bricks Multi-Agent Supervisor

- Databricks Apps

- Lakebase

![](./readme_images/image13.png){width="6.5in"
height="4.277777777777778in"}

### App screenshot:

![](./readme_images/image6.png){width="6.5in"
height="5.180555555555555in"}

![](./readme_images/image16.png){width="6.5in"
height="5.180555555555555in"}

![](./readme_images/image18.png){width="6.5in"
height="5.166666666666667in"}

![](./readme_images/image9.png){width="6.5in"
height="5.194444444444445in"}

![](./readme_images/image24.png){width="6.5in"
height="5.180555555555555in"}

![](./readme_images/image12.png){width="6.5in"
height="5.180555555555555in"}

### Requirements

- Terraform, Databricks CLI, JQ

- Databricks account admin

### Variables settings

1.  For the workspace creation, update the variables in the
    terraform.tfvars file\
    ( terraform/account/terraform.tfvars )

2.  For the application, update the variables in the databricks.yml
    file\
    (dabs/databricks.yml)\
    You only need to update the default value for the profile, email,
    catalog, schema.\
    Leave the other values as is.

### Installation

Some components do not have APIs yet. Some manual steps, described
below, are required.

1.  In a terminal, go to the root folder of the demo and run\
    ./deploy.sh

> When asked, run the manual configuration steps

2.  Marketplace\
    !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: manually create the marketplace tables called
> \'news\' from the UI
>
> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

- In the Databricks UI, click on Marketplace

- In the search box, type 'BBC/Google/CNN/Reuters News listing'

- Click 'Get instant access'

![](./readme_images/image11.png){width="5.057292213473316in"
height="2.6826334208223974in"}

![](./readme_images/image29.png){width="3.7953838582677166in"
height="5.921875546806649in"}

3.  Create Catalog\
    !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: manually create the catalog with the same name as the
> one have set in the databricks.yml file. Press enter to continue
> (Currently a bug)
>
> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

![](./readme_images/image21.png){width="6.5in"
height="4.166666666666667in"}

![](./readme_images/image4.png){width="3.350722878390201in"
height="2.5989588801399823in"}

4.  Assign Default Catalog\
    !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: in the UI, set the workspace default catalog to the
> catalog you have just created
>
> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

![](./readme_images/image3.png){width="3.048293963254593in"
height="3.0989588801399823in"}\
![](./readme_images/image1.png){width="7.070831146106737in"
height="2.9777307524059493in"}

5.  Genie Space permission\
    !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: Manually grant access to the Genie space to all users

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-\
![](./readme_images/image5.png){width="6.5in"
height="3.2083333333333335in"}\
![](./readme_images/image10.png){width="6.5in"
height="4.180555555555555in"}

6.  Activate multiple previews

> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-
>
> ACTION REQUIRED: Activate the preview feature \'Mosaic AI Agent Bricks
> Preview\' in the UI and press enter to continue

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: Activate the preview feature \'External Tool Calling
> for Agents\' in the UI and press enter to continue

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: Activate both preview features \'On-Behalf-Of-User
> Authorization\' in the UI and press enter to continue

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: Activate the preview features \'Managed MCP Servers\'
> in the UI and press enter to continue

!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

![](./readme_images/image14.png){width="4.088542213473316in"
height="3.6102351268591426in"}

7.  Dashboard embedding\
    !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: Grant access to allow dashboard embedding
> (Settings/security/embed dashboard) and press enter to continue
>
> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

![](./readme_images/image23.png){width="6.5in"
height="2.4027777777777777in"}

8.  Knowledge Assistant creation\
    (you might need to refresh the browser to see the Agents menu)

![](./readme_images/image26.png){width="6.5in"
height="5.180555555555555in"}

Enter the following under Basic Info\
**Name**: knowledge-assistant-rag

> **Description**: RAG Chatbot for financial documentation, including
> 10K, 10Q and earning calls

Enter the following under Configure Knowledge Sources\
**Source**: demo/portfolio/artifacts/pdf

**Describe the content**: Financial PDF documents, including 10K, 10Q
and earning calls

![](./readme_images/image7.png){width="6.5in" height="6.625in"}

> Once created, keep in mind it might take a couple of minutes to parse
> all documents...

9.  Multi-Agent Supervisor

> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-
>
> ACTION REQUIRED: Create the Multi-agent Supervisor
>
> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

![](./readme_images/image17.png){width="7.0346708223972in"
height="3.2016765091863517in"}

> **Name**: multi-agent-supervisor
>
> **Description**: This Multi-Agent Supervisor answers questions on
> financial data. It includes Genie for structure data, RAG endpoint for
> PDF documents and functions to get news sentiment on various
> companies.
>
> ![](./readme_images/image20.png){width="4.807292213473316in"
> height="9.440702099737532in"}
>
> Copy the Endpoint and paste it in the CLI\
> ![](./readme_images/image28.png){width="6.5in"
> height="1.1805555555555556in"}

10. Apps permissions to Agent Bricks\
    !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: Manually assign the app Service Principal the right
> to use
>
> the Multi-agent Supervisor and the Knowledge Assistant Agent endpoints
>
> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

![](./readme_images/image15.png){width="6.5in"
height="2.6805555555555554in"}

![](./readme_images/image30.png){width="6.5in"
height="2.486111111111111in"}

In BOTH agents, assign the Service Principle permission to query the
endpoint

![](./readme_images/image2.png){width="6.5in"
height="2.6527777777777777in"}

11. Copy the lakebase variables from the APP\
    !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-

> ACTION REQUIRED: Copy the lakebase variables in the file
> dabs/lakebase/lakebase_variable.sh
>
> !-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-![](./readme_images/image22.png){width="4.560426509186351in"
> height="4.895136701662293in"}

12. Connect to Lakebase

![](./readme_images/image8.png){width="6.5in"
height="2.861111111111111in"}

![](./readme_images/image25.png){width="6.5in" height="1.75in"}

> Paste in the CLI
>
> Get OAuth Token + Copy OAuth token + Paste in the CLI

13. To sync the lakebase table

![](./readme_images/image19.png){width="6.5in"
height="2.361111111111111in"}

![](./readme_images/image27.png){width="6.5in"
height="3.763888888888889in"}

### Local testing/development

1.  cd dabs

2.  dabs % ./dev_locally.sh

### Deploy APP only 

To deploy a new version of the app only, without deploying everything
else:

1.  cd dabs/apps

2.  source ../login_new_workspace.sh

3.  databricks bundle deploy \--target dev

4.  databricks bundle run databricks_portfolio_apps

### MISC

Question that leverages various agents in the same question, proving
multi-agentic system:

I want to know which stock I have the most and for that stock, give me
the top 3 risks highlighted in the financial docs and what is the market
sentiment from the news
