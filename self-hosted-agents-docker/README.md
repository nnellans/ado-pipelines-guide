The Dockerfiles and scripts found in this folder are taken directly from the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops)

---

### Windows Container Agents
- Windows Container Agents are based on the Windows Server Core image and run on a Windows host
  - See the example Windows Server Core 2019 [Dockerfile](/self-hosted-agents-dockerfile/windows/Dockerfile)
- Requirements for the Windows host:
  - Enable Hyper-V
  - Install Docker for Windows
  - Switch Docker to use Windows containers

---

### Linux Container Agents
- Linux Container Agents are based on the Ubuntu image and run on a Linux host
  - See the example Ubuntu 18.04 [Dockerfile](/self-hosted-agents-dockerfile/ubuntu/Dockerfile-1804)
  - See the example Ubuntu 20.04 [Dockerfile](/self-hosted-agents-dockerfile/ubuntu/Dockerfile-2004)

---

### Running your Container
To run your agent in Docker, you'll pass a few environment variables to docker run, which configures the agent to connect to Azure Pipelines or Azure DevOps Server.
```
docker run -e AZP_URL=<Azure DevOps instance> -e AZP_TOKEN=<PAT token> -e AZP_AGENT_NAME=mydockeragent dockeragent:latest
```
  - This installs the latest version of the agent software
  - This will attach the agent to the `Default` pool in Azure DevOps. You can specify a different pool by setting the `AZP_POOL` environment variable
  - This will use a default agent working directory of `_work`. You can specify a different working directory by setting the `AZP_WORK` environment variable
  - If you want a fresh agent container for every pipeline run, add the `--once` flag to your docker run command

---

### Environment Variables
| Variable | Description |
| -------- | ----------- |
| AZP_URL	| The URL of the Azure DevOps/Azure DevOps Server instance |
| AZP_TOKEN	| Personal Access Token (PAT) with scope of Agent Pools (read, manage) |
| AZP_AGENT_NAME | Agent name (default value: the container hostname) |
| AZP_POOL | Agent pool name (default value: `Default`) |
| AZP_WORK | Agent working directory (default value: `_work`) |

---

### Customize the container to suit your needs
- Tasks and scripts might depend on specific tools being available on the container's PATH, and it's your responsibility to ensure that these tools are available
- For example, the Tasks for [ArchiveFiles](https://github.com/microsoft/azure-pipelines-tasks/tree/master/Tasks/ArchiveFilesV2) and [ExtractFiles](https://github.com/microsoft/azure-pipelines-tasks/tree/master/Tasks/ExtractFilesV1) requires that the `zip` and `unzip` packages be available in your Ubuntu container.  Modify your Dockerfile, as needed, to install the necessary packages
