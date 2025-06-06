FROM registry.hub.docker.com/library/golang:1.23.6 as builder
WORKDIR /workspace
COPY . .
ENV GOOS linux
ENV CGO_ENABLED 1
RUN go mod vendor && \
    go build -ldflags "-s -w" -o prestd cmd/prestd/main.go && \
    apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -yq netcat-traditional && rm -rf /var/lib/apt/lists/*

# Use golang image
# needs go to compile the plugin system
FROM registry.hub.docker.com/library/golang:1.23.6
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*
ENV CGO_ENABLED 1
ENV PREST_BUILD_PLUGINS 1
COPY --from=builder /bin/nc /bin/nc
COPY --from=builder /workspace/prestd /bin/prestd
COPY --from=builder /workspace/etc/entrypoint.sh /app/entrypoint.sh
COPY --from=builder /workspace/lib /app/lib
COPY --from=builder /workspace/etc/plugin /app/plugin
WORKDIR /app
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
