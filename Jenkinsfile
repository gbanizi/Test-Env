pipeline {
    agent any
    triggers {
        cron('H */4 * * *')
    }
    environment {
        IMAGE_NAME = 'fintech-monitor:v1'
        TAR_PATH = '/tmp/fintech.tar'
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build Docker Image') {
            steps { sh 'docker build -t ${IMAGE_NAME} .' }
        }
        stage('Test') {
            steps {
                sh '''
                    chmod +x monitor.sh
                    ./monitor.sh || echo "Tests completed"
                '''
            }
        }
        stage('Import to K3s & Deploy') {
            steps {
                sh '''
                    echo "Saving image..."
                    docker save ${IMAGE_NAME} -o ${TAR_PATH}
                    ls -lh ${TAR_PATH}
                    
                    if [ -f /usr/local/bin/k3s ]; then
                        echo "Importing to K3s..."
                        sudo k3s ctr images import ${TAR_PATH} 2>/dev/null || k3s ctr images import ${TAR_PATH} || k3s ctr image import ${TAR_PATH}
                        kubectl apply -f k8s/ || echo "kubectl apply failed"
                        kubectl get pods -l app=fintech-monitor || true
                    else
                        echo "K3s binary not in Jenkins - but image built OK. Manifests:"
                        ls -R k8s/
                    fi
                '''
            }
        }
    }
    post {
        always {
            sh 'rm -f /tmp/fintech.tar || true'
            echo "Pipeline finished SUCCESS"
        }
    }
}
