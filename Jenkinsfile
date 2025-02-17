pipeline {
    environment {
        registry = "noel135/img-repo"
        registryCredential = 'docker-credential'
        dockerImage = ''
        docker_version = "${BUILD_NUMBER}"
        deployment_file = "${WORKSPACE}/newdeployment.yaml"
        service_file = "${WORKSPACE}/service.yaml"
        KUBECONFIG_CREDENTIAL_ID = 'kubeconfig' 
        DEPLOY_PATH = "${WORKSPACE}/newdeployment.yaml"
	sshpasswd= "Zn+TEfX94/p2" 

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
                script {
                    sh "chmod 755 /var/jenkins_home/workspace/sample/mvnw"
                    sh "./mvnw clean package" // Run Maven clean package to build the JAR/WAR file
                }
            }
        }
        stage('Deploying the application') {
            steps {
                script {
                      sh "chmod 777  ${WORKSPACE}/target/*.jar"
                      echo "Deploying to ${params.ENVIRONMENT} environment..."
                    if (ENVIRONMENT == 'dev') {
                        sh "sshpass -p "${sshpasswd}" scp -o StrictHostKeyChecking=no -r target/*.jar caasops@100.96.44.207:${DEPLOY_PATH}"
                    } else if (ENVIRONMENT == 'staging') {
                        sh "sshpass -p "{sshpasswd}" scp -o StrictHostKeyChecking=no -r target/*.jar caasops@100.96.44.205:${DEPLOY_PATH}"
                    } else if (ENVIRONMENT == 'prod') {
                        sh " sshpass -p "{sshpasswd}" scp -o StrictHostKeyChecking=no -r target/*.jar caasops@100.96.44.203:${DEPLOY_PATH}"
                    }
                }
            }
        }
    }
}
