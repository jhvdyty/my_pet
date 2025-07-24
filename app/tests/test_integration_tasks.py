import pytest
from app import app 
from models import task as task_model

@pytest.fixture
def client():
    task_model.tasks.clear()
    with app.test_client() as client:
        yield client
    task_model.tasks.clear()

def test_create_and_get_task(client):
    response = client.post('/tasks', json={"title": "Test", "description": "desc"})
    assert response.status_code == 201

    response = client.get('/tasks')
    data = response.get_json()
    assert len(data) == 1
    assert data[0]["title"] == "Test"

def test_get_single_task(client):
    client.post('/tasks', json={"title": "Test", "description": "desc"})
    response = client.get('/tasks/1')
    assert response.status_code == 200
    assert response.get_json()["title"] == "Test"

def test_delete_task(client):
    client.post('/tasks', json={"title": "Delete me", "description": "..."})
    response = client.delete('/tasks/1')
    assert response.status_code == 204

    response = client.get('/tasks/1')
    assert response.status_code == 404