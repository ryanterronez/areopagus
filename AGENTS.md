# Repository Instructions

## Purpose

Areopagus is a small application for ingesting lecture content and making transcripts searchable.

Optimize for:
- simplicity
- security
- low cost
- understandability
- easy local development
- minimal AWS infrastructure

Do not solve problems we do not currently have.

## Architecture

Keep the architecture as small as possible.

Admin-only bootstrap operations should run locally unless there is a concrete reason they must run in AWS.

Application infrastructure belongs in this repository.

Organization governance, account-level security controls, shared AWS bootstrap infrastructure, and other true platform concerns belong in `aws-platform`.

Before introducing a new AWS service or significant infrastructure component, stop and propose the design first. Explain:
1. the requirement it solves,
2. why existing infrastructure or local execution is insufficient,
3. the AWS resources it would create,
4. IAM/security implications,
5. recurring cost or operational burden.

Do not implement the architectural change until Ryan approves it.

Do not create speculative infrastructure, future scaffolding, unused integrations, or abstractions for anticipated scale.

## Local execution

Use Windows Command Prompt (`cmd`) syntax for local commands.

Never run Git operations.

Never run Terraform, AWS CLI, shell, or other infrastructure-changing commands on Ryan's behalf.

When commands are needed, provide the exact commands for Ryan to copy and run manually.

Ryan prefers to perform Git and infrastructure operations himself.

## Local-first developer experience

When the same operation can run locally or in CI/CD, optimize the local path for simplicity.

The normal local workflow should use the shortest reasonable commands.

For Terraform, prefer local usage such as:

`terraform init`

`terraform plan`

`terraform apply`

Do not require Ryan to routinely provide:
- backend configuration files
- role ARNs
- repeated `-var` arguments
- variable files used only for CI
- CI-specific environment variables
- other pipeline-oriented configuration

Prefer sensible checked-in defaults for normal local use when doing so is safe.

If CI/CD requires additional backend configuration, role assumption, variables, credentials setup, or other complexity, put that complexity in the workflow rather than shifting it onto the local developer experience.

Do not make the local workflow more complicated solely to make the pipeline easier to configure.

Local simplicity is the priority.

## Python

Use the Python version selected by pyenv.

Create the project environment with:

`pyenv exec python -m venv .venv`

Always activate `.venv` before running Python tools, dependencies, tests, or the application:

`.venv\Scripts\activate.bat`

Do not use the system Python or install project dependencies globally.

Keep local bootstrap functionality independent from AWS whenever practical.

## AWS

Prefer the smallest secure AWS design.

Avoid:
- custom networking unless required
- always-on compute
- unnecessary Lambda functions
- queues or orchestration without a demonstrated need
- unnecessary IAM roles or policy layers
- customer-managed KMS keys unless required
- infrastructure created only for future possibilities

Use AWS IAM Identity Center / SSO for human access.

Use short-lived credentials.

Do not create IAM users or long-lived AWS access keys.

Do not use AdministratorAccess or PowerUserAccess for normal application deployment.

## Terraform

Keep Terraform boring.

Prefer:
- one Terraform root when practical
- direct resources
- few variables
- few outputs
- minimal abstraction
- AWS defaults when they safely satisfy the requirement

Do not create modules merely for organization or anticipated reuse.

Do not introduce additional Terraform roots or state boundaries without a real privilege, ownership, or lifecycle reason.

Do not require local users to supply configuration that can safely be encoded as normal repository defaults.

Pipeline-specific Terraform configuration should stay in CI/CD rather than complicating the local workflow.

Use repository-installed Terraform skills when relevant.

## CI/CD

CI should primarily validate code and Terraform.

Do not create automatic infrastructure deployment workflows unless Ryan explicitly approves that deployment model.

Do not expand GitHub Actions permissions or AWS trust relationships without explaining why they are required.

Keep workflows small and scoped to the files and responsibility they actually validate.

CI/CD may use more explicit configuration than local development when automation requires it.

Do not simplify CI/CD by making local commands more complicated.

## Change discipline

Implement only the requested slice.

Do not scaffold future work.

Do not add adjacent infrastructure or functionality simply because it may eventually be useful.

If implementation begins growing materially beyond the requirement that started the task, stop and ask for architectural approval.

Prefer removing obsolete complexity rather than building another layer around it.

## Naming and consistency

Names should accurately describe the resource, role, variable, output, policy, or behavior they represent.

Do not preserve misleading historical names merely because they already exist in the code.

Keep terminology consistent across Terraform, Python, workflows, documentation, and AWS resource names where practical.

Do not rename deployed AWS resources solely for cosmetic reasons unless Ryan explicitly approves the resulting replacement or migration.

Prefer clear, boring names over clever abstractions.

## Documentation

`PROJECT_STATUS.md` is the canonical concise snapshot of:
- current architecture
- implemented functionality
- active work
- major decisions
- next steps
- blockers

Keep it current when a change materially affects those areas.

Keep `README.md` focused on:
- project purpose
- repository orientation
- how to run current functionality locally
- current developer/user instructions

Remove or correct instructions that are no longer valid.

Do not document hypothetical architecture as though it already exists.

## Completion

For meaningful changes, report:
1. what changed,
2. files added, removed, or modified,
3. AWS resources added or removed,
4. IAM permissions or trust relationships changed,
5. recurring cost impact,
6. commands Ryan needs to run manually,
7. anything uncertain that needs review.

## Guiding principle

Areopagus should remain understandable and operable by one engineer.

When in doubt, choose less infrastructure, less code, and the simpler local workflow.