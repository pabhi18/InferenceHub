#!/bin/bash
set -e

echo "Uploading models to MinIO..."
if [ "$#" -ne 3 ]; then
  echo "Usage: ./upload-models.sh <MINIO_ACCESS_KEY> <MINIO_SECRET_KEY> <MODEL_DIRECTORY>"
  echo "Example: ./upload-models.sh ACCESS_KEY SECRET_KEY /path/to/models"
  exit 1
fi

MINIO_ACCESS_KEY="$1"
MINIO_SECRET_KEY="$2"
MODEL_DIRECTORY="$3"
MINIO_ENDPOINT="minio.inferencehub.dpdns.org"

if ! command -v mc &> /dev/null; then
  echo "mc (MinIO Client) could not be found. Installing mc..."
    curl -O https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x mc
    sudo mv mc /usr/local/bin/mc
fi

mc alias set modelstore "http://$MINIO_ENDPOINT" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY"
mc mb modelstore/models || true

mc cp --recursive "$MODEL_DIRECTORY" "modelstore/models/"