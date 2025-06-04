#!/bin/bash

CONTAINER_NAME="supabase-edge-functions"
CONTAINER_FUNCTIONS_DIR="/home/supabase/functions"

# Supabase 專案根目錄是 export_functions/supabase
SUPABASE_PROJECT_DIR="./export_functions/supabase"

if ! command -v supabase &> /dev/null; then
  echo "Error: supabase CLI 未安裝"
  exit 1
fi

if ! command -v docker &> /dev/null; then
  echo "Error: Docker 未安裝或無法使用"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Error: 找不到正在運行的 Docker container: $CONTAINER_NAME"
  exit 1
fi

echo "開始建置與部署 Edge Functions..."

for func_path in "$SUPABASE_PROJECT_DIR/functions"/*; do
  if [ -d "$func_path" ]; then
    func_name=$(basename "$func_path")
    echo "Building function: $func_name"

    # 進入 supabase project 目錄建置函數
    (cd "$SUPABASE_PROJECT_DIR" && supabase functions build "$func_name")

    ESZIP_PATH="$SUPABASE_PROJECT_DIR/functions/$func_name/$func_name.eszip"
    if [ ! -f "$ESZIP_PATH" ]; then
      echo "找不到 ESZIP 檔案：$ESZIP_PATH，跳過"
      continue
    fi

    echo "Copy $func_name.eszip 到容器 $CONTAINER_NAME"
    docker cp "$ESZIP_PATH" "$CONTAINER_NAME":"$CONTAINER_FUNCTIONS_DIR/"

    echo "$func_name 部署完成"
    echo "--------------------------"
  fi
done

echo "重啟函數容器: $CONTAINER_NAME"
docker restart "$CONTAINER_NAME"

echo "全部部署完成！"
