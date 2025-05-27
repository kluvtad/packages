#!/bin/bash
set -e

# Check if the required environment variables are set
for var in RUNNER_URL RUNNER_TOKEN RUNNER_NAME RUNNER_LABELS; do
  if [ -z "${!var}" ]; then
    echo "Error: ${var} is not set."
    exit 1
  fi
done

./config.sh --url "${RUNNER_URL}" \
            --token "${RUNNER_TOKEN}" \
            --name "${RUNNER_NAME}" \
            --labels "${RUNNER_LABELS}" \
            --runnergroup "${RUNNER_GROUP:-default}" \
            --replace

./run.sh