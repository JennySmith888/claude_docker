#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORKSPACE="${WORKSPACE:-$(pwd)}"

case "${1:-help}" in
  up)     docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d proxy
          echo "Proxy started. Run './claude.sh run' to start a session." ;;
  down)   docker compose -f "$SCRIPT_DIR/docker-compose.yml" down ;;
  status) docker compose -f "$SCRIPT_DIR/docker-compose.yml" ps ;;
  logs)   docker compose -f "$SCRIPT_DIR/docker-compose.yml" logs -f proxy ;;
  run)    shift
          docker compose -f "$SCRIPT_DIR/docker-compose.yml" run --rm agent "$@" ;;
  verify) echo "Testing blocked domain (should fail):"
          docker compose -f "$SCRIPT_DIR/docker-compose.yml" run --rm agent \
            curl --max-time 5 https://example.com || echo "✓ Blocked"
          echo "Testing allowed domain (should succeed):"
          docker compose -f "$SCRIPT_DIR/docker-compose.yml" run --rm agent \
            curl -o /dev/null -w "%{http_code}" https://api.anthropic.com
          echo " (404 = reachable)" ;;
  *)      echo "Usage: $0 {up|down|status|logs|run [claude args...]|verify}" ;;
esac
