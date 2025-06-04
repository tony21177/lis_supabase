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

  # 建立暫時工作目錄
  TEMP_DIR="$EXPORT_DIR/temp_$fn"
  mkdir -p "$TEMP_DIR"

  # 初始化 supabase 專案（避免 CLI 下載失敗）
  (cd "$TEMP_DIR" && supabase init > /dev/null)

  # 下載函數
  supabase functions download "$fn" \
    --project-ref "$ONLINE_PROJECT_REF" \
    --workdir "$TEMP_DIR" || {
      echo "❌ 匯出失敗: $fn"
      exit 1
    }

  # 移動函數資料夾到 export_functions/functions/<fn>
  mkdir -p "$EXPORT_DIR/functions/$fn"
  mv "$TEMP_DIR/.supabase/functions/$fn"/* "$EXPORT_DIR/functions/$fn" 2>/dev/null

  # 清除暫時目錄
  rm -rf "$TEMP_DIR"
done

echo
echo "✅ 所有函數已成功下載至 $EXPORT_DIR/functions/"