import json
import boto3
import os

ecs_client = boto3.client('ecs')
sqs_client = boto3.client('sqs')

CLUSTER_NAME = os.getenv('ECS_CLUSTER_NAME')
TASK_DEFINITION = os.getenv('ECS_TASK_DEFINITION')
SUBNET_ID = os.getenv('ECS_SUBNET_ID')
SECURITY_GROUP_ID = os.getenv('SECURITY_GROUP_ID')

print(f"cluster name read from os: {CLUSTER_NAME}")
print(f"TASK_DEFINITION read from os: {TASK_DEFINITION}")
print(f"SUBNET_ID read from os: {SUBNET_ID}")
print(f"SECURITY_GROUP_ID read from os: {SECURITY_GROUP_ID}")


def lambda_handler(event, context):
    # Get the number of messages in the SQS queue
    queue_url = os.getenv('SQS_QUEUE_URL')
    response = sqs_client.get_queue_attributes(
        QueueUrl=queue_url,
        AttributeNames=['ApproximateNumberOfMessages']
    )
    
    message_count = int(response['Attributes']['ApproximateNumberOfMessages'])
    
    if message_count > 0:
        # Define the number of tasks to start based on the message count
        num_tasks = message_count // 10 + 1 # Example: 1 task per 10 messages
    
        if num_tasks > 0:
            # Start Fargate tasks
            response = ecs_client.run_task(
                cluster=CLUSTER_NAME,
                taskDefinition=TASK_DEFINITION,
                count=num_tasks,
                launchType='FARGATE',
                networkConfiguration={
                    'awsvpcConfiguration': {
                        'subnets': [SUBNET_ID],
                        'securityGroups': [SECURITY_GROUP_ID]
                    }
                }
            )
            
            return {
                'statusCode': 200,
                'body': json.dumps('Started {} tasks'.format(num_tasks))
            }
        else:
            return {
                'statusCode': 200,
                'body': json.dumps('No tasks started')
            }
            print("No SQS messages in queue")
    else:
            return {
                'statusCode': 200,
                'body': json.dumps('No Messages found')
            }