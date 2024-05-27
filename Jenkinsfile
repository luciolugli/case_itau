pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'  // Substitua pela sua região AWS
        ECR_REPO = '121447/validate-jwt' // Substitua pelo nome do seu repositório ECR
        IMAGE_TAG = "validate_jwt:${env.BUILD_ID}"
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Construir a imagem Docker
                    sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Login no ECR
                    sh '''
                    eval $(aws ecr get-login --no-include-email --region $AWS_REGION)
                    docker push $ECR_REPO:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    // Atualizar a definição de tarefa ECS e implantar
                    sh '''
                    ecs-cli configure --cluster validate-jwt-cluster --default-launch-type FARGATE --region $AWS_REGION
                    ecs-cli compose --file docker-compose.yml service up
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

