FROM trampgeek/jobeinabox:latest
USER root
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Debug opcional: confirmar versão da base
RUN cat /etc/os-release

# 1) Dependências extras que o Swift precisa
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates curl unzip git nano less procps iproute2 jq \
    build-essential clang libicu-dev libcurl4-openssl-dev libxml2 libsqlite3-0 libedit2 tzdata \
    libncurses6 libtinfo6 libatomic1 libbsd0 \
 && rm -rf /var/lib/apt/lists/*

# 2) Instalar Swift 6.1.2 (Ubuntu 24.04)
ARG SWIFT_TARBALL_URL="https://download.swift.org/swift-6.1.2-release/ubuntu2404/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE-ubuntu24.04.tar.gz"
ARG SWIFT_DIR="/usr/local/swift"

RUN wget -q "${SWIFT_TARBALL_URL}" -O /tmp/swift.tar.gz \
 && tar -xzf /tmp/swift.tar.gz -C /tmp \
 && SWIFT_EXTRACTED="$(tar -tzf /tmp/swift.tar.gz | head -1 | cut -f1 -d"/")" \
 && mv "/tmp/${SWIFT_EXTRACTED}" "${SWIFT_DIR}" \
 && ln -sf "${SWIFT_DIR}/usr/bin/swiftc" /usr/local/bin/swiftc \
 && ln -sf "${SWIFT_DIR}/usr/bin/swift"  /usr/local/bin/swift \
 && rm -f /tmp/swift.tar.gz

# 3) Garantir caches para www-data e jobe00..07
RUN install -d -m 700 -o www-data -g www-data /var/www/.cache/clang/ModuleCache \
 && for i in 00 01 02 03 04 05 06 07; do \
      install -d -m 700 -o jobe$i -g jobe /home/jobe$i/.cache/clang/ModuleCache; \
    done

# 4) Copiar handler do Swift
#    Certifique-se que jobe-langs/SwiftTask.php existe no build context
#    e tem namespace correto: `<?php namespace Jobe; ?>`
COPY jobe-langs/SwiftTask.php /var/www/html/jobe/app/Libraries/SwiftTask.php
RUN chown www-data:www-data /var/www/html/jobe/app/Libraries/SwiftTask.php \
 && chmod 0644 /var/www/html/jobe/app/Libraries/SwiftTask.php

# 5) Forçar rebuild da lista de linguagens
RUN rm -f /tmp/jobe_language_cache_file || true

# 6) Healthcheck: valida se Swift aparece
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD curl -fsS http://localhost/jobe/index.php/restapi/languages | grep -q '"swift"' || exit 1

EXPOSE 80
