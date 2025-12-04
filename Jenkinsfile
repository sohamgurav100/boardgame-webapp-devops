pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('dockerhub-creds')
        SSH_KEY = credentials('app-server-ssh')
        DOCKER_IMAGE = "soham613/boardgame-app"
        APP_SERVER = "35.154.33.125"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Application') {
            steps {
                sh 'chmod +x mvnw'
                sh './mvnw clean package -DskipTests'
            }
        }

        // stage('OWASP Dependency Check') {
        //     steps {
        //         sh '''
        //         dependency-check.sh --scan . --format HTML --out owasp-report
        //         '''
        //     }
        // }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t boardgame-app .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                trivy image --exit-code 0 --severity HIGH,CRITICAL boardgame-app
                '''
            }
        }

        stage('DockerHub Push') {
            steps {
                sh '''
                echo ${DOCKERHUB_PSW} | docker login -u ${DOCKERHUB_USR} --password-stdin
                docker tag boardgame-app ${DOCKER_IMAGE}:latest
                docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Deploy to EC2 App Server') {
            steps {
                sshagent(credentials: ['app-server-ssh']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER} "
                        sudo docker stop boardgame-app || true &&
                        sudo docker rm boardgame-app || true &&
                        sudo docker pull ${DOCKER_IMAGE}:latest &&
                        sudo docker run -d -p 80:8080 --name boardgame-app ${DOCKER_IMAGE}:latest
                    "
                    '''
                }
            }
        }
    }
}
