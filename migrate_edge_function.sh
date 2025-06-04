#!/bin/bash

# 需先安裝supabase CLI工具
# curl -L -o supabase_2.24.3_linux_amd64.deb https://github.com/supabase/cli/releases/download/v2.24.3/supabase_2.24.3_linux_amd64.deb
# sudo dpkg -i supabase_2.24.3_linux_amd64.deb

# 需要先supabase login會開啟網頁登入取得Verification code
# 然後在終端機輸入驗證碼

# === 設定參數 ===
ONLINE_PROJECT_REF="tiwffegdtaozfjwlfljd"               # 替換成你的線上 Supabase 專案 ID
ONLINE_SUPABASE_URL="https://$ONLINE_PROJECT_REF.supabase.co"
ONLINE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpd2ZmZWdkdGFvemZqd2xmbGpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxNjY5MjMsImV4cCI6MjA2MTc0MjkyM30.__LxwO0vhhoWiA5ADY8Lm9O698bpXgfyuGzqhbMwgPk"

SELF_HOST_SUPABASE_URL="http://127.0.0.1:8000"         # 替換成你自架 Supabase 的 URL
SELF_HOST_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE"

# === 建立匯出資料夾 ===
EXPORT_DIR="supabase_export/functions"
mkdir -p "$EXPORT_DIR"

# === 匯出線上 Edge Functions ===
echo "== 登入並連結線上 Supabase 專案 =="
supabase link --project-ref "$ONLINE_PROJECT_REF"
if ! supabase functions list --project-ref "$ONLINE_PROJECT_REF" > /dev/null 2>&1; then
  echo "❌ 無法從線上 Supabase 取得函數，請確認登入與權限"
  exit 1
fi

echo "== 匯出 Edge Functions =="
supabase functions list --project-ref "$ONLINE_PROJECT_REF" | tail -n +2 | awk '{print $1}' | while read -r function_name; do
  echo "📦 匯出函數: $function_name"
  mkdir -p "$EXPORT_DIR/$function_name"
  supabase functions download "$function_name" --project-ref "$ONLINE_PROJECT_REF" --legacy-bundle --workdir "$EXPORT_DIR/$function_name"
done

# === 切換連結至 Self-host Supabase ===
echo "== 切換連線到 Self-host Supabase =="
supabase link --project-ref local --project-url "$SELF_HOST_SUPABASE_URL" --anon-key "$SELF_HOST_ANON_KEY"

# === 部署 Edge Functions ===
echo "== 部署 Edge Functions 到 Self-host Supabase =="
for fn_dir in "$EXPORT_DIR"/*; do
  fn_name=$(basename "$fn_dir")
  echo "🚀 部署函數: $fn_name"
  supabase functions deploy "$fn_name" --project-ref local --workdir "$fn_dir"
done

echo "✅ 所有函數已成功遷移完成！"

# 備註：請確認 self-host 環境已啟動 supabase local instance (supabase start)
