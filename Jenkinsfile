pipeline {
agent any

environment {
    REGISTRY = "noel135/img-repo"
    REGISTRY_CREDENTIAL = "docker-credential"
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

    stage('Build Docker Image') {
        steps {
            sh '''
            docker build -t ${REGISTRY}:${BUILD_NUMBER} .
            docker tag ${REGISTRY}:${BUILD_NUMBER} ${REGISTRY}:latest
            '''
        }
    }

    stage('Push Docker Image') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: "${REGISTRY_CREDENTIAL}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )
            ]) {
                sh '''
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                docker push ${REGISTRY}:${BUILD_NUMBER}
                docker push ${REGISTRY}:latest
                docker logout
                '''
            }
        }
    }

    stage('Update Deployment YAML') {
        steps {
            sh '''
            sed -i "s|image: noel135/img-repo:.*|image: noel135/img-repo:${BUILD_NUMBER}|g" ${DEPLOYMENT_FILE}

            echo "Updated deployment.yaml:"
            grep image ${DEPLOYMENT_FILE}
            '''
        }
    }
	stage('Commit Deployment Update') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'git-credential',
                usernameVariable: 'GIT_USER',
                passwordVariable: 'GIT_PASS'
            )
        ]) {
            sh '''
            git config user.name "Jenkins"
            git config user.email "jenkins@local"

            git add deployment.yaml
            git commit -m "Update image to ${BUILD_NUMBER}" || true

            git push https://${GIT_USER}:${GIT_PASS}@github.com/Noel2503/jenkins-spgboot.git HEAD:main
            '''
        }
    }
}
}

post {
    success {
        echo "Pipeline completed successfully."
    }
    failure {
        echo "Pipeline failed."
    }
}

}
