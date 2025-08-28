FROM trampgeek/jobeinabox:latest

USER root
SHELL ["/bin/bash","-euo","pipefail","-c"]

# Instalar dependências mínimas para o Swift
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl ca-certificates unzip git \
    build-essential clang \
    libicu-dev libcurl4-openssl-dev libxml2 libsqlite3-0 libedit2 tzdata \
    libncurses6 libtinfo6 libatomic1 libbsd0 \
 && rm -rf /var/lib/apt/lists/*

# Baixar e instalar Swift 6.1.2 (para Ubuntu 24.04)
ARG SWIFT_URL="https://download.swift.org/swift-6.1.2-release/ubuntu2404/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE-ubuntu24.04.tar.gz"
RUN curl -fsSL "$SWIFT_URL" -o /tmp/swift.tar.gz \
 && tar -xzf /tmp/swift.tar.gz -C /usr/local \
 && mv /usr/local/swift-6.1.2-RELEASE-ubuntu24.04 /usr/local/swift \
 && ln -sf /usr/local/swift/usr/bin/swiftc /usr/local/bin/swiftc \
 && ln -sf /usr/local/swift/usr/bin/swift  /usr/local/bin/swift \
 && mkdir -p /usr/lib/swift && ln -sfn /usr/local/swift/usr/lib/swift /usr/lib/swift \
 && swiftc --version \
 && rm -f /tmp/swift.tar.gz

EXPOSE 80
