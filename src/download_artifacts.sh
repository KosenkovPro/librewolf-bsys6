#!/usr/bin/env bash
set -eu

source $BSYS6/exports/vars.sh

if [ "$FORGE_TYPE" == "github" ]; then
  echo "Notice: On GitHub the build artifacts are exchanged with the 'actions/upload-artifact' and 'actions/download-artifact' actions, there is nothing to download here" >&2
  exit 0
fi

source $BSYS6/exports/artifacts_s3.sh

echo "-> Downloading artifacts from s3://$S3_ARTIFACTS_BUCKET$ARTIFACTS_RUN_PATH/" >&2
if ! artifacts_s3cmd get --recursive --force "s3://$S3_ARTIFACTS_BUCKET$ARTIFACTS_RUN_PATH/" . >&2; then
  echo "Error: Failed to download artifacts from the artifacts bucket" >&2
  exit 1
fi
