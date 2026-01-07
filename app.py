from flask import Flask, request, jsonify
import jwt
from jwt.exceptions import InvalidTokenError
import math
from flask_swagger_ui import get_swaggerui_blueprint
import logging
from logging.handlers import RotatingFileHandler
from datetime import datetime, timezone
import uuid
import requests

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

players = {}
games = {}

def utc_now_iso():
    return datetime.now(timezone.utc).isoformat()

def notify_realtime(payload):
    webhook_url = app.config.get("REALTIME_WEBHOOK_URL")
    if not webhook_url:
        app.logger.info("REALTIME_WEBHOOK_URL not configured, skipping realtime push")
        return
    response = requests.post(webhook_url, json=payload, timeout=5)
    response.raise_for_status()

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

@app.route('/players', methods=['POST'])
def create_player():
    data = request.json or {}
    name = data.get("name")
    team = data.get("team")
    number = data.get("number")
    if not name or not team or number is None:
        return jsonify({"error": "Campos obrigatorios: name, team, number"}), 400
    player_id = str(uuid.uuid4())
    players[player_id] = {
        "id": player_id,
        "name": name,
        "team": team,
        "number": number,
        "approved": False,
        "created_at": utc_now_iso()
    }
    return jsonify(players[player_id]), 201

@app.route('/players', methods=['GET'])
def list_players():
    approved = request.args.get("approved")
    result = list(players.values())
    if approved is not None:
        approved_bool = approved.lower() == "true"
        result = [player for player in result if player["approved"] == approved_bool]
    return jsonify(result), 200

@app.route('/players/<player_id>/approve', methods=['POST'])
def approve_player(player_id):
    player = players.get(player_id)
    if not player:
        return jsonify({"error": "Jogador nao encontrado"}), 404
    player["approved"] = True
    player["approved_at"] = utc_now_iso()
    return jsonify(player), 200

@app.route('/games', methods=['POST'])
def create_game():
    data = request.json or {}
    home_team = data.get("home_team")
    away_team = data.get("away_team")
    if not home_team or not away_team:
        return jsonify({"error": "Campos obrigatorios: home_team, away_team"}), 400
    game_id = str(uuid.uuid4())
    games[game_id] = {
        "id": game_id,
        "home_team": home_team,
        "away_team": away_team,
        "status": "scheduled",
        "score": {"home": 0, "away": 0},
        "period": 1,
        "events": [],
        "created_at": utc_now_iso()
    }
    return jsonify(games[game_id]), 201

@app.route('/games/<game_id>/start', methods=['POST'])
def start_game(game_id):
    game = games.get(game_id)
    if not game:
        return jsonify({"error": "Jogo nao encontrado"}), 404
    game["status"] = "in_progress"
    game["started_at"] = utc_now_iso()
    payload = {"type": "game_started", "game": game}
    notify_realtime(payload)
    return jsonify(game), 200

@app.route('/games/<game_id>/events', methods=['POST'])
def add_game_event(game_id):
    game = games.get(game_id)
    if not game:
        return jsonify({"error": "Jogo nao encontrado"}), 404
    data = request.json or {}
    event_type = data.get("type")
    if not event_type:
        return jsonify({"error": "Campo obrigatorio: type"}), 400
    event = {
        "id": str(uuid.uuid4()),
        "type": event_type,
        "payload": data.get("payload", {}),
        "created_at": utc_now_iso()
    }
    if event_type == "score":
        team = event["payload"].get("team")
        points = event["payload"].get("points", 0)
        if team not in ("home", "away"):
            return jsonify({"error": "payload.team deve ser 'home' ou 'away'"}), 400
        game["score"][team] += int(points)
    if event_type == "period_change":
        game["period"] = int(event["payload"].get("period", game["period"]))
    if event_type == "game_finished":
        game["status"] = "finished"
        game["finished_at"] = utc_now_iso()
    game["events"].append(event)
    payload = {"type": "game_event", "game_id": game_id, "event": event, "game": game}
    notify_realtime(payload)
    return jsonify({"game": game, "event": event}), 201

@app.route('/games/<game_id>', methods=['GET'])
def get_game(game_id):
    game = games.get(game_id)
    if not game:
        return jsonify({"error": "Jogo nao encontrado"}), 404
    return jsonify(game), 200

if __name__ == '__main__':
    configure_logging(app)
    app.run(debug=True)
