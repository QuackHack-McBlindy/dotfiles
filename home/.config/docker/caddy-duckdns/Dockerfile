# syntax=docker/dockerfile:1

# Stage 1: Build Caddy with DuckDNS plugin
FROM caddy:2.9.1-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns

# Stage 2: Final image
FROM alpine:latest

# Metadata
LABEL org.opencontainers.image.source="https://github.com/your-repo/combined-caddy-duckdns"
LABEL org.opencontainers.image.description="Caddy server with DuckDNS plugin and DuckDNS DDNS updater"
LABEL org.opencontainers.image.author="Your Name <your.email@example.com>"
LABEL org.opencontainers.image.licenses=MIT

# Default environment variables for DuckDNS updater
ENV FREQUENCY=5
ENV RECORD_TYPE=A
ENV TZ=UTC

# Install dependencies
RUN apk update && apk add --no-cache tzdata curl bind-tools caddy && \
    mkdir -p /etc/caddy /data /config

# Copy Caddy binary from builder stage
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Embed DuckDNS logic directly
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'print_breaker() { echo "-------------------------------------------------"; }' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Set timezone' >> /entrypoint.sh && \
    echo 'if [ -z "$TZ" ]; then echo "TZ not set. Defaulting to UTC"; else ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; echo $TZ > /etc/timezone; fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Check and prepare DuckDNS environment' >> /entrypoint.sh && \
    echo 'if [ -f "$TOKEN_FILE" ]; then TOKEN=$(cat "$TOKEN_FILE"); fi' >> /entrypoint.sh && \
    echo 'if [ -z "$TOKEN" ]; then echo "TOKEN not set. Exiting."; exit 1; fi' >> /entrypoint.sh && \
    echo 'if [ -f "$SUBDOMAINS_FILE" ]; then SUBDOMAINS=$(cat "$SUBDOMAINS_FILE"); fi' >> /entrypoint.sh && \
    echo 'if [ -z "$SUBDOMAINS" ]; then echo "SUBDOMAINS not set. Exiting."; exit 1; fi' >> /entrypoint.sh && \
    echo 'if [ "$RECORD_TYPE" != "A" ] && [ "$RECORD_TYPE" != "AAAA" ]; then RECORD_TYPE="A"; fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'echo "TOKEN=\"$TOKEN\"" > /config.sh' >> /entrypoint.sh && \
    echo 'echo "SUBDOMAINS=\"$SUBDOMAINS\"" >> /config.sh' >> /entrypoint.sh && \
    echo 'echo "RECORD_TYPE=\"$RECORD_TYPE\"" >> /config.sh' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Function to get public IP' >> /entrypoint.sh && \
    echo 'get_ip() {' >> /entrypoint.sh && \
    echo '  if [ "$RECORD_TYPE" = "A" ]; then echo $(curl -s https://ipv4.icanhazip.com/); else echo $(curl -s https://ipv6.icanhazip.com/); fi' >> /entrypoint.sh && \
    echo '}' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Update loop' >> /entrypoint.sh && \
    echo 'while true; do' >> /entrypoint.sh && \
    echo '  CURRENT_IP=$(get_ip)' >> /entrypoint.sh && \
    echo '  if [ -z "$CURRENT_IP" ]; then echo "Could not fetch IP"; sleep $((FREQUENCY * 60)); continue; fi' >> /entrypoint.sh && \
    echo '  OLD_IP=$(cat /old_record_ip 2>/dev/null)' >> /entrypoint.sh && \
    echo '  if [ "$CURRENT_IP" != "$OLD_IP" ]; then' >> /entrypoint.sh && \
    echo '    RESULT=$(curl -s "https://www.duckdns.org/update?domains=${SUBDOMAINS}&token=${TOKEN}&${RECORD_TYPE}=${CURRENT_IP}")' >> /entrypoint.sh && \
    echo '    if [ "$RESULT" = "OK" ]; then echo "$CURRENT_IP" > /old_record_ip; fi' >> /entrypoint.sh && \
    echo '  fi' >> /entrypoint.sh && \
    echo '  sleep $((FREQUENCY * 60))' >> /entrypoint.sh && \
    echo 'done &' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Start Caddy' >> /entrypoint.sh && \
    echo 'exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose necessary ports
EXPOSE 80 443

# Entry point
ENTRYPOINT ["/entrypoint.sh"]
