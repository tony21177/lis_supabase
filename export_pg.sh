#!/bin/bash
# 設定密碼為環境變數
export PGPASSWORD='SX5FBqgJiqv992FQ'

# 執行 pg_dump 匯出整個 database（含 schema 和資料）
# pg_dump -h db.tiwffegdtaozfjwlfljd.supabase.co \
#   -U postgres \
#   -d postgres \
#   -p 5432 \
#   -Fc \
#   -f supabase_backup.dump

# psql "postgres://postgres.tiwffegdtaozfjwlfljd:'SX5FBqgJiqv992FQ'@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres"


pg_dump -h aws-0-ap-southeast-1.pooler.supabase.com -p 5432 -U postgres.tiwffegdtaozfjwlfljd -d postgres -F c -f backup.dump

