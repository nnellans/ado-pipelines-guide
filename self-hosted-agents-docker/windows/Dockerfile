# Taken from https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker

FROM mcr.microsoft.com/windows/servercore:ltsc2022

WORKDIR /azp/

COPY ./start.ps1 ./

CMD powershell .\start.ps1
