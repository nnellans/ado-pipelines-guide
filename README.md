**Warning**: This is an advanced guide and assumes you already know the basics of Azure DevOps Pipelines. Think of this more like an advanced cheat sheet. I went through various sources, captured any notes that I felt were important, and organized them into the README file you see here. If you are new to ADO Pipelines, then I would suggest going through the Microsoft Docs or doing a couple Microsoft Learn courses first.

It's important to know that this is a live document. Some of the sections are still a work in progress. I will be continually updating it over time.

Azure DevOps has two different types of Pipelines.  First, there is the "*Classic UI*" Pipelines, these come in both Build and Release forms.  Second, there are the YAML Pipelines that are defined strictly in code.  This guide will only focus on the modern YAML Pipelines.

---

# High-Level Pipeline Structure

There are two main types of information defined in a YAML Pipeline:
1. Pipeline-level information. This includes things like triggers, parameters, variables, agent pools, repositories, etc.
2. The actual work being done by the Pipeline.  There are three different ways you can define the work:
  - The standard way by defining `Stages`, `Jobs`, and `Steps`.  This way will always work, no matter how many Stages or Jobs you have.
    ![pipeline option 1](/images/pipeline-option1-stages.png)
  - If you have one Stage with multiple Jobs, then you can omit the `Stages` layer.  So, all you need to define is `Jobs` and `Steps`.
    ![pipeline option 2](/images/pipeline-option2-jobs.png)
  - If you have one Stage with one Job, then you can omit both the `Stages` and `Jobs` layer.  So, all you need to define is `Steps`.
    ![pipeline option 3](/images/pipeline-option3-steps.png)

---

# Pipeline-level information

Let's start by going over the common fields that can be defined at the root of the Pipeline, they are:
- name
- appendCommitMessageToRunTime
- trigger
- pr
- schedules
- parameters
- variables
- pool
- resources
- lockBehavior

## name
- Specifies the name for each "Run" of this pipeline
- Not to be confused with the actual name of the pipeline itself (which is defined in the Azure DevOps UI)
- This expects a string value, and expressions are allowed
- This field is optional.  The default name of each run will be in this format: `yyyymmdd.xx` where:
  - `yyyymmdd` is the current date
  - `xx` is an iterator, which starts at `1` and increments with each run of the pipeline

## appendCommitMessageToRunName
- Specifies if the latest Git commit message is appended to the end of the run name (specified above)
- This field is optional.  The default is `true`
- This expects a boolean value, and accepts any of the following: `true`, `y`, `yes`, `on`, `false`, `n`, `no`, `off`

## trigger
- Specifies the Continuous Integration (CI) triggers that will be used to automatically start a run of this pipeline
- This looks for pushes to branches or tags on the repo where the pipeline's YAML file is stored
- This field is optional.  By default, a push to any branch of the repo will cause a pipeline run to be triggered
- You cannot use variables in triggers, as variables are not evaluated until after the pipeline triggers
- triggers are not supported inside template files
- There are 3 ways to define CI triggers:

### Option 1 - Disable CI Triggers
```yaml
trigger: 'none'
```
- Pushes to branches will not trigger a pipeline run

### Option 2 - Simplified Branch Syntax
```yaml
trigger:
- main
- feature/*
```
- This lets you specify a list of branch names, and wildcards are supported
- Any push to these branches will trigger a pipeline run

### Option 3 - Full Syntax
```yaml
trigger:
  batch: boolean
  branches:
    include:
    - main
    exclude:
    - feature/*
    - release/*
  paths:
    include:
    - docs/readme.md
    - docs/app*
    exclude:
    - .gitignore
    - docs
  tags:
    include:
    - v2.*
    exclude:
    - v3.0
```
- If you specify both `branches` and `tags` then both will be evaluated, if at least one of them matches, then the pipeline will be triggered
- `paths` is optional, and cannot be used by itself, `paths` is only used to modify `branches`
  - Paths in Git are case-sensitive, and wildcards are supported
- `batch` is optional, the default is `false`
  - Enabling the `batch` option means only one instance of the pipeline will run at a time.  While the second run of the pipeline is waiting for its turn, it will batch up all of the changes that have been made while its been waiting, and when its finally able to run it will apply all of those changes at once

---

## pr
- Specifies the Pull Request (PR) triggers that will be used to automatically start a run of this pipeline
- This looks for Pull Requests that are opened on branches of the repo where the pipeline's YAML file is stored
- YAML PR triggers are only supported for GitHub and BitBucket Cloud
- This field is optional.  By default, a PR opened on any branch of the repo will cause a pipeline run to be triggered
- You cannot use variables in triggers, as variables are not evaluated until after the pipeline triggers
- triggers are not supported inside template files
- There are 3 ways to define CI triggers:

### Option 1 - Disable PR Triggers
```yaml
pr: 'none'
```
- Pushes to branches will not trigger a pipeline run

