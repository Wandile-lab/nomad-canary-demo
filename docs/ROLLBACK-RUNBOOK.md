# Nomad Canary Rollback Runbook

## 1. Identify a Failed Deployment
Check the active job and deployment status:
```bash
nomad job status <job-name>
nomad deployment status <deployment-id>
```
* **If `Auto Revert = true`:** Nomad automatically stops the unhealthy canary and creates a new revert deployment restoring the previous healthy job version. Verify `Healthy == Desired` on the new deployment.
* **If `Auto Revert = false`:** The deployment stays in `Status = failed` (`Failed due to progress deadline`). Follow Section 2 immediately.

## 2. Manual Rollback Procedure (`auto_revert = false`)
1. Inspect job history to find the last known-good version number:
   ```bash
   nomad job history <job-name>
   ```
2. Revert the job to that stable version:
   ```bash
   nomad job revert <job-name> <stable-version-number>
   ```
3. Verify the rollback deployment succeeds and all allocations are healthy:
   ```bash
   nomad job status <job-name>
   ```
4. Inspect logs on the failed allocation before re-attempting a fix:
   ```bash
   nomad alloc status <failed-alloc-id>
   nomad alloc logs <failed-alloc-id>
   ```
