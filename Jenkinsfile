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
            script {
                dockerImage = docker.build("${registry}:${docker_version}")
            }
        }
    }

    stage('Push Docker Image') {
        steps {
            script {
                docker.withRegistry('https://index.docker.io/v1/', registryCredential) {
                    dockerImage.push()
                    dockerImage.push('latest')
                }
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
