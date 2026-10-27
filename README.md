# Test-Env
# DevOps Lab Environment

**Stack:** Ubuntu 24.04 LTS | Git | GitHub Codespaces (Azure)

**Lab 01 - Completed:**
- Validated Linux environment (uname, os-release, pwd)
- Verified Git workflow (add, commit, push)
- Environment operational on Codespaces

Part of DevOps Foundations - Linux & Git Module.

Day 7 Goal: Deploy fintech-monitor on K3s + CronJob + Jenkins pipeline
Initial Setup:
Project: Test-Env in GitHub CodespacesApp: fintech-monitor:v1 (Python - fraud checks, CRITICAL logs)K8s manifests: k8s/deployment.yaml (Deployment + CronJob _/5 _ _ _ *)Jenkinsfile building Docker image + kubectl apply

Phase 1: K3s wouldn't start
Error 1: kubectl get nodes -> hudson.model.Hudson.Read
Cause: KUBECONFIG was pointing to Jenkins' kube configFix: Must use sudo k3s kubectl not plain kubectlError 2: sudo k3s server -> overlayfs check failed + operation not permitted
Cause: Codespaces doesn't allow overlayfs inside containerdWe tried: --snapshotter=fuse-overlayfs Error 2b: mount.fuse3: executable file not foundReal fix that worked:bashsudo pkill -9 k3s
sudo rm -rf /var/lib/rancher/k3s/agent/containerd
sudo nohup k3s server --snapshotter=native --write-kubeconfig-mode 644 --disable traefik --disable metrics-server > /tmp/k3s.log 2>&1 &native is slow but it's the only snapshotter that works in Codespaces.
Result: sudo k3s kubectl get nodes -> Ready

Phase 2: Deployment applied but Pod stuckbashsudo k3s kubectl apply -f k8s/deployment.yaml --validate=false
# deployment.apps/fintech-monitor created
# cronjob.batch/fintech-monitor-cron createdBut:
STATUS: ErrImageNeverPull / ContainerCreating
Cause: 
Manifest had imagePullPolicy: NeverDocker image was in Docker, not in K3s's containerdFirst import was wrong namespace:
docker save ... | sudo k3s ctr images import - -> imported 0.0 B (went to default namespace)Fix:bash# Import to CORRECT k8s.io namespace
docker save fintech-monitor:v1 | sudo k3s ctr -n k8s.io images import -

# Verify:
sudo k3s ctr -n k8s.io images ls | grep fintech
# docker.io/library/fintech-monitor:v1 80.8 MiB -> SUCCESS

# Also fix manifest for future:
imagePullPolicy: Never -> IfNotPresentPhase 3: SUCCESS
Final State - your last 2 screenshots prove it:javascriptNAME                                    READY  STATUS     RESTARTS AGE
fintech-monitor-6897b8fd54-w4fl7         1/1    Running    0        16s
fintech-monitor-cron-29884070-nnmsz      0/1    Completed  1        6m52s
fintech-monitor-cron-29884070-ts7jf     0/1    Completed  0        112s

fintech-monitor-cron  */5 * * * *  False  0  3m20s ago  10mLogs:javascriptTotal failed: 4
Alice failed: 2
CRITICAL: High failure rate - 4 failures detected at Mon Oct 26 19:56:42 UTC 2026
FRAUD_CHECK: user alice has 2 failures - review at Mon Oct 26 19:56:42 UTC 2026That is the app working inside K3s. Deployment Running + CronJob completing every 5 minutes.
Git:
k8s/deployment.yaml already pushed, branch main up to date.
