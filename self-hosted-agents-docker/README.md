The Dockerfiles and scripts found in this folder are taken directly from the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops)

---

### Windows Container Agents
- Windows Container Agents are based on the Windows Server Core image and run on a Windows host
  - See the example Windows Server Core 2022 [Dockerfile](/self-hosted-agents-docker/windows/Dockerfile)
- Build the Windows image:
  `docker build --tag "azp-agent:windows" --file "./Dockerfile" .` 
- Running the Windows image:
  ```powershell
  docker run \
    -e AZP_URL="<Azure DevOps instance>" `
    -e AZP_TOKEN="<Personal Access Token>" `
    -e AZP_POOL="<Agent Pool Name>" `
    -e AZP_AGENT_NAME="Docker Agent - Windows" `
    --name "azp-agent-windows" `
    azp-agent:windows
  ```
  - If you want a fresh agent container for every pipeline job, pass the `--once` flag to the `run` command
- Requirements for the Windows host:
  - Enable Hyper-V
  - Install Docker for Windows
  - Switch Docker to use Windows containers

---

### Linux Container Agents
- Linux Container Agents are based on either the Ubuntu or Alpine image and run on a Linux host
  - See the example Ubuntu 22.04 [Dockerfile](/self-hosted-agents-docker/linux/Dockerfile-ubuntu-2204)
  - See the example Alpine [Dockerfile](/self-hosted-agents-docker/linux/Dockerfile-alpine)
- Build the Linux image:
  `docker build --tag "azp-agent:linux" --file "./Dockerfile" .`
- Running the Linux image:
  ```shell
  docker run \
    -e AZP_URL="<Azure DevOps instance>" \
    -e AZP_TOKEN="<Personal Access Token>" \
    -e AZP_POOL="<Agent Pool Name>" \
    -e AZP_AGENT_NAME="Docker Agent - Linux" \
    --name "azp-agent-linux" \
    azp-agent:linux
  ```
  - If you want a fresh agent container for every pipeline job, pass the `--once` flag to the `run` command.

---

### Environment Variables
| Variable | Description |
| --- | --- |
| AZP_URL	| The URL of the Azure DevOps/Azure DevOps Server instance |
| AZP_TOKEN	| Personal Access Token (PAT) with scope of Agent Pools (read, manage) |
| AZP_AGENT_NAME | Agent name (default value: the container hostname) |
| AZP_POOL | Agent pool name (default value: `Default`) |
| AZP_WORK | Agent working directory (default value: `_work`) |

---

### Customize the container to suit your needs
- Tasks and scripts might depend on specific tools being available on the container's PATH, and it's your responsibility to ensure that these tools are available
- For example, the Tasks for [ArchiveFiles](https://github.com/microsoft/azure-pipelines-tasks/tree/master/Tasks/ArchiveFilesV2) and [ExtractFiles](https://github.com/microsoft/azure-pipelines-tasks/tree/master/Tasks/ExtractFilesV1) requires that the `zip` and `unzip` packages be available in your Ubuntu container.  Modify your Dockerfile, as needed, to install the necessary packages
