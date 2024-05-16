FROM debian:stable-slim

RUN apt-get update 
RUN apt-get install -y iproute2 iputils-ping

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
