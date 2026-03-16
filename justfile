# Fizzy - Developer Commands

# Show all commands
default:
    @just --list --unsorted

# ─────────────────────────────────────────────────────────────
# INFRA
# ─────────────────────────────────────────────────────────────

# [infra] Setup environment (check node, install deps)
infra-setup:
    infra/scripts/setup.sh

# [infra] CDK synth: just infra-synth --environment=<env> --image-version=<version> --profile=<profile> [--stack=StackName]
infra-synth *args:
    infra/scripts/cdk.sh synth {{args}}

# [infra] CDK diff: just infra-diff --environment=<env> --image-version=<version> --profile=<profile> [--stack=StackName]
infra-diff *args:
    infra/scripts/cdk.sh diff {{args}}

# [infra] CDK deploy: just infra-deploy --environment=<env> --image-version=<version> --profile=<profile> [--stack=StackName]
infra-deploy *args:
    infra/scripts/cdk.sh deploy {{args}}

# [infra] CDK destroy: just infra-destroy --environment=<env> --profile=<profile> [--stack=StackName]
infra-destroy *args:
    infra/scripts/cdk.sh destroy {{args}}

# [infra] CDK import: just infra-import --environment=<env> --stack=StackName [--profile=<profile>]
infra-import *args:
    infra/scripts/cdk.sh import {{args}}
