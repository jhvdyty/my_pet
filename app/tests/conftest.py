
import pytest
from models import task as task_model


@pytest.fixture(autouse=True)
def reset_tasks():
    task_model.tasks.clear()
    task_model.task_id_counter = 1
    yield
    task_model.tasks.clear()
    task_model.task_id_counter = 1
