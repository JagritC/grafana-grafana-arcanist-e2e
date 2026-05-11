#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export GO_VERSION="${GO_VERSION:-1.26.3}"
export PATH="/usr/local/go/bin:${PATH}"
export YARN_ENABLE_PROGRESS_BARS=false
export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=8192}"

install_os_packages() {
  if command -v gcc >/dev/null 2>&1 && command -v curl >/dev/null 2>&1 && command -v make >/dev/null 2>&1; then
    return
  fi

  apt-get update
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    make \
    python3
  rm -rf /var/lib/apt/lists/*
}

install_go() {
  if command -v go >/dev/null 2>&1 && go version | grep -q "go${GO_VERSION}"; then
    return
  fi

  curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tgz
  rm -rf /usr/local/go
  tar -C /usr/local -xzf /tmp/go.tgz
  rm -f /tmp/go.tgz
}

install_os_packages
install_go

corepack enable
corepack install

yarn install --immutable
yarn run build:nominify

GO_BUILD_DEV=1 make build-go

mkdir -p /tmp/grafana-data /tmp/grafana-logs /tmp/grafana-plugins

exec ./bin/linux/amd64/grafana server \
  --homepath=/app \
  cfg:app_mode=development \
  cfg:analytics.check_for_plugin_updates=false \
  cfg:analytics.check_for_updates=false \
  cfg:analytics.reporting_enabled=false \
  cfg:auth.anonymous.enabled=true \
  cfg:auth.anonymous.org_role=Admin \
  cfg:paths.data=/tmp/grafana-data \
  cfg:paths.logs=/tmp/grafana-logs \
  cfg:paths.plugins=/tmp/grafana-plugins \
  cfg:paths.provisioning=/etc/grafana/provisioning \
  cfg:security.admin_password=admin \
  cfg:security.admin_user=admin \
  cfg:server.http_addr=0.0.0.0 \
  cfg:server.http_port="${PORT:-3000}" \
  cfg:users.default_theme=light
