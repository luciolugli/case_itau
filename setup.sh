#!/bin/bash

# Verifica se o Python 3 está instalado
if ! command -v python3 &> /dev/null
then
    echo "Python 3 não está instalado. Por favor, instale o Python 3 e tente novamente."
    exit
fi

# Verifica se o pip está instalado
if ! command -v pip &> /dev/null
then
    echo "pip não está instalado. Instalando pip..."
    sudo apt-get install python3-pip -y
fi

# Cria um ambiente virtual
if [ ! -d "venv" ]; then
    echo "Criando ambiente virtual..."
    python3 -m venv venv
fi

# Ativa o ambiente virtual
source venv/bin/activate

# Atualiza o pip
pip install --upgrade pip

# Instala as dependências
echo "Instalando dependências..."
pip install flask pyjwt flask-swagger-ui

# Cria a estrutura de pastas e arquivos se não existirem
mkdir -p static
touch static/swagger.yaml


# Adiciona o conteúdo do swagger.yaml
cat <<EOT > static/swagger.yaml
openapi: 3.0.0
info:
  version: 1.0.0
  title: Api Validador JWT
  description: API para verificação de tokens JWT
paths:
  /verify:
    post:
      summary: Verifica se um token JWT é válido
      description: Verifica se um token JWT atende a determinadas regras.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                token:
                  type: string
                  description: Token JWT a ser verificado
      responses:
        '200':
          description: Sucesso na verificação do token
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    description: Mensagem de sucesso
                  justification:
                    type: string
                    description: Justificativa para o sucesso da verificação do token
                  payload:
                    type: object
                    description: Payload do token JWT
        '400':
          description: Erro de solicitação inválida
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
                    description: Mensagem de erro
        '401':
          description: Token JWT inválido
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
                    description: Mensagem de erro
components:
  schemas:
    ErrorResponse:
      type: object
      properties:
        error:
          type: string
          description: Mensagem de erro
servers:
  # Added by API Auto Mocking Plugin
  - description: SwaggerHub API Auto Mocking
    url: https://virtserver.swaggerhub.com/LUCIOLUGLI/jwt-api/1.0.0
  - url: http://127.0.0.1:5000
    description: Local development server

EOT

# Adiciona o conteúdo do app.py
from flask import Flask, request, jsonify
import jwt
from jwt.exceptions import InvalidTokenError
import math
from flask_swagger_ui import get_swaggerui_blueprint
import logging
from logging.handlers import RotatingFileHandler

app = Flask(__name__)

### Swagger specific ###
SWAGGER_URL = '/swagger'
API_URL = '/static/swagger.yaml'
SWAGGERUI_BLUEPRINT = get_swaggerui_blueprint(SWAGGER_URL, API_URL, config={'app_name': "JWT Verifier API"})
app.register_blueprint(SWAGGERUI_BLUEPRINT, url_prefix=SWAGGER_URL)
### End Swagger specific ###

def is_prime(n):
    """Check if a number is prime."""
    if n <= 1:
        return False
    if n <= 3:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

# Configuração do logger
def configure_logging(app):
    # Configuração do logger principal
    app.logger.setLevel(logging.DEBUG)

    # Formato das mensagens de log
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    # Handler para log para console
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)  # Defina o nível do log conforme necessário
    console_handler.setFormatter(formatter)
    app.logger.addHandler(console_handler)

    # Handler para log em arquivo rotativo
    file_handler = RotatingFileHandler('app.log', maxBytes=1024000, backupCount=10)
    file_handler.setLevel(logging.DEBUG)  # Defina o nível do log conforme necessário
    file_handler.setFormatter(formatter)
    app.logger.addHandler(file_handler)

# Chamada para configurar o logging
configure_logging(app)

@app.route('/verify', methods=['POST'])
def verify_jwt():
    token = request.json.get('token')
    if not token:
        return jsonify({'error': 'Token obrigatorio'}), 400

    try:
        payload = jwt.decode(token, options={"verify_signature": False})
    except InvalidTokenError:
        return jsonify({'error': 'JWT invalido'}), 200

    required_claims = ['Name', 'Role', 'Seed']
    if len(payload) != 3 or any(claim not in payload for claim in required_claims):
        return jsonify({'error': 'Foi encontrado mais de 3 claims.'}), 400

    name = payload['Name']
    role = payload['Role']
    seed = payload['Seed']

    if not isinstance(name, str) or any(char.isdigit() for char in name) or len(name) > 256:
        return jsonify({'error': 'Claim Name invalido. Abrindo o JWT, a Claim Name possui caracter de numeros'}), 400

    if role not in ['Admin', 'Member', 'External']:
        return jsonify({'error': 'Role Claim Role Invalido'}), 400

    try:
        seed = int(seed)
    except ValueError:
        return jsonify({'error': 'Seed deve ser um numero'}), 400

    if not is_prime(seed):
        return jsonify({'error': 'A claim Seed deve ser um numero primo'}), 400

    # Se todas as verificações passarem, retornar uma resposta de sucesso com detalhes do payload e justificativa
    return jsonify({
        'message': 'JWT valido',
        'justification': 'Abrindo o JWT, as informações contidas atendem a descricao',
        'payload': payload
    }), 200

if __name__ == '__main__':
    configure_logging(app)
    app.run(debug=True)
EOT

echo "Configuração concluída. Para iniciar o servidor Flask, execute: 'source venv/bin/activate' e depois 'python app.py'."

