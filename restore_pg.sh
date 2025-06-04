#!/bin/bash


# psql -h 127.0.0.1 -p 5434 -U postgres -d postgres

# 以superuser身份連接到本地 PostgreSQL 資料庫
# psql -h 127.0.0.1 -p 5434 -U supabase_admin -d postgres


set -e  # 一旦有錯誤就中止腳本

PGHOST=127.0.0.1
PGPORT=5434
# PGUSER=postgres
PGUSER=supabase_admin
PGDATABASE=postgres
BACKUP_FILE="backup.dump"

# 確保你已經設定了 PGPASSWORD 環境變數，或在還原時會提示輸入密碼
export PGPASSWORD=your-super-secret-and-long-postgres-password

pg_restore \
  --clean \
  --no-owner \
  --host=$PGHOST \
  --port=$PGPORT \
  --username=$PGUSER \
  --dbname=$PGDATABASE \
  --verbose \
  "$BACKUP_FILE"
