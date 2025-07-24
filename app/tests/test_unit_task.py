import pytest
from models.task import add_task, get_tasks, get_task, delete_task

from models import task as task_model

@pytest.fixture(autouse=True)
def reset_test():
    task_model.tasks.clear()
    yield
    task_model.tasks.clear()

def test_add_add_get_task():
    t = {"title": "Test", "description": "Unit test"}
    add_task(t)
    assert get_tasks()[0]["title"] == "Test"

def test_get_task_by_id():
    add_task({"title": "Task A", "description": "desc A"})
    task = get_task(1)
    assert task is not None 
    assert task["id"] == 1

def test_delete_task():
    add_task({"title": "To delete", "description": "desc"})
    delete_task(1)
    assert get_task(1) is None