tasks = []
task_id_counter = 1


def add_task(task_data):
    global task_id_counter
    task = {
        'id': task_id_counter,
        'title': task_data['title'],
        'description': task_data['description']
    }
    tasks.append(task)
    task_id_counter += 1
    return task


def get_tasks():
    return tasks


def get_task(task_id):
    return next((t for t in tasks if t['id'] == task_id), None)


def delete_task(task_id):
    global tasks
    task = get_task(task_id)
    if task:
        tasks = [t for t in tasks if t['id'] != task_id]
        return True
    return False
