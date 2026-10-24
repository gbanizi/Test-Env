pipeline { agent any
stage('Checkout') { steps { checkout scm } }
sh 'ls -lh && cat payments.log | head -n5'
sh '''
docker build -t fintech-monitor:v1 .
docker images | grep fintech
'''
docker run --rm fintech-monitor:v1 bash -c "./monitor.sh && cat alerts.log"
docker save fintech-monitor:v1 -o /tmp/fintech.tar
sudo k3s ctr images import /tmp/fintech.tar
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl apply -f k8s-cronjob.yaml
kubectl get cronjobs
sleep 70
kubectl get jobs
kubectl get pods
POD=$(kubectl get pods --selector=job-name --sort-by=.metadata.creationTimestamp -o name | tail -n1)
kubectl logs $POD
post { always { sh 'kubectl delete cronjob fintech-monitor-cron || true' } }
