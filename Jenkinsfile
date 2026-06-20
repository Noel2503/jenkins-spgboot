pipeline {
    environment {
        registry = "noel135/img-repo"
        registryCredential = 'docker-credential'
        dockerImage = ''
        docker_version = "${BUILD_NUMBER}"
        deployment_file = "${WORKSPACE}/newdeployment.yaml"
        service_file = "${WORKSPACE}/service.yaml"
    }
    agent any
    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
    }
    stages {

    stage('Cloning our Git') {
        steps {
            git(
                url: 'https://github.com/Noel2503/jenkins-spgboot.git',
                credentialsId: 'git-credential',
                branch: 'main'
            )
        }
    }

    stage('Build with Maven') {
        steps {
            sh "chmod +x mvnw"
            sh "./mvnw clean package"
        }
    }

    stage('Build Docker Image') {
    steps {
        sh """
        docker build -t noel135/img-repo:${BUILD_NUMBER} .
        """
    }
}

stage('Push Docker Image') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'docker-credential',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )
        ]) {
            sh """
            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
            docker push noel135/img-repo:${BUILD_NUMBER}
            docker tag noel135/img-repo:${BUILD_NUMBER} noel135/img-repo:latest
            docker push noel135/img-repo:latest
            """
        }
    }
}
	stage('Update Deployment YAML') {
    steps {
        script {
            sh """
            sed -i 's|image: noel135/sample:.*|image: noel135/sample:${BUILD_NUMBER}|g' deployment.yaml
            """
        }
    }
}
}
}
