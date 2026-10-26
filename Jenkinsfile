pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t fintech-monitor:v1 .'
            }
        }
        stage('Test') {
            steps {
                sh '''
                chmod +x monitor.sh
                ./monitor.sh
                '''
            }
        }
        stage('Import to K3s & Deploy') {
            steps {
                sh '''
                docker save fintech-monitor:v1 -o /tmp/fintech.tar
                sudo k3s ctr images import /tmp/fintech.tar
                export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
                kubectl apply -f k8s-cronjob.yaml
                kubectl get cronjobs
                '''
            }
        }
    }
    post {
        always {
            sh 'rm -f /tmp/fintech.tar || true'
        }
    }
}
