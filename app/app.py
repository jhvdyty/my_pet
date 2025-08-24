from flask import Flask, jsonify, request
from models.task import add_task, get_tasks, get_task
from models.task import delete_task as delete_task_model
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    generate_latest,
    CONTENT_TYPE_LATEST,
)
import time
import os


app = Flask(__name__)

REQUEST_COUNT = Counter(
    'flask_requests_total',
    'Total requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'flask_request_duration_seconds',
    'Request duration',
    ['method', 'endpoint']
)

ACTIVE_TASKS = Gauge(
    'flask_active_tasks_total',
    'Total number of active tasks'
)

DB_CONNECTIONS = Gauge(
    'flask_db_connections_active',
    'Active database connections'
)

REQUESTS_TASKS = Counter(
    'flask_requests_tasks_total',
    'Requests to /tasks endpoint'
)


@app.before_request
def before_request():
    request.start_time = time.time()


@app.after_request
def after_request(response):
    request_duration = time.time() - request.start_time

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()

    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=request.path
    ).observe(request_duration)

    return response


@app.route('/metrics')
def metrics():
    try:
        tasks = get_tasks()
        ACTIVE_TASKS.set(len(tasks))
    except Exception:
        pass

    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


@app.route('/')
def index():
    return jsonify({
        'message': 'Task API is running',
        'endpoints': {
            'GET /tasks': 'Get all tasks',
            'POST /tasks': 'Create new task',
            'GET /tasks/<id>': 'Get specific task',
            'DELETE /tasks/<id>': 'Delete task',
            'GET /metrics': 'Prometheus metrics',
            'GET /health': 'Health check'
        }
    })


@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200


@app.route('/ready')
def ready():
    try:
        get_tasks()
        return jsonify({'status': 'ready'}), 200
    except Exception:
        return jsonify({'status': 'not ready'}), 503


@app.route('/tasks', methods=['GET'])
def get_all_tasks():
    REQUESTS_TASKS.inc()
    return jsonify(get_tasks())


@app.route('/tasks', methods=['POST'])
def create_task():
    task_data = request.get_json()
    if not task_data:
        return jsonify({'error': 'No input data provided'}), 400

    if 'title' not in task_data or 'description' not in task_data:
        return jsonify({'error': 'Missing title or description'}), 400

    task = add_task(task_data)
    return jsonify(task), 201


@app.route('/tasks/<int:task_id>', methods=['GET'])
def get_single_task(task_id):
    task = get_task(task_id)
    if task is None:
        return jsonify({'error': 'задача не найдена'}), 404
    return jsonify(task)


@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    success = delete_task_model(task_id)
    if success:
        return '', 204
    return jsonify({'error': 'Task not found'}), 404


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
