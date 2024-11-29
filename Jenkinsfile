pipeline {
    environment {
        registry = "noel135/img-repo"
        registryCredential = 'docker-credential'
        dockerImage = ''
        docker_version = "${BUILD_NUMBER}"
        deployment_file = "${WORKSPACE}/deployment.yaml"
        service_file = "${WORKSPACE}/service.yaml"
        KUBECONFIG_CREDENTIAL_ID = 'kubeconfig'
        SCANNER_HOME = tool 'sonar-scanner'
        TRIVY_SERVER = "http://trivy-server.trivy.svc.cluster.local:4954"
    }
    agent any
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
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=noel-spg \
                        -Dsonar.java.binaries=. \
                        -Dsonar.projectKey=noel-spg
                    '''
                }
            }
        }
        stage('Building our image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":$docker_version"
                }
            }
        }
        stage('Trivy Scan') {
            steps {
                script {
                    // Scan the Docker image with Trivy
                    sh "trivy client --remote ${TRIVY_SERVER} ${registry}:${docker_version} > trivy-scan-report.txt"
                }
            }
        }
		stage('Archive Trivy Report') {
            steps {
                archiveArtifacts allowEmptyArchive: true, artifacts: 'trivy-scan-report.txt'
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {  
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Pull Docker Image') {
            steps {
                script {
                    sh 'docker pull "$registry":"$docker_version"' 
                }
            }
        }
        stage('Update Image in Deployment File on GitHub') {
            steps {
                script {
                    sh "sed -i 's|image: .*|image: ${registry}:${docker_version}|g' ${deployment_file}"
                }
            }
        }
        stage('Update Deployment file to GitHub') {
            steps {
                withCredentials([string(credentialsId: 'git-spgboot', variable: 'git_token_test')]) {
                    sh '''
                        git config --global user.name "Noel2503"
                        git config --global user.email "noelyesuraj25@gmail.com"
                        git add ${deployment_file}
                        git commit -m "Updated deployment docker file"
                        git push https://$git_token_test@github.com/Noel2503/jenkins-spgboot.git HEAD:main
                    '''
                }
            }
        }
        stage('Apply Kubernetes YAML') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh "kubectl delete -f ${deployment_file} -n noelspg"
                    sh "kubectl apply -f ${deployment_file} -n noelspg"
                }
            }
        }
        stage('Cleaning up') {
            steps {
                script {
                    sh 'docker rmi $registry:$BUILD_NUMBER'
                }
            }
        }
    }
}