### Option 2 - Simplified Branch Syntax
```yaml
pr:
- main
- feature/*
```
- This lets you specify a list of branch names, and wildcards are supported
- Any push to these branches will trigger a pipeline run

### Option 3 - Full Syntax
```yaml
pr:
  autoCancel: boolean
  drafts: boolean
  branches:
    include:
    - main
    exclude:
    - feature/*
    - release/*
  paths:
    include:
    - docs/readme.md
    - docs/app*
    exclude:
    - .gitignore
    - docs
```
- `paths` is optional, and cannot be used by itself, `paths` is only used to modify `branches`
  - Paths in Git are case-sensitive, and wildcards are supported
- `autoCancel` is optional, the default is `true`
  - If more updates are made to the same PR, should in-progress validation runs be canceled?
- `drafts` is optional, the default is `true`
  - Will 'draft' PRs cause the trigger to fire?





1. stages
2. jobs
3. steps
  - strategy
  - continueOnError
  - container
  - services
  - workspace
4. extends



---
Triggers
- Tells the Pipeline when to run

Stages
- A logical boundary that can be used to mark seperation of concerns (one example being Build, QA, Production)
- Stages are comprised of one or more Jobs (max of 256 Jobs per Stage)
- By default, Stages run sequentially, one after the other, in the order they are defined in the yaml file.
  - In other words, by default, each Stage has an implicit dependency on the previous Stage
  - If you add `dependsOn` to a Stage, then you can change the order in which the Stages run
  - If you add `dependsOn: []` to a Stage, this removes any dependencies altogether, so this Stage will run in parallel with others
- By default, a Stage will not run if the previous Stage fails
  - If you add a `condition` to a Stage, you can make it run even if the previous Stage fails
  - If you add any `condition` to a Stage, then you are removing the implicit condition that the previous Stage must succeed.  So, when you use a `condition` on a Stage it is common to use `and(succeeded(),yourCustomCondition)` which adds the implicit success condition back, as well as adds your own custom condition.  Otherwise, this Stage will run regardless of the outcoum of the preceding Stage.

Jobs
- Each Job runs on one Agent
  - Though, there are a handful of 'Agentless' Jobs as well
- Jobs are comprised of one or more Steps
- An Agent can only run one Job at a time
  - To run multiple Jobs in parallel you must have multiple Agents as well as purchase sufficient Parallel Jobs
  - If you have multiple Agents and don't want your Jobs running in parallel, then you can use `dependsOn` in your Jobs to make sure they run in the order you want them to
- Jobs are configured with a default timeout of 60 minutes
  - This can be configured by adding the `timeoutInMinutes` setting to your Job
  - Setting `timeoutInMinutes` will set the timeout to:
    - Forever on self-hosted Agents
    - 360 minutes / 6 hours on Microsoft-hosted Agents for a public project and public repo
    - 60 minutes / 1 hour on Microsoft-hosted Agents for a private project and private repo (but you can purchase more)
- 

Steps
- The smallest building block of a Pipeline
- Steps can run a Task
  - Tasks are pre-packaged scripts or procedures to do something (install Java, run a Gradle build, etc.)
  - Tasks abstract away a lot of the underlying complexity, and all you have to do is just provide a set of inputs to the Task
- Steps can also just run your own custom Script (command line, PowerShell, or Bash)

---

Environments
Agents
Artifacts

---

Conditions
- Conditions can be used on Stages, Jobs, or Steps

---

Templates
- Templates must exist on your filesystem at the start of a pipeline run
- You can't reference Templates in an artifact
- 1. Steps
- 2. Jobs
  - When templating Jobs, remember to remove the name of the Job inside your Template file, this will avoid any naming conflicts
- 3. Stages
- 4. Variables
- When referencing a Template, the path to use for the Template should be relative to the main yaml pipeline
- You can reference a Template that is in another repo than the main yaml pipeline
  - You must define the other repo in the 'resources' section in your main yaml pipeline
  - template: file.yaml@repoName
  - You can also reference the repo where the main yaml pipeline is found with 'self':
    template: file.yaml@self

---

`${{ Template Expressions }}`
- Can be used to expand Parameters or Variables
- Two formats:
  - Index Syntax: `${{ parameters['someName']`
  - Property Deference syntax: `${{ parameters.someName }}`
- Expansion only happens inside Stages, Jobs, Steps, or Resources\Containers
  - What about the new feature for Repos?

---

Sources
- https://learn.microsoft.com/en-us/azure/devops/pipelines/process/stages
- https://learn.microsoft.com/en-us/azure/devops/pipelines/process/phases
- https://learn.microsoft.com/en-us/azure/devops/pipelines/process/templates
- https://learn.microsoft.com/en-us/azure/devops/pipelines/process/expressions
- https://learn.microsoft.com/en-us/azure/devops/pipelines/process/conditions
