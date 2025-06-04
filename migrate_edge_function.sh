#!/bin/bash

# ✅ 修改為你的 self-host 參數
SELF_HOST_PROJECT_URL="http://127.0.0.1:8000"
SELF_HOST_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE"
SELF_HOST_PROJECT_REF="local"

# ✅ 線上 Supabase 專案參數
ONLINE_PROJECT_REF="tiwffegdtaozfjwlfljd"  # 請替換為正確的 ref

# ✅ 匯出目的資料夾
EXPORT_DIR="export_functions"
mkdir -p "$EXPORT_DIR/functions"

echo "== 取得線上 Edge Function 清單 =="

FUNCTION_NAMES=$(supabase functions list --project-ref "$ONLINE_PROJECT_REF" \
  | grep -vE '^\s*(ID|--+)' \
  | awk -F '|' '{ print $3 }' \
  | sed 's/^[ \t]*//;s/[ \t]*$//')

if [[ -z "$FUNCTION_NAMES" ]]; then
  echo "❌ 無法取得函數清單，請檢查 project ref 是否正確"
  exit 1
fi

echo "共取得函數:"
echo "$FUNCTION_NAMES"
echo

echo "== 匯出線上 Edge Functions 到 $EXPORT_DIR/functions =="

for fn in $FUNCTION_NAMES; do
  echo "📦 匯出函數: $fn"
  supabase functions download "$fn" \
    --project-ref "$ONLINE_PROJECT_REF" \
    --overwrite \
    --no-verify-jwt || {
      echo "❌ 匯出失敗: $fn"
      exit 1
    }

  # 移動下載的 function 到 export_functions
  mv "functions/$fn" "$EXPORT_DIR/functions/$fn"
done