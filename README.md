# Areopagus

Areopagus is an AWS-hosted application.

This repository contains:

- Application code
- Tests
- Terraform for AWS resources used by the application
- GitHub Actions and other repository-level development tooling

## Repository Layout

```text
.agents/skills/       # Repository-local agent skills
.github/workflows/    # GitHub Actions workflows
src/                  # Python application code
terraform/            # Areopagus application infrastructure
tests/                # Application tests
```

## AWS Platform

AWS organization and governance are managed separately in the `aws-platform` repository.

The `aws-platform` repository is responsible for platform-level resources such as:

- AWS Organizations
- Account provisioning
- Organizational Units
- Service Control Policies
- Organization-level governance

This repository is responsible for resources that belong specifically to the Areopagus application and run inside the Areopagus AWS account.

In short:

```text
aws-platform
└── AWS platform and governance

areopagus
├── application code
└── application infrastructure
```

## Infrastructure

Terraform is used to manage Areopagus infrastructure.

Terraform applies are currently performed manually from a local, authenticated administrator environment. GitHub Actions should not automatically apply Terraform unless that approach is deliberately changed in the future.

## Development

The primary development environment is Windows with Visual Studio Code, Codex, Python, Terraform, AWS CLI, and Git.

More documentation will be added as the application architecture is built.
