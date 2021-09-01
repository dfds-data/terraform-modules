from os import environ
import json
import gzip
import logging
from base64 import b64decode
from os import environ
import pymsteams

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def read_event(event):
    compressed_payload = b64decode(event["awslogs"]["data"])

    uncompressed_payload = gzip.decompress(compressed_payload)

    payload = json.loads(uncompressed_payload)
    
    return payload

def send_teams_message(hook_url, message):
    myTeamsMessage = pymsteams.connectorcard(hook_url)
    myTeamsMessage.text(message)
    myTeamsMessage.send()

def lambda_handler(event, context):
    payload = read_event(event)
    hook_url = environ["webhook_url"]
    message = payload["logEvents"][0]["message"]
    
    loggroup = payload["logGroup"]
    message = f"*{loggroup}*: \n \n {message}"
    send_teams_message(hook_url, message)
