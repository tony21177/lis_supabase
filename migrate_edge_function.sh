#!/bin/bash

# ✅ 修改為你的 self-host 參數
SELF_HOST_PROJECT_URL="http://127.0.0.1:8000"
SELF_HOST_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE"   # << 請替換為實際 anon key
SELF_HOST_PROJECT_REF="local"        # 不用變

# ✅ 線上 Supabase 專案參數
ONLINE_PROJECT_REF="tiwffegdtaozfjwlfljd"  # << 替換為線上的 ref，例如 tiwffegdtaozfjwlfljd

echo "== 取得線上 Edge Function 清單 =="

# 自動抓取函數名稱（slug）
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

echo "== 匯出線上 Edge Functions =="

for fn in $FUNCTION_NAMES; do
  echo "📦 匯出函數: $fn"
  supabase functions download "$fn" \
    --project-ref "$ONLINE_PROJECT_REF" \
    --legacy-bundle || {
      echo "❌ 匯出失敗: $fn"
      exit 1
    }
done

echo
echo "== 建立 local config.json =="

for fn in $FUNCTION_NAMES; do
  mkdir -p "functions/$fn/.supabase"
  cat <<EOF > "functions/$fn/.supabase/config.json"
{
  "projectId": "$SELF_HOST_PROJECT_REF",
  "api": {
    "projectUrl": "$SELF_HOST_PROJECT_URL",
    "anonKey": "$SELF_HOST_ANON_KEY"
  }
}
EOF
done

echo
echo "== 部署函數到 Self-host Supabase =="

for fn in $FUNCTION_NAMES; do
  echo "🚀 部署函數: $fn"
  (cd "functions/$fn" && supabase functions deploy "$fn" --no-verify-jwt) || {
    echo "❌ 部署失敗: $fn"
    exit 1
  }
done

echo
echo "✅ 所有函數已成功從線上同步並部署至本機 self-host Supabase"
