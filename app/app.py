from flask import Flask, jsonify, request
from models.task import add_task, get_tasks, get_task
from models.task import delete_task as delete_task_model
import os

app = Flask(__name__)


@app.route('/')
def index():
    return jsonify({
        'message': 'Task API is running',
        'endpoints': {
            'GET /tasks': 'Get all tasks',
            'POST /tasks': 'Create new task',
            'GET /tasks/<id>': 'Get specific task',
            'DELETE /tasks/<id>': 'Delete task'
        }
    })


@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200


@app.route('/tasks', methods=['GET'])
def get_all_tasks():
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


@app.route("/tasks/<int:task_id>", methods=["DELETE"])
def delete_task(task_id):
    success = delete_task_model(task_id)
    if success:
        return '', 204
    else:
        return jsonify({'error': 'Task not found'}), 404


if __name__ == '__main__':
    port = int(os.getenv("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)