#!/bin/bash

_SHORT_URL=https://github.com/${ORG_NAME}

deregister_runner() {
  echo "Caught SIGTERM. Deregistering runner"
  if [[ -n "${ACCESS_TOKEN}" ]]; then
    _TOKEN=$(ACCESS_TOKEN="${ACCESS_TOKEN}" bash /token.sh)
    RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  fi
  ./config.sh remove --token "${RUNNER_TOKEN}"
  exit
}
_RUNNER_NAME=${RUNNER_NAME:-${RUNNER_NAME_PREFIX:-self-runner}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')}
configure_runner() {
  ARGS=()
  if [[ -n "${ACCESS_TOKEN}" ]]; then
    echo "Obtaining the token of the runner"
    _TOKEN=$(ACCESS_TOKEN="${ACCESS_TOKEN}" bash /token.sh)
    RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  fi
  echo "Configuring"
  ./config.sh \
      --url "${_SHORT_URL}" \
      --token "${RUNNER_TOKEN}" \
      --name "${_RUNNER_NAME}" \
      --work "/_work" \
      --labels "ued" \
      --unattended \
      --replace 

}

  configure_runner
  trap deregister_runner SIGINT SIGQUIT SIGTERM INT TERM QUIT
  "$@"