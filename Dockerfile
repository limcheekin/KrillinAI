FROM alpine:latest as builder

# 安装基础工具并创建目录
WORKDIR /build
RUN apk add --no-cache wget && \
    mkdir -p bin && \
    ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) \
            URL="https://github.com/yt-dlp/yt-dlp/releases/download/2025.01.15/yt-dlp_linux"; \
            BIN_URL="https://github.com/krillinai/KrillinAI/releases/download/v1.1.3/KrillinAI_1.1.3_Linux_x86_64"; \
            ;; \
        armv7l) \
            URL="https://github.com/yt-dlp/yt-dlp/releases/download/2025.01.15/yt-dlp_linux_armv7l"; \
            BIN_URL="https://github.com/krillinai/KrillinAI/releases/download/v1.1.3/KrillinAI_1.1.3_Linux_arm64"; \
            ;; \
        aarch64) \
            URL="https://github.com/yt-dlp/yt-dlp/releases/download/2025.01.15/yt-dlp_linux_aarch64"; \
            BIN_URL="https://github.com/krillinai/KrillinAI/releases/download/v1.1.3/KrillinAI_1.1.3_Linux_arm64"; \
            ;; \
        *) \
            echo "Unsupported architecture: $ARCH" && exit 1; \
            ;; \
    esac && \
    wget -O bin/yt-dlp "$URL" && \
    chmod +x bin/yt-dlp && \
    wget -O bin/KrillinAI "$BIN_URL" && \
    chmod +x bin/KrillinAI

# 最终镜像
FROM jrottenberg/ffmpeg:6.1-alpine

# 设置工作目录并复制文件
WORKDIR /app
COPY --from=builder /build/bin /app/bin

# 创建必要目录并设置权限
RUN mkdir -p /app/models

# 声明卷
VOLUME ["/app/bin", "/app/models"]

# 设置环境变量
ENV PATH="/app/bin:${PATH}"

# 设置端口
EXPOSE 8888/tcp

# 设置入口点
ENTRYPOINT ["/app/bin/KrillinAI"]