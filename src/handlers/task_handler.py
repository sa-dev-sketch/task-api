import os
import json
import boto3
import uuid
from datetime import datetime, timezone

def get_table():
    local_endpoint_url = os.environ.get('DYNAMODB_ENDPOINT_URL')
    dynamodb = boto3.resource(
        'dynamodb',
        endpoint_url=local_endpoint_url, # ローカルの場合はDynamoDB Localコンテナに繋ぐ
        region_name=os.environ.get('AWS_REGION', 'ap-northeast-3')
    )
    TABLE_NAME = os.environ.get('TABLE_NAME', 'Tasks')
    return dynamodb.Table(TABLE_NAME)


def handler(event, context):
    http_method = event.get('requestContext', {}).get('http', {}).get('method')
    path = event.get('requestContext', {}).get('http', {}).get('path')
    task_id = event.get('pathParameters', {}).get('id')

    if http_method == 'GET' and path == '/tasks':
        return get_tasks()
    
    elif http_method == 'POST' and path == '/tasks':
        body = json.loads(event.get('body', '{}'))
        return create_task(body)
    
    elif http_method == 'GET' and task_id:
        return get_task(task_id)  
      
    elif http_method == 'PUT' and task_id:
        body = json.loads(event.get('body', '{}'))
        return update_task(task_id, body)

    elif http_method == 'DELETE' and task_id:
        return delete_task(task_id)
     
    else:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'Not found'})
        }


def get_tasks():
    table = get_table()
    response = table.scan()
    return {
        'statusCode': 200,
        'body': json.dumps(response['Items'], ensure_ascii=False)
    }


def create_task(body):
    task = {
        'task_id': str(uuid.uuid4()),
        'title': body.get('title', ''),
        'status': 'todo',
        'created_at': datetime.now(timezone.utc).isoformat(),
        'updated_at': datetime.now(timezone.utc).isoformat()
    }
    table = get_table()
    table.put_item(Item=task)
    return {
        'statusCode': 201,
        'body': json.dumps(task, ensure_ascii=False)
    }


def get_task(task_id):
    table = get_table()
    response = table.get_item(Key={'task_id': task_id})
    item = response.get('Item')

    if not item:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Tasks not found'}, ensure_ascii=False)
        }
    return {
        'statusCode': 200,
        'body': json.dumps(item, ensure_ascii=False)
    }


def update_task(task_id, body):
    table = get_table()
    response = table.update_item(
        Key={'task_id': task_id},
        UpdateExpression='SET title = :title, #s = :status, updated_at = :updated_at',
        ExpressionAttributeNames={'#s': 'status'},
        ExpressionAttributeValues={
            ':title': body.get('title'),
            ':status': body.get('status'),
            ':updated_at': datetime.now(timezone.utc).isoformat(),
        },
        ReturnValues='ALL_NEW'
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response['Attributes'], ensure_ascii=False)
    }    


def delete_task(task_id):
    table = get_table()
    table.delete_item(Key={'task_id': task_id})
    return {
        'statusCode': 204,
        'body': ''
    }