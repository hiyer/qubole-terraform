import boto3
import json
import time
import sys

import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    new_ami_id = None
    try:
        ssm = boto3.client("ssm")
        logger.info(event)
        message = event["Records"][0]["Sns"]
        # logger.info(message)
        
        response = ssm.start_automation_execution(
            DocumentName='QBL-CreateEncryptedCopyofAMI',
            Parameters={
                "SourceImageId": [ message["MessageAttributes"]["ami-id"]["Value"] ],
                "SourceImageRegion": [ message["MessageAttributes"]["ami-region"]["Value"] ]
            },
            ClientToken=message["MessageId"]
        )
    except Exception as e:
        logger.error("Error executing automation: %s" %e)
        return {
            'statusCode': 500,
            'body': json.dumps({ 'error': str(e) })
        }

    executionId = response["AutomationExecutionId"]
    response = ssm.get_automation_execution(AutomationExecutionId=executionId)
    execution = response["AutomationExecution"]
    logger.info(execution)
    
    for i in xrange(100):
        try:
            outputs = execution["StepExecutions"][0]["Outputs"]
            new_ami_id = outputs['ImageId'][0]
            break
        except (KeyError, IndexError) as e:
            time.sleep(1)
            continue

    # Make API call to Qubole to set new AMI Id
    return {
        'statusCode': 200,
        'body': json.dumps({ 'ami-id': new_ami_id })
    }
    
    