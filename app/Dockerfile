# ============================================================================
# FastAPI сервис конвертации документов DOC/XLS → DOCX/XLSX
# Python 3.11 + LibreOffice + uvicorn
# ============================================================================
FROM python:3.11-slim

# ── Переменные окружения ───────────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    HOME=/tmp \
    RAW_DATA_DIR=/app/raw_data \
    PREPARED_DATA_DIR=/app/prepared_data \
    LIBREOFFICE_PATH=/usr/bin/soffice \
    API_PORT=8000 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# ── Установка системных зависимостей ───────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # LibreOffice + модули
    libreoffice \
    libreoffice-writer \
    libreoffice-calc \
    # Java для устранения предупреждений javaldx
    openjdk-21-jdk-headless \
    # Графические зависимости для headless-режима
    libx11-6 libxext6 libxrender1 libxt6 libgl1 libsm6 libice6 \
    libxinerama1 libfontconfig1 libdbus-1-3 \
    # Шрифты (критично для корректной конвертации)
    fonts-dejavu-core fonts-liberation fonts-freefont-ttf \
    # Утилиты для отладки
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    # Проверка установки
    && /usr/bin/soffice --version \
    && java -version

# ── Настройка Python-окружения ─────────────────────────────────────────────
WORKDIR /app

# Копируем и устанавливаем зависимости
COPY requirements.txt .
RUN pip install -U pip && \
    pip install -r requirements.txt

# Копируем код приложения
COPY converter.py .
COPY main.py .

# ── Подготовка директорий и прав ───────────────────────────────────────────
# Создаём папки и даём права для пользователя nobody
RUN mkdir -p ${RAW_DATA_DIR} ${PREPARED_DATA_DIR} /tmp && \
    chown -R nobody:nogroup ${RAW_DATA_DIR} ${PREPARED_DATA_DIR} /tmp /app && \
    chmod -R 755 ${RAW_DATA_DIR} ${PREPARED_DATA_DIR} /tmp /app

# ── Запуск ─────────────────────────────────────────────────────────────────
EXPOSE ${API_PORT}

# Переключаемся на непривилегированного пользователя
USER nobody

# Health check для Docker/Kubernetes
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${API_PORT}/health || exit 1

# Запуск через uvicorn
ENTRYPOINT ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
CMD []