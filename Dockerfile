# ============================================================================
# Dockerfile для конвертации документов на Python 3.11
# ============================================================================
FROM python:3.11-slim

# Переменные окружения (включая HOME для LibreOffice)
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    HOME=/tmp \
    RAW_DATA_DIR=/app/raw_data \
    PREPARED_DATA_DIR=/app/prepared_data \
    LIBREOFFICE_PATH=/usr/bin/libreoffice

# Установка LibreOffice + зависимости (включая Java для устранения предупреждений)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # LibreOffice + Java (устраняет ошибку javaldx)
    libreoffice \
    libreoffice-writer \
    libreoffice-calc \
    openjdk-21-jre-headless \
    # Критические зависимости для headless-режима
    libx11-6 libxext6 libxrender1 libxt6 libgl1 libsm6 libice6 libxinerama1 libfontconfig1 libdbus-1-3 \
    # Шрифты
    fonts-dejavu-core fonts-liberation fonts-freefont-ttf \
    # Утилиты
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    # Проверка установки
    && libreoffice --version && java -version

# Установка Python-зависимостей (без xlrd!)
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY converter.py .
RUN chmod +x converter.py

# Настройка прав (создаём /tmp для пользователя nobody)
RUN mkdir -p ${RAW_DATA_DIR} ${PREPARED_DATA_DIR} /tmp && \
    chown -R nobody:nogroup ${RAW_DATA_DIR} ${PREPARED_DATA_DIR} /tmp && \
    chmod -R 755 ${RAW_DATA_DIR} ${PREPARED_DATA_DIR} /tmp

USER nobody

ENTRYPOINT ["python3", "converter.py"]
CMD []
