#!/bin/sh

# Check required environment variables
if [ -z "$LITELLM_MASTER_KEY" ]; then
    echo "Error: LITELLM_MASTER_KEY is not set"
    exit 1
fi

if [ "$STORE_MODEL_IN_DB" = "True" ]; then
    if [ -z "$LITELLM_SALT_KEY" ]; then
        echo "Error: LITELLM_SALT_KEY is required when STORE_MODEL_IN_DB is True"
        exit 1
    fi
    if [ -z "$DATABASE_URL" ]; then
        echo "Error: DATABASE_URL is required when STORE_MODEL_IN_DB is True"
        exit 1
    fi
fi

# Export variables to ensure they're available to litellm
export LITELLM_MASTER_KEY
export LITELLM_SALT_KEY
export DATABASE_URL
export STORE_MODEL_IN_DB

if [ "$USE_DDTRACE" = "true" ]; then
    export DD_TRACE_OPENAI_ENABLED="False"
    exec ddtrace-run litellm "$@"
else
    exec litellm "$@"
fi