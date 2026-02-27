# Document Converter (Python 3.11)

Конвертирует `.doc` → `.docx` и `.xls` → `.xlsx` с сохранением структуры папок.

## 🚀 Запуск

```bash
# 1. Подготовка
mkdir -p raw_data prepared_data
cp ~/документы/*.doc raw_data/
cp ~/таблицы/*.xls raw_data/

# 2. Сборка и запуск
docker-compose up --build

# 3. Результаты
ls -lh prepared_data/