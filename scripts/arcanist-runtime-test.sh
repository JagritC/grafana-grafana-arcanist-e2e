#!/usr/bin/env bash
set -euo pipefail

port="${ARCANIST_APP_HOST_PORT:-3000}"
base_url="http://127.0.0.1:${port}"
dashboard_url="${base_url}/d/arcanist-panels/arcanist-panel-screenshot-benchmark?orgId=1&from=now-6h&to=now"

curl -fsS "${base_url}/api/health" >/dev/null
curl -fsS -u admin:admin "${base_url}/api/dashboards/uid/arcanist-panels" \
  | grep -q "Arcanist Panel Screenshot Benchmark"

echo "health check passed"
echo "dashboard fixture: ${dashboard_url}"
