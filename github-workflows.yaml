#####################################
## WORKFLOW INFO
#####################################

# name of the workflow as shown in the GitHub UI
name: 'string' # optional, default is the path & name of the yaml file

# name to use for each run of the workflow
# value can include expressions, and can reference the contexts of 'github' and 'inputs'
run-name: 'string' # optional, default is specific to how your workflow was triggered

#####################################
## TRIGGERS:  https://docs.github.com/en/actions/using-workflows/triggering-a-workflow
#####################################

# option 1: single event with no options
on: push

# option 2: multiple events with no options
# only one event needs to occur to trigger the workflow
# if multiple events happen at the same time, then multiple runs of the workflow will trigger
on: [push, fork]
on:
  - push
  - fork

# option 3: events with options
on:
  push:
    branches:
    - blahblah
  issues:
    types:
    - opened

# option 4: if this workflow is used as a template (reusable workflow)
on:
  workflow_call:
    inputs: # input parameters
      inputName1:
        description:
        required: true | false
        type: boolean | number | string # required
        default: something # if omitted, a boolean will be false, a number will be 0, and a string will be ""
      inputName2:
    secrets: # input secrets
      secretName1:
        description:
        required: true | false
    outputs: # output values
      outputName1:
        description:
        value:

#####################################
## GITHUB_TOKEN PERMISSIONS:  https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token
#####################################
# if you want to modify the default permissions granted to the GITHUB_TOKEN
# workflow-level, but can also be defined at the Job-level

# option 1: full syntax
permissions:
  actions: read | write | none
  checks: read | write | none
  contents: read | write | none
  deployments: read | write | none
  id-token: read | write | none
  issues: read | write | none
  discussions: read | write | none
  packages: read | write | none
  pages: read | write | none
  pull-requests: read | write | none
  repository-projects: read | write | none
  security-events: read | write | none
  statuses: read | write | none
# option 2: shortcut syntax to provide read or write access for all scopes
permissions: read-all | write-all
# option 3: shortcut syntax to disable permissions to all scopes
permissions: {}

#####################################
## DEFAULTS:  https://docs.github.com/en/actions/using-jobs/setting-default-values-for-jobs
#####################################
# create a map of default settings
# workflow-level, but can also be defined at the Job-level. the most specific defaults wins

defaults:

#####################################
## CONCURRENCY:  https://docs.github.com/en/actions/using-jobs/using-concurrency
#####################################

concurrency:

#####################################
## VARIABLES:  https://docs.github.com/en/actions/learn-github-actions/variables
#####################################
# workflow-level, but can also be defined at the Job-level and Step-level. the most specific variable wins
# cannot reference other variables in the same map

env:
  KEY: value
  KEY: value
# use inside the runner, just access an environment variable as usual
#     linux:  $KEY
#     windows powershell:  $env:KEY
# use workflow-level environment variables outside a runner
#     ${{ env.KEY }}
# there are many default environment variables, most also have a matching value in the github context
#     $GITHUB_REF and ${{ github.ref }}
# use configuration variables defined in GitHub UI
#     ${{ vars.CONFIGKEY }}
# use secrets defined in GitHub UI
#     ${{ secrets.SECRETKEY }}

#####################################
## JOBS:  https://docs.github.com/en/actions/using-jobs/using-jobs-in-a-workflow
#####################################

jobs:

  # Option 1 - Normal Job
  symbolicJobName: # must be unique, start with a letter or underscore, and only contain letters, numbers, dashes, and underscores
    name: 'string' # friendly name that is shown in the GitHub UI
    runs-on: windows-latest | ubuntu-latest | macos-latest # specifies the Agent to run on
    needs: # Job dependencies
    if: # Job condition, ${{ ... }} can optionally be used to enclose your condition
    environment:
    continue-on-error: true # allows the Workflow to pass if this Job fails
    timeout-minutes: 10 # max time a Job can run before being cancelled. optional, default is 360
    permissions: # job-level GITHUB_TOKEN permissions
    defaults: # job-level defaults
    concurrency: # job-level concurrency
    env: # job-level variables
    
    # https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container
    # run all Steps in this Job on this Container, only for Steps that don't already specify a Container
    # only supported on Microsoft-hosted Ubuntu runners, or self-hosted Linux runners
    # 'run' Steps inside a Container will default to the sh shell, overwrite with jobid.defaults.run, or step.shell
    container: node:14.16 # shortcut syntax
    container: # full syntax
      image: node:14.16
      credentials:
        username:
        password:
      env:
      ports:
      volumes:
      options:
    
    # https://docs.github.com/en/actions/using-containerized-services/about-service-containers
    # define service containers
    services:
      symbolicServiceName:
        image: nginx
        credentials:
          username:
          password:
        env:
        ports:
        volumes:
        options:
    
    # https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs
    strategy:
      fail-fast:
      max-parallel:
      matrix:
    
    # https://docs.github.com/en/actions/using-jobs/defining-outputs-for-jobs
    outputs: # specify outputs of this Job
    
    # list the Steps of this Job
    steps:

    # standard Step that uses an Action
    - id: 'symbolicStepName'
      name: 'string' # friendly name that is shown in the GitHub UI
      if: # Step condition, ${{ ... }} can optionally be used to enclose your condition
      continue-on-error: true # allows the Job to pass if this Step fails
      timeout-minutes: 10 # max time to run the Step before killing the process
      env: # Step-level variables
      uses: actions/checkout@v3
      with:
        param1: value1
        param2: value2
        args: 'something' # GitHub passes this to the Docker container's ENTRYPOINT.  This is used instead of the CMD instruction in your Dockerfile
        entrypoint: 'something' # this is used instead of the ENTRYPOINT instruction in your Dockerfile

    # Step that runs a Script
    - name: something2
      run: single-line command
      shell: bash|pwsh|python|sh|cmd|powershell
      working-directory: ./temp

    # Step that runs a Script
    - name: something3
      run: |
        multi-line
        command

  # https://docs.github.com/en/actions/using-workflows/reusing-workflows  
  # Job that calls a Template
  # only the following parameters are supported in such a Job
  symbolicJobName:
    name:
    needs:
    if:
    permissions:
    concurrency:
    uses: org/repo/.github/workflows/file.yaml@ref # reference a Job template
    with: # parameters to pass to the template, must match what is defined in the template
      param1: value1
      param2: value2
    secrets: # secrets to pass to the template, must match what is defined in the template
      param1: ${{ secrets.someSecret }}
      param2: ${{ secretos.someOtherSecret }}
    secrets: inherit # pass all of the secrets from the parent workflow to the template. this includes org, repo, and environment secrets from the parent workflow

# official github actions: https://github.com/orgs/actions/repositories
# official azure actions: https://github.com/marketplace?query=Azure&type=actions&verification=verified_creator
