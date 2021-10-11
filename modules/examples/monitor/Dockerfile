FROM amazon/aws-lambda-python:3.8

COPY requirements.txt monitor.py ./
RUN python -m pip install -r requirements.txt -t .

CMD ["send_message_to_teams.lambda_handler"]