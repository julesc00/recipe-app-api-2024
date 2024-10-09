FROM python:3.9-alpine3.13
LABEL maintainer="julesc003@gmail.com"
ENV PYTHONUNBUFFERED=1

# Copy necessary files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# Argument to switch between dev and prod
ARG DEV=false

# Install necessary dependencies and create the user
RUN apk add --no-cache bash && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /tmp && \
    adduser -D -H -s /bin/bash django-user

# Ensure the Python virtual environment is in the path
ENV PATH="/py/bin:$PATH"

# Switch to the newly created user
USER django-user


