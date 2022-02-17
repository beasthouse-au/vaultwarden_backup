ARG ARCH=
FROM ${ARCH}alpine:latest

RUN apk add --no-cache xz tzdata

ENV CRON_TIME "0 */12 * * *"
ENV DELETE_AFTER 0
VOLUME /backups

WORKDIR /app
COPY entrypoint.sh script.sh ./

ENTRYPOINT ["./entrypoint.sh"]
