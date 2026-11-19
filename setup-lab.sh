#!/usr/bin/env bash
set -e

echo "==> 1. Checking dependencies (curl, unzip, gpg)..."
sudo apt-get update -qq
sudo apt-get install -y -qq curl unzip gpg lsb-release

echo "==> 2. Installing Nomad and Consul if missing..."
if ! command -v nomad >/dev/null 2>&1 || ! command -v consul >/dev/null 2>&1; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg --yes
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq nomad consul
fi

echo "==> 3. Starting Consul in dev mode..."
if ! pgrep -x "consul" >/dev/null; then
  nohup consul agent -dev -client=0.0.0.0 > /tmp/consul.log 2>&1 &
  for i in $(seq 1 15); do
    curl -sf http://127.0.0.1:8500/v1/status/leader | grep -q ':' && break
    sleep 1
  done
fi

echo "==> 4. Starting Nomad in dev mode..."
if ! pgrep -x "nomad" >/dev/null; then
  sudo bash -c 'nohup nomad agent -dev -bind=0.0.0.0 > /tmp/nomad.log 2>&1 &'
  for i in $(seq 1 20); do
    curl -sf http://127.0.0.1:4646/v1/status/leader | grep -q ':' && break
    sleep 1
  done
fi

if ! curl -sf http://127.0.0.1:4646/v1/status/leader | grep -q ':'; then
  echo "ERROR: Nomad failed to start. Logs:"
  cat /tmp/nomad.log
  exit 1
fi

echo "==> 5. Verifying cluster health..."
consul members
nomad node status
echo "Lab is ready! Nomad UI: http://localhost:4646 | Consul UI: http://localhost:8500"
