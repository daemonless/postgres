ARG BASE_VERSION=15
ARG PG_VERSION=17
FROM ghcr.io/daemonless/base:${BASE_VERSION}
ARG PG_VERSION

ARG FREEBSD_ARCH=amd64
ARG PACKAGES="postgresql${PG_VERSION}-server postgresql${PG_VERSION}-client postgresql${PG_VERSION}-contrib"
ARG UPSTREAM_URL="https://www.postgresql.org/docs/release/"
ARG HEALTHCHECK_ENDPOINT="pg_isready -q"

LABEL org.opencontainers.image.title="PostgreSQL ${PG_VERSION}" \
    org.opencontainers.image.description="PostgreSQL ${PG_VERSION} on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/postgres" \
    org.opencontainers.image.url="https://www.postgresql.org/" \
    org.opencontainers.image.documentation="https://www.postgresql.org/docs/${PG_VERSION}/" \
    org.opencontainers.image.licenses="PostgreSQL" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="5432" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.category="Databases" \
    io.daemonless.upstream-url="${UPSTREAM_URL}" \
    io.daemonless.packages="${PACKAGES}"

# Install PostgreSQL
RUN pkg update && \
    pkg install -y ${PACKAGES} && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/*

# Create directories
RUN mkdir -p /var/db/postgres/data${PG_VERSION} /var/run/postgresql /run/secrets /docker-entrypoint-initdb.d && \
    chown -R bsd:bsd /var/db/postgres /var/run/postgresql /run/secrets /docker-entrypoint-initdb.d

# Copy service definitions and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/*/run /etc/cont-init.d/* 2>/dev/null || true

# Store PG version for scripts
RUN echo "${PG_VERSION}" > /var/db/postgres/pg_version

# Extract package version for tagging (e.g., 17.7 or 14.20)
RUN mkdir -p /app && \
    pkg query '%v' postgresql${PG_VERSION}-server | sed 's/_.*$//' > /app/version

ENV PGDATA="/var/db/postgres/data${PG_VERSION}" \
    PG_VERSION="${PG_VERSION}" \
    POSTGRES_USER="postgres" \
    POSTGRES_PASSWORD="" \
    POSTGRES_DB="postgres" \
    POSTGRES_INITDB_ARGS="" \
    POSTGRES_HOST_AUTH_METHOD="scram-sha-256"

EXPOSE 5432
VOLUME /var/db/postgres
