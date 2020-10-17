FROM python:3.7-slim

COPY ./requirements.txt .
RUN apt-get update                                                  && \
    apt-get install -y gcc make build-essential                     && \
    python -m pip install --upgrade pip                             && \
    pip install --no-cache-dir -r requirements.txt             && \
    python -c "import nltk; nltk.download('stopwords');"            && \
    find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf    && \
    apt-get clean                                                   && \
    apt-get remove -y build-essential

WORKDIR /bot
COPY ./bot /bot
COPY ./modules /modules

RUN find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf

COPY ./bot/actions/actions.py /bot/actions/actions.py
COPY ./bot/Makefile /bot/Makefile

EXPOSE 5055
HEALTHCHECK --interval=300s --timeout=60s --retries=5 \
  CMD curl -f http://0.0.0.0:5055/health || exit 1

CMD make run-actions
