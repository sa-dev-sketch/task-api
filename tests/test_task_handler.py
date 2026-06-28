from src.handlers.task_handler import handler

# モックデータ（共通）
MOCK_DATA = {
    "task_id": "610d2c62-272f-4b21-a7c8-092773632dba",
    "title": "テストタスク",
    "status": "todo",
    "created_at": "2026-06-24T10:26:21.951542+00:00",
    "updated_at": "2026-06-24T10:26:21.951745+00:00"
}

# 全データ取得
def test_get_tasks(mocker):
    mock_execute = mocker.patch("src.handlers.task_handler.get_table")
    mock_execute.return_value.scan.return_value = {'Items': [MOCK_DATA]}

    event = {
        'requestContext': {'http': {'method': 'GET', 'path': '/tasks'}}
    }
    result = handler(event, None)

    assert result['statusCode'] == 200

# データ登録
def test_create_task(mocker):
    mocker.patch("src.handlers.task_handler.get_table")

    event = {
        'requestContext': {'http': {'method': 'POST', 'path': '/tasks'}},
        'body': '{"title": "テストタスク"}'
    }
    result = handler(event, None)

    assert result['statusCode'] == 201

# 個別データ取得（正常系）
def test_get_task(mocker):
    mock_execute = mocker.patch("src.handlers.task_handler.get_table")
    mock_execute.return_value.get_item.return_value = {'Item': MOCK_DATA}

    event = {
        'requestContext': {'http': {'method': 'GET', 'path': '/tasks/610d2c62-272f-4b21-a7c8-092773632dba'}},
        'pathParameters': {'id': '610d2c62-272f-4b21-a7c8-092773632dba'}
    }
    result = handler(event, None)

    assert result['statusCode'] == 200

# 個別データ取得（異常系）
def test_get_task_not_found(mocker):
    mock_execute = mocker.patch("src.handlers.task_handler.get_table")
    mock_execute.return_value.get_item.return_value = {}

    event = {
        'requestContext': {'http': {'method': 'GET', 'path': '/tasks/none'}},
        'pathParameters': {'id': 'none'}
    }
    result = handler(event, None)

    assert result['statusCode'] == 400

# データ更新
def test_update_task(mocker):
    mock_execute = mocker.patch("src.handlers.task_handler.get_table")
    mock_execute.return_value.update_item.return_value = {'Attributes': {**MOCK_DATA, 'status': 'in_progress'}}

    event = {
        'requestContext': {'http': {'method': 'PUT', 'path': '/tasks/610d2c62-272f-4b21-a7c8-092773632dba'}},
        'pathParameters': {'id': '610d2c62-272f-4b21-a7c8-092773632dba'},
        'body': '{"title": "テストタスク", "status": "in_progress"}'
    }
    result = handler(event, None)

    assert result['statusCode'] == 200

# データ削除
def test_delete_task(mocker):
    mocker.patch("src.handlers.task_handler.get_table")

    event = {
        'requestContext': {'http': {'method': 'DELETE', 'path': '/tasks/610d2c62-272f-4b21-a7c8-092773632dba'}},
        'pathParameters': {'id': '610d2c62-272f-4b21-a7c8-092773632dba'}
    }
    result = handler(event, None)

    assert result['statusCode'] == 204