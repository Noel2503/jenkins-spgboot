pipeline {
agent any

```
environment {
    REGISTRY = "noel135/img-repo"
    DEPLOYMENT_FILE = "deployment.yaml"
}

parameters {
    string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
    choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
}

stages {

    stage('Clone Repository') {
        steps {
            git(
                url: 'https://github.com/Noel2503/jenkins-spgboot.git',
                credentialsId: 'git-credential',
                branch: "${params.BRANCH}"
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
            withCredentials([
                usernamePassword(
                    credentialsId: 'docker-credential',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )
            ]) {
                sh '''
                mkdir -p /kaniko/.docker

                cat > /kaniko/.docker/config.json <<EOF
                {
                  "auths": {
                    "https://index.docker.io/v1/": {
                      "auth": "$(echo -n $DOCKER_USER:$DOCKER_PASS | base64 | tr -d '\n')"
                    }
                  }
                }
                EOF

                /kaniko/executor \
                  --dockerfile=Dockerfile \
                  --context=$WORKSPACE \
                  --destination=noel135/img-repo:${BUILD_NUMBER} \
                  --destination=noel135/img-repo:latest
                '''
            }
        }
    }

    stage('Update Deployment YAML') {
        steps {
            sh '''
            sed -i "s|image: noel135/img-repo:.*|image: noel135/img-repo:${BUILD_NUMBER}|g" ${DEPLOYMENT_FILE}

            echo "Updated deployment file:"
            grep image ${DEPLOYMENT_FILE}
            '''
        }
    }
}

post {
    success {
        echo "Build ${BUILD_NUMBER} completed successfully"
    }

    failure {
        echo "Build failed"
    }
}
```

}
