# Use an ARM-compatible Python base image.
FROM python:3.9-slim-buster-arm64v8

# Set working directory in the container
WORKDIR /app

# Install necessary system dependencies for the proxy
# The proxy uses some OS-level libraries for its functionality (e.g., keyring, browser interaction)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    libsecret-1-0 \
    libglib2.0-0 \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Clone the email-oauth2-proxy source code
# We clone directly from the simonrob/email-oauth2-proxy repository
RUN git clone https://github.com/simonrob/email-oauth2-proxy.git .

# Install Python dependencies
# The email-oauth2-proxy uses requirements.txt for its Python dependencies
RUN pip install --no-cache-dir -r requirements-core.txt

# Expose the ports the proxy will listen on
# 8080 for the web interface (for OAuth authentication)
# 8000 for the SMTP proxy
EXPOSE 8080
EXPOSE 8000

# Command to run the proxy
# We run it in --no-gui mode as it's a server-side application
# We also pass environment variables directly as arguments, which the simonrob proxy supports.
# This makes it easier to manage configuration via Docker Compose.
CMD ["python", "emailproxy.py", "--no-gui", \
    "--listen-address", "0.0.0.0", \
    "--listen-port", "8080", \
    "--smtp-listen-address", "0.0.0.0", \
    "--smtp-listen-port", "8000", \
    "--oauth2-client-id", "${OAUTH2_CLIENT_ID}", \
    "--oauth2-client-secret", "${OAUTH2_CLIENT_SECRET}", \
    "--oauth2-user-email", "${OAUTH2_USER_EMAIL}", \
    "--oauth2-scopes", "${OAUTH2_SCOPES}", \
    "--upstream-smtp-host", "${UPSTREAM_SMTP_HOST}", \
    "--upstream-smtp-port", "${UPSTREAM_SMTP_PORT}", \
    "--redirect-uri", "${OAUTH2_REDIRECT_URI}", \
    "--cache-store", "/data/credstore.config", \
    "--logfile", "${LOGFILE}", \
    "--debug", "${DEBUG}"]

