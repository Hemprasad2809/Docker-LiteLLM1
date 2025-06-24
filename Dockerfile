FROM litellm-base:latest

WORKDIR /app

COPY config.yaml /app/config.yaml

EXPOSE 4000
ENV TELEMETRY=False
ENV PORT=4000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:4000/health || exit 1

CMD ["litellm", "--config", "/app/config.yaml", "--port", "4000"] 