FROM trampgeek/jobeinabox:latest
USER root

# 1) deps essenciais + runtime do Swift (inclui libs que o swiftc precisa)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates unzip curl git nano less procps iproute2 jq \
    build-essential clang libicu-dev libcurl4-openssl-dev libxml2 libsqlite3-0 libedit2 tzdata \
    libncurses6 libtinfo6 \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2) Swift 6.1.2 (Ubuntu 24.04, amd64)
RUN wget -q https://download.swift.org/swift-6.1.2-release/ubuntu2404/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE-ubuntu24.04.tar.gz \
 && tar -xzf swift-6.1.2-RELEASE-ubuntu24.04.tar.gz \
 && mv swift-6.1.2-RELEASE-ubuntu24.04 /usr/local/swift-6.1.2 \
 && ln -sf /usr/local/swift-6.1.2/usr/bin/swiftc /usr/local/bin/swiftc \
 && ln -sf /usr/local/swift-6.1.2/usr/bin/swift  /usr/local/bin/swift \
 && rm -f swift-6.1.2-RELEASE-ubuntu24.04.tar.gz

# 3) sandboxes + cache do clang (Swift precisa escrever em ModuleCache)
RUN groupadd -r jobe || true \
 && chmod 755 /home \
 && for i in 00 01 02 03 04 05 06 07; do \
      id jobe$i >/dev/null 2>&1 || useradd -m -s /usr/sbin/nologin -g jobe jobe$i; \
      install -d -m 700 -o jobe$i -g jobe /home/jobe$i/.cache/clang/ModuleCache; \
      chown -R jobe$i:jobe /home/jobe$i/.cache; \
      chmod -R 700 /home/jobe$i/.cache; \
    done

# 4) copia o handler do Swift do PRÓPRIO repositório
#    (mantenha jobe-langs/SwiftTask.php no repo)
COPY jobe-langs/SwiftTask.php /var/www/html/jobe/app/Libraries/SwiftTask.php
RUN chown www-data:www-data /var/www/html/jobe/app/Libraries/SwiftTask.php \
 && chmod 0644 /var/www/html/jobe/app/Libraries/SwiftTask.php

# 5) limpeza final + healthcheck
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD curl -fsS http://localhost/jobe/index.php/restapi/languages || exit 1

EXPOSE 80