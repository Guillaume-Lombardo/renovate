FROM renovate/renovate:latest

USER root

RUN mkdir -p /tmp/renovate/cache \
    && chown -R 1000:1000 /tmp/renovate

COPY config.js /usr/src/app/config.js
COPY --chmod=0755 scripts/add-renovate-member.sh /usr/local/bin/add-renovate-member.sh
COPY --chmod=0755 scripts/run-renovate.sh /usr/local/bin/run-renovate.sh
