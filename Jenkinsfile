pipeline {
    agent any

    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_NAME = "faizanab/netflix"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/faizan-ab/Deploy-Netflix-Clone-on-Kubernetes.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix
                    """
                }
            }
        }

//        stage('OWASP Dependency Check') {
//            steps {
//                dependencyCheck additionalArguments: '', odcInstallation: 'DependencyCheck'
//                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
//            }
//        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image netflix || true"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {

                        sh """
                        docker build -t $IMAGE_NAME \
                        --build-arg TMDB_V3_API_KEY=98560f1e1e2a9e2af66984b8a63da300 .

                        docker push $IMAGE_NAME
                        """
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh """
                docker stop netflix || true
                docker rm netflix || true
                docker run -d -p 8081:80 --name netflix $IMAGE_NAME
                """
            }
        }
    }
}
