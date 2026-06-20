pipeline {
    agent any

    environment {
        REGISTRY = "noel135/img-repo"
        DEPLOYMENT_FILE = "deployment.yaml"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git(
                    url: 'https://github.com/Noel2503/jenkins-spgboot.git',
                    credentialsId: 'git-credential',
                    branch: 'main'
                )
            }
        }

        stage('Build Application') {
            steps {
                sh '''
                chmod +x mvnw
                ./mvnw clean package -DskipTests
                '''
            }
        }

        stage('Build & Push Image') {
            steps {
                sh '''
                /kaniko/executor \
                  --dockerfile=Dockerfile \
                  --context=$WORKSPACE \
                  --destination=noel135/img-repo:${BUILD_NUMBER}
                '''
            }
        }

        stage('Update Deployment YAML') {
            steps {
                sh '''
                sed -i "s|image: noel135/img-repo:.*|image: noel135/img-repo:${BUILD_NUMBER}|g" deployment.yaml
                '''
            }
        }
    }
}
