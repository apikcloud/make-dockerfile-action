FROM python:3.11.9-slim

ADD . /app
WORKDIR /app

RUN apt-get update && apt-get install --no-install-recommends --yes git

RUN pip install --target=/app Jinja2 click

ENV PYTHONPATH /app

RUN chmod +x /app/main.py

ENTRYPOINT ["/app/entrypoint.sh"]