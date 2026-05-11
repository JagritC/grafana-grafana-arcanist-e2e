#!/usr/bin/env bash
set -euo pipefail

port="${ARCANIST_APP_HOST_PORT:-3000}"
base_url="http://127.0.0.1:${port}"

curl -fsS "${base_url}/api/health" >/dev/null
curl -fsS -u admin:admin "${base_url}/api/dashboards/uid/arcanist-panels" \
  | grep -q "Arcanist Panel Screenshot Benchmark"

echo "arcanist Grafana dashboard fixture is available at ${base_url}/d/arcanist-panels/arcanist-panel-screenshot-benchmark"
