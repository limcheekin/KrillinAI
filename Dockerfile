FROM alpine:latest as builder

# 安装基础工具并创建目录
WORKDIR /build
RUN apk add --no-cache wget && \
    mkdir -p bin && \
    ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) \
            URL="https://github.com/krillinai/KrillinAI/releases/download/v1.1.3/KrillinAI_1.1.3_Linux_x86_64"; \
            ;; \
        armv7l) \
            URL="https://github.com/krillinai/KrillinAI/releases/download/v1.1.3/KrillinAI_1.1.3_Linux_arm64"; \
            ;; \
        aarch64) \
            URL="https://github.com/krillinai/KrillinAI/releases/download/v1.1.3/KrillinAI_1.1.3_Linux_arm64"; \
            ;; \
        *) \
            echo "Unsupported architecture: $ARCH" && exit 1; \
            ;; \
    esac && \
    wget -O bin/KrillinAI "$URL" && \
    chmod +x bin/KrillinAI

# 最终镜像
FROM linuxserver/ffmpeg

# 设置工作目录并复制文件
WORKDIR /app
COPY --from=builder /build/bin /app

# 设置端口
EXPOSE 8888/tcp

# 设置入口点
ENTRYPOINT ["./KrillinAI"]