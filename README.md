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
