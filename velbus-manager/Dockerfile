# https://contributors.home-assistant.io/apps/guides/dockerfile/
# Expects pre-built binaries under velbusapi/${BUILD_ARCH}/ (see scripts/build-velbusapi.sh).
ARG BUILD_FROM
ARG BUILD_ARCH
ARG BUILD_VERSION
ARG BUILD_REF

FROM ${BUILD_FROM}

ARG BUILD_ARCH
ARG BUILD_VERSION
ARG BUILD_REF
ARG BUILD_NAME
ARG BUILD_DESCRIPTION

RUN apk add --no-cache jq icu-libs

COPY velbusapi/${BUILD_ARCH}/ /app/
COPY rootfs /

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.source="https://github.com/cereal2nd/hassio-velbus-manager" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}"