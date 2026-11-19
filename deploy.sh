#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${1:-latest}"
JOB_FILE="nomad-canary-demo.nomad.hcl"

echo "==> Updating job spec to image tag: ${IMAGE_TAG}"
sed -E -i "s|(image = \"[^\"]+:)[^\"]+\"|\1${IMAGE_TAG}\"|" "${JOB_FILE}"

echo "==> Submitting job to Nomad and waiting for canary rollout..."
# Blocks until the canary passes min_healthy_time (exit 0) or fails/reverts (exit 1)
nomad job run "${JOB_FILE}"

echo "==> Rollout completed successfully!"
