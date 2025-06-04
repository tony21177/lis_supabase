#!/bin/bash

# 需先安裝supabase CLI工具
# npm install supabase --save-dev


# === 設定參數 ===
ONLINE_PROJECT_REF="tiwffegdtaozfjwlfljd"               # 替換成你的線上 Supabase 專案 ID
ONLINE_SUPABASE_URL="https://$ONLINE_PROJECT_REF.supabase.co"
ONLINE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpd2ZmZWdkdGFvemZqd2xmbGpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxNjY5MjMsImV4cCI6MjA2MTc0MjkyM30.__LxwO0vhhoWiA5ADY8Lm9O698bpXgfyuGzqhbMwgPk"                # 替換成線上 supabase 的 anon key

SELF_HOST_SUPABASE_URL="http://127.0.0.1:8000"         # 替換成你自架 Supabase 的 URL
SELF_HOST_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE"          # 替換成你自架的 anon key

# === 建立匯出資料夾 ===
mkdir -p supabase_export/functions
cd supabase_export

echo "== 登入線上 Supabase 專案 =="
supabase link --project-ref $ONLINE_PROJECT_REF
supabase functions list > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "❌ 無法從線上 Supabase 取得函數，請確認你的連線與權限"
  exit 1
fi

echo "== 匯出線上 Edge Functions =="
supabase functions list --project-ref $ONLINE_PROJECT_REF | tail -n +2 | awk '{print $1}' | while read function_name; do
  echo "📦 匯出函數: $function_name"
  mkdir -p "functions/$function_name"
  supabase functions download "$function_name" --project-ref $ONLINE_PROJECT_REF --target "functions/$function_name"
done

echo "== 切換連線到 Self-host Supabase =="
supabase link --project-ref local --project-url $SELF_HOST_SUPABASE_URL --anon-key $SELF_HOST_ANON_KEY

echo "== 部署 Edge Functions 到 Self-host Supabase =="
for fn_dir in functions/*; do
  fn_name=$(basename "$fn_dir")
  echo "🚀 部署函數: $fn_name"
  supabase functions deploy "$fn_name"
done

echo "✅ 所有函數已成功遷移完成！"