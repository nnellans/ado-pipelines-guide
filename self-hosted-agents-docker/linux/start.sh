#!/bin/bash
set -e

# Taken from https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker

# Load a token either from the environment variable or by using the service principal credentials.
load_azp_token() {
  # Always un-export AZP_CLIENTSECRET so it is never inherited by
  # child processes (e.g., agent job processes). It remains available
  # as a shell variable so that it can be used to generate a token.
  export -n AZP_CLIENTSECRET

  if [ -n "$AZP_CLIENTID" ]; then
    if [ -z "$AZP_CLIENTSECRET" ]; then
      echo 1>&2 "error: AZP_CLIENTSECRET must be set when AZP_CLIENTID is used"
      exit 1
    fi

    if [ -z "$AZP_TENANTID" ]; then
      echo 1>&2 "error: AZP_TENANTID must be set when AZP_CLIENTID is used"
      exit 1
    fi

    echo "Using service principal credentials to get token"
    # Isolate Azure CLI state to a dedicated, restrictive directory to avoid
    # leaking cached credentials/tokens to subsequent pipeline job processes.
    AZP_TOKEN="$(
       export AZURE_CONFIG_DIR="$(mktemp -d)"
       chmod 700 "$AZURE_CONFIG_DIR"
       az_cli_cleanup() {
         # Log out and remove the isolated Azure CLI config directory to purge cached tokens.
         az logout --username "$AZP_CLIENTID" >/dev/null 2>&1 || true
         az account clear >/dev/null 2>&1 || true
         rm -rf "$AZURE_CONFIG_DIR"
       }
       trap az_cli_cleanup EXIT
       az login --allow-no-subscriptions --service-principal --username "$AZP_CLIENTID" --password "$AZP_CLIENTSECRET" --tenant "$AZP_TENANTID" >/dev/null
       # adapted from https://learn.microsoft.com/en-us/azure/databricks/dev-tools/user-aad-token
       az account get-access-token --query accessToken --output tsv
     )"
    echo "Token retrieved"
  fi

  if [ -z "${AZP_TOKEN_FILE}" ]; then
    if [ -z "${AZP_TOKEN}" ]; then
      echo 1>&2 "error: missing AZP_TOKEN environment variable"
      exit 1
    fi

    AZP_TOKEN_FILE="$(dirname "$0")/.token"
  fi

  if [ -n "${AZP_TOKEN-}" ]; then
    if [ -d "${AZP_TOKEN_FILE}" ]; then
      echo 1>&2 "error: AZP_TOKEN_FILE is a directory, expected a file path: ${AZP_TOKEN_FILE}"
      exit 1
    fi
    # If the file already exists, it must itself be writable. 
    if [ -e "${AZP_TOKEN_FILE}" ]; then
      if [ ! -w "${AZP_TOKEN_FILE}" ]; then
        echo 1>&2 "error: existing AZP_TOKEN_FILE is not writable: ${AZP_TOKEN_FILE}"
        exit 1
      fi
    else
      if [ ! -w "$(dirname "${AZP_TOKEN_FILE}")" ]; then
        echo 1>&2 "error: AZP_TOKEN_FILE parent directory is missing or not writable: $(dirname "${AZP_TOKEN_FILE}")"
        exit 1
      fi
    fi
    (umask 177 && echo -n "${AZP_TOKEN}" > "${AZP_TOKEN_FILE}")
    chmod 600 "${AZP_TOKEN_FILE}" || true
  else
    if [ ! -r "${AZP_TOKEN_FILE}" ]; then
      echo 1>&2 "error: AZP_TOKEN_FILE is not readable: ${AZP_TOKEN_FILE}"
      exit 1
    fi
    if [ ! -s "${AZP_TOKEN_FILE}" ]; then
      echo 1>&2 "error: AZP_TOKEN_FILE is empty: ${AZP_TOKEN_FILE}"
      exit 1
    fi
  fi

  # Unset the AZP_TOKEN environment variable to prevent it from being exposed.
  # At this point the token is only available in the file specified by AZP_TOKEN_FILE.
  unset AZP_TOKEN
}

# Cleanup function to remove the agent configuration.
cleanup() {
  trap "" EXIT

  if [ -e ./config.sh ]; then
    print_header "Cleanup. Removing Azure Pipelines agent..."

    # Try to get a new token if using service principal credentials, as the old one
    # might have expired between the time it was waiting to run a job and now.
    # If refresh fails, continue cleanup with the existing token file.
    if [ -n "$AZP_CLIENTID" ]; then
      if ! ( load_azp_token ); then
         echo "Warning: failed to refresh Azure Pipelines token during cleanup. Continuing with the existing token."
      fi
    fi

    # If the agent has some running jobs, the configuration removal process will fail.
    # So, give it some time to finish the job. But only try max_attempts and then exit.
    max_attempts=10
    attempt=1
    while [ $attempt -le $max_attempts ]; do
      ./config.sh remove --unattended --auth "PAT" --token $(cat "${AZP_TOKEN_FILE}") && break

      echo "Attempt $attempt failed. Retrying in 30 seconds..."
      attempt=$((attempt+1))
      sleep 30
    done
    if [ $attempt -gt $max_attempts ]; then
       echo 1>&2 "warning: failed to remove agent configuration after $max_attempts attempts"
    fi
  fi
}

print_header() {
  lightcyan="\033[1;36m"
  nocolor="\033[0m"
  echo -e "\n${lightcyan}$1${nocolor}\n"
}

if [ -z "${AZP_URL}" ]; then
  echo 1>&2 "error: missing AZP_URL environment variable"
  exit 1
fi

# Load the AZP token for initial setup.
load_azp_token

if [ -n "${AZP_WORK}" ]; then
  mkdir -p "${AZP_WORK}"
fi

# Let the agent ignore sensitive env variables, including tokens and the client secret.
export VSO_AGENT_IGNORE="AZP_TOKEN,AZP_TOKEN_FILE,AZP_CLIENTSECRET"

print_header "1. Determining matching Azure Pipelines agent..."

AZP_AGENT_PACKAGES=$(curl -LsS \
    -u user:$(cat "${AZP_TOKEN_FILE}") \
    -H "Accept:application/json" \
    "${AZP_URL}/_apis/distributedtask/packages/agent?platform=${TARGETARCH}&top=1")

AZP_AGENT_PACKAGE_LATEST_URL=$(echo "${AZP_AGENT_PACKAGES}" | jq -r ".value[0].downloadUrl")

if [ -z "${AZP_AGENT_PACKAGE_LATEST_URL}" -o "${AZP_AGENT_PACKAGE_LATEST_URL}" == "null" ]; then
  echo 1>&2 "error: could not determine a matching Azure Pipelines agent"
  echo 1>&2 "check that account "${AZP_URL}" is correct and the token is valid for that account"
  exit 1
fi

print_header "2. Downloading and extracting Azure Pipelines agent..."

curl -LsS "${AZP_AGENT_PACKAGE_LATEST_URL}" | tar -xz & wait $!

. ./env.sh

trap "cleanup; exit 0" EXIT
trap "cleanup; exit 130" INT
trap "cleanup; exit 143" TERM

print_header "3. Configuring Azure Pipelines agent..."

# Despite it saying "PAT", it can be the token through the service principal
./config.sh --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "${AZP_URL}" \
  --auth "PAT" \
  --token $(cat "${AZP_TOKEN_FILE}") \
  --pool "${AZP_POOL:-Default}" \
  --work "${AZP_WORK:-_work}" \
  --replace \
  --acceptTeeEula & wait $!

print_header "4. Running Azure Pipelines agent..."

chmod +x ./run.sh

# To be aware of TERM and INT signals call ./run.sh
# Running it with the --once flag at the end will shut down the agent after the build is executed
./run.sh "$@" & wait $!
