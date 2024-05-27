# tests/test_app.py
import pytest
from app import app

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_verify_jwt_valid(client):
    token = "eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQWRtaW4iLCJTZWVkIjoiNzg0MSIsIk5hbWUiOiJUb25pbmhvIEFyYXVqbyJ9.QY05sIjtrcJnP533kQNk8QXcaleJ1Q01jWY_ZzIZuAg"
    response = client.post('/verify', json={'token': token})
    assert response.status_code == 200
    data = response.get_json()
    assert data['message'] == 'Abrindo o JWT, as informações contidas atendem a descricao'

def test_verify_jwt_invalid(client):
    token = "eyJhbGciOiJzI1NiJ9.dfsdfsfryJSr2xrIjoiQWRtaW4iLCJTZrkIjoiNzg0MSIsIk5hbrUiOiJUb25pbmhvIEFyYXVqbyJ9.QY05fsdfsIjtrcJnP533kQNk8QXcaleJ1Q01jWY_ZzIZuAg"
    response = client.post('/verify', json={'token': token})
    assert response.status_code == 200
    data = response.get_json()
    assert data['message'] == 'JWT is invalid'

