#!/usr/bin/env bash
set -euo pipefail

# CDK wrapper script with named arguments
# Usage: ./cdk.sh <command> --environment=<env> --image-version=<version> [--profile=<profile>] [--stack=<stack>] [--exclusively]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"

command="${1:-}"
shift || true

environment=""
image_version=""
profile=""
stack=""
exclusively=""
force=""

for arg in "$@"; do
    case "$arg" in
        --environment=*) environment="${arg#*=}" ;;
        --image-version=*) image_version="${arg#*=}" ;;
        --profile=*) profile="${arg#*=}" ;;
        --stack=*) stack="${arg#*=}" ;;
        --exclusively) exclusively="--exclusively" ;;
        --force)
            if [[ "$command" == "import" ]]; then
                force="--force"
            else
                echo "Error: --force is only allowed for import"; exit 1
            fi
            ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

# Validate required arguments
if [[ -z "$environment" ]]; then
    echo "Error: --environment is required (development|production)"
    exit 1
fi

if [[ "$environment" != "development" && "$environment" != "production" ]]; then
    echo "Error: --environment must be 'development' or 'production'"
    exit 1
fi

# image-version is required for all commands except destroy
if [[ -z "$image_version" && "$command" != "destroy" ]]; then
    echo "Error: --image-version is required"
    exit 1
fi

cd "$INFRA_DIR"

# Export ENVIRONMENT for CDK config-loader
export ENVIRONMENT="$environment"

profile_flag=""
if [[ -n "$profile" ]]; then
    profile_flag="--profile $profile"
fi

echo "Environment: $environment"
echo "Profile:     ${profile:-"(using environment credentials)"}"
echo "Image:       $image_version"
echo ""

case "$command" in
    synth)
        yarn cdk synth --context imageVersion="$image_version" $profile_flag $stack $exclusively
        ;;
    diff)
        yarn cdk diff --context imageVersion="$image_version" $profile_flag ${stack:-"--all"} $exclusively
        ;;
    deploy)
        yarn cdk deploy --context imageVersion="$image_version" --require-approval any-change $profile_flag ${stack:-"--all"} $exclusively
        ;;
    destroy)
        yarn cdk destroy --context imageVersion="${image_version:-destroy}" $profile_flag ${stack:-"--all"} $exclusively
        ;;
    import)
        yarn cdk import --context imageVersion="${image_version:-import}" $profile_flag $stack $exclusively $force
        ;;
    *)
        echo "Usage: $0 <synth|diff|deploy|destroy|import> --environment=<development|production> [--profile=<profile>] [--image-version=<version>] [--stack=<stack>] [--exclusively]"
        exit 1
        ;;
esac
