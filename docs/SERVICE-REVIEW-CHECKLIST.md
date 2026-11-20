# Nomad Canary & Rollback Readiness Checklist

Use this checklist before enabling automated CI/CD deploys on any Nomad service:

- [ ] **HTTP Health Check Defined:** Service registers a Consul `check` endpoint (e.g., `/health`) that verifies real application readiness, not just an open TCP port.
- [ ] **Canary Enabled (`canary >= 1`):** `update` block deploys at least 1 canary instance alongside existing healthy allocations before replacing them.
- [ ] **Realistic Deadlines Set:**
  - `min_healthy_time` (e.g., `"10s"`) prevents flapping containers from being promoted early.
  - `healthy_deadline` (e.g., `"90s"`) allows enough time for cold Docker image pulls.
  - `progress_deadline` (e.g., `"2m"`–`"5m"`) bounds total failure detection time instead of waiting on the 10-minute default.
- [ ] **Rollback Policy Verified:** `auto_revert = true` is enabled unless the service runs stateful/irreversible migrations (if `false`, on-call engineers must have `nomad job revert` documented in the service runbook).
- [ ] **CI Blocks on Rollout:** Deployment pipeline waits for `nomad job run` to complete and fails the build on non-zero exit codes.
- [ ] **Immutable Image Tags:** Deployments reference exact Git commit SHAs rather than mutable `:latest` tags.
