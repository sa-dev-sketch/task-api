resource "aws_dynamodb_table" "tasks" {
  name             = "Tasks"
  hash_key         = "task_id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "task_id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "status-index"
    hash_key        = "status"
    projection_type = "ALL"
  }

  tags = {
    Name = "tasks"
  }
}