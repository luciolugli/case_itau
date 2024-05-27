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
  title: JWT Verifier API
  version: 1.0.0
servers:
  - url: http://localhost:5000
paths:
  /verify:
    post:
      summary: Verify JWT
      operationId: verifyJwt
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                token:
                  type: string
                  description: JWT token to verify
      responses:
        '200':
          description: JWT verification result
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                    description: JWT verification message
        '400':
          description: Bad request
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
                    description: Error message
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
                    description: Error message
EOT

# Adiciona o conteúdo do app.py
cat <<EOT > app.py
from flask import Flask, request, jsonify
import jwt
from jwt.exceptions import InvalidTokenError
import math
from flask_swagger_ui import get_swaggerui_blueprint

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

@app.route('/verify', methods=['POST'])
def verify_jwt():
    token = request.json.get('token')
    if not token:
        return jsonify({'error': 'Token is required'}), 400

    try:
        payload = jwt.decode(token, options={"verify_signature": False})
    except InvalidTokenError:
        return jsonify({'message': 'JWT is invalid'}), 200  # Responde com sucesso, mas indica que o JWT é inválido

    required_claims = ['Name', 'Role', 'Seed']
    if len(payload) != 3 or any(claim not in payload for claim in required_claims):
        return jsonify({'message': 'JWT is invalid'}), 200  # Responde com sucesso, mas indica que o JWT é inválido

    name = payload['Name']
    role = payload['Role']
    seed = payload['Seed']

    if not isinstance(name, str) or any(char.isdigit() for char in name) or len(name) > 256:
        return jsonify({'message': 'JWT is invalid'}), 200  # Responde com sucesso, mas indica que o JWT é inválido

    if role not in ['Admin', 'Member', 'External']:
        return jsonify({'message': 'JWT is invalid'}), 200  # Responde com sucesso, mas indica que o JWT é inválido

    try:
        seed = int(seed)
    except ValueError:
        return jsonify({'message': 'JWT is invalid'}), 200  # Responde com sucesso, mas indica que o JWT é inválido

    if not is_prime(seed):
        return jsonify({'message': 'JWT is invalid'}), 200  # Responde com sucesso, mas indica que o JWT é inválido

    return jsonify({'message': 'JWT is valid'}), 200

if __name__ == '__main__':
    app.run(debug=True)
EOT

echo "Configuração concluída. Para iniciar o servidor Flask, execute: 'source venv/bin/activate' e depois 'python app.py'."

