# Use an ARM-compatible Python base image specifically for 64-bit ARM (aarch64).
FROM arm64v8/python:3.9-slim-bookworm

# Set working directory in the container
WORKDIR /app

# Install necessary system dependencies for the proxy
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    libsecret-1-0 \
    libglib2.0-0 \
    gnupg \
    # Add any other dependencies if the proxy needs a browser for authentication (e.g., xdg-utils, xdg-open)
    # For a headless server, the initial authentication will be done by copying a URL, so a full browser isn't needed.
    && rm -rf /var/lib/apt/lists/*

# Clone the email-oauth2-proxy source code
# We clone directly from the simonrob/email-oauth2-proxy repository
RUN git clone https://github.com/simonrob/email-oauth2-proxy.git .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements-core.txt

# Expose the ports the proxy will listen on
# 8080 for the web interface (for OAuth authentication)
# 8000 for the SMTP proxy
EXPOSE 8080
EXPOSE 8000

# Command to run the proxy
# The proxy will read its configuration from the emailproxy.config file
# mounted in the /data volume.
CMD ["python", "emailproxy.py", "--no-gui"]