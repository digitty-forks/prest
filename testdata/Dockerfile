FROM registry.hub.docker.com/library/golang:1.23
WORKDIR /workspace
RUN apt update && apt install -y postgresql-client

CMD ["sh", "./testdata/runtest.sh"]
