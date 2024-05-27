# Validador JWT

## Descrição

Este projeto é uma API para verificar tokens JWT. A API valida vários aspectos do token JWT, incluindo sua estrutura, claims e valores específicos.

## Instruções de Instalação

### Requisitos

- Python 3.7 ou superior
- Pip
- Docker (alternativamente, você pode usar Podman)
- AWS CLI
- ECS CLI
- Helm (para Kubernetes)

### Configuração do Ambiente

1. Clone o repositório:
    ```bash
    git clone https://github.com/luciolugli/case_itau.git
    cd case_itau
    ```

2. Instale as dependências Python:
    ```bash
    pip install -r requirements.txt
    ```

3. Configure o Docker:
    - **Docker:**
        ```bash
        docker build -t validate_jwt .
        ```
    - **Podman (alternativa ao Docker):**
        ```bash
        podman build -t validate_jwt .
        ```

4. Execute a aplicação:
    ```bash
    docker run -p 5000:5000 validate_jwt
    ```

### Testes de Unidade / Integração

Para executar os testes, utilize o comando:
```bash
pytest


**********************************************


## Pipeline CI/CD com Jenkins
Este projeto está configurado para utilizar o Jenkins para CI/CD. O pipeline Jenkinsfile inclui etapas para construção, push para ECR e deploy para ECS.

## Configuração do Jenkins
- `1.`: Configure suas credenciais AWS no Jenkins.
- `2.`: Adicione o repositório GitHub como SCM no Jenkins
- `3.`: Crie um pipeline e utilize o Jenkinsfile do projeto.


Deploy no AWS ECS com Fargate

Passos Básicos
- `1.`: Criar um Cluster ECS:
Acesse o console do Amazon ECS e crie um cluster.

- `2.`:Definir uma Tarefa ECS:
Crie uma definição de tarefa que utiliza a imagem Docker que você criou e fez o push para o Docker Hub ou ECR.

- `3.`:Criar um Serviço ECS:
Crie um serviço que utilize a definição de tarefa que você criou.

##Acessar a Aplicação

Verificar o endereço IP público da tarefa Fargate em execução.

##Comandos Importantes
Build e Push da Imagem Docker

docker build -t validate_jwt .
aws ecr get-login-password --region <sua-regiao> | docker login --username AWS --password-stdin <seu-repo-ecr>
docker tag validate_jwt:latest <seu-repo-ecr>:latest
docker push <seu-repo-ecr>:latest



Deploy para ECS

ecs-cli configure --cluster validate-jwt-cluster --default-launch-type FARGATE --region <sua-regiao>
ecs-cli compose --file docker-compose.yml service up


Deploy no Kubernetes com Helm
Instalar o Helm:


curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
