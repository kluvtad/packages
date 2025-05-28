#!/bin/bash
set -e

# Check if the required environment variables are set
for var in RUNNER_URL RUNNER_TOKEN RUNNER_NAME RUNNER_LABELS; do
  if [ -z "${!var}" ]; then
    echo "Error: ${var} is not set."
    exit 1
  fi
done

FORCE_REGISTER=${FORCE_REGISTER:-false}

if [ "${FORCE_REGISTER}" = "true" ] && [ -d "/workspace/runner" ] ; then
  echo "Force registering the GitHub runner."
  rm -rf /workspace/runner
fi

if [ ! -d "/workspace/runner" ]; then
  echo "Create workspace directory for GitHub runner."
  cp -r /src /workspace/runner

  cd /workspace/runner
  ./config.sh --url "${RUNNER_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --runnergroup "${RUNNER_GROUP:-default}" \
    --replace
fi

cd /workspace/runner
./run.sh
