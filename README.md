# Nomad Canary Deployment & Rollback Lab

End-to-end reference pipeline demonstrating zero-downtime canary deployments, Consul health-check gating, and automated vs. manual rollbacks on HashiCorp Nomad.

## Architecture
1. **CI (`build-and-push`):** GitHub Actions builds the Flask service image on every push to `main` and pushes an immutable `<short-sha>` tag to `ghcr.io`.
2. **CD (`deploy-canary`):** A self-hosted runner updates `nomad-canary-demo.nomad.hcl` with the commit SHA and runs `nomad job run`, blocking until the canary passes health checks or triggers a rollback.
3. **Canary & Health Gating:** Nomad launches `canary = 1` alongside `count = 2` healthy instances. Consul polls `/health` every `5s`; if the canary fails to stay healthy for `min_healthy_time = "10s"`, Nomad halts promotion and reverts.

## One-Command Lab Setup (Ubuntu / WSL2)
```bash
chmod +x setup-lab.sh
./setup-lab.sh
```
* **Nomad UI:** `http://localhost:4646`
* **Consul UI:** `http://localhost:8500`

## Measured Rollback Benchmarks (Week 3)
| Scenario | Configuration | Recovery Mechanism | Measured Time |
| :--- | :--- | :--- | :--- |
| **Automatic Rollback** | `auto_revert = true`, `progress_deadline = 10m` (default) | Unattended Nomad revert after deadline | **10m 11s** (0s human delay) |
| **Automatic Rollback (Tuned)** | `auto_revert = true`, `progress_deadline = 2m` | Unattended Nomad revert after deadline | **~2m 12s** (0s human delay) |
| **Manual Rollback** | `auto_revert = false` | Operator runs `nomad job revert <job> <ver>` | **12.42s** command execution + human detection time |

## Operational Docs
* [Rollback Runbook](docs/ROLLBACK-RUNBOOK.md)
* [Service Review Checklist](docs/SERVICE-REVIEW-CHECKLIST.md)
