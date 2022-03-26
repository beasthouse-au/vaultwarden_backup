ARG ARCH=
FROM ${ARCH}alpine:latest

LABEL org.opencontainers.image.source = "https://github.com/fabricionaweb/vaultwarden_backup"

RUN apk add --no-cache tar xz tzdata sqlite

ENV TZ Europe/London
ENV CRON_TIME 0 */12 * * *
ENV DELETE_AFTER 0

VOLUME /backups
WORKDIR /app
COPY entrypoint.sh script.sh ./

ENTRYPOINT ["./entrypoint.sh"]
