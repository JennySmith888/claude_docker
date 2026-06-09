#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker compose -f "$SCRIPT_DIR/docker-compose.yml" down
docker compose -f "$SCRIPT_DIR/docker-compose.yml" build agent
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d proxy
echo "Rebuild complete. Run './claude.sh run' to start a session."
