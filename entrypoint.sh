#!/bin/bash -l

# Run octodns-sync with your config.

# Requirements:
#   - /github/workspace contains a clone of the user's config repository.

# If GITHUB_WORKSPACE is set, prepend it to $1 for _config_path.
echo "INFO: GITHUB_WORKSPACE is '${GITHUB_WORKSPACE}'."
_config_path="${GITHUB_WORKSPACE%/}/${1:-public.yaml}"

_doit="${2}"
_plan_checksum="${3}"
# Change to config directory, so relative paths will work.
cd "$(dirname "${_config_path}")" || echo "INFO: Cannot cd to $(dirname "${_config_path}")."

echo "INFO: _config_path: ${_config_path}"
if [ "${_doit}" = "--doit" ]; then
  if [ -z "${_plan_checksum}" ]; then
    MESSAGE="This script requires passing a plan checksum"
    echo "$MESSAGE"
    echo "::set-output name=result::$MESSAGE"
    exit 1
  fi
  RESULT=$(octodns-sync --config-file="${_config_path}" --log-stream-stdout --plan-checksum "${_plan_checksum}" --doit)
else
  RESULT=$(octodns-sync --config-file="${_config_path}" --log-stream-stdout)
fi
exit_code=$?
echo "$RESULT"

# We want the result after a line starting with *
SHORT_RESULT=$(echo "$RESULT" | sed -ne "/\*/,$ p")

# We need to escape newlines or we only get first line of result
SHORT_RESULT="${SHORT_RESULT//'%'/'%25'}"
SHORT_RESULT="${SHORT_RESULT//$'\n'/'%0A'}"
SHORT_RESULT="${SHORT_RESULT//$'\r'/'%0D'}"
PLAN_CHECKSUM=$(echo "$RESULT" | grep -oP 'Plan Checksum: \K\w+')
echo "::set-output name=result::$SHORT_RESULT"
echo "::set-output name=plan_checksum::$PLAN_CHECKSUM"
exit "$exit_code"
