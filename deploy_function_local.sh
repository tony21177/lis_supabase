#!/bin/bash

# 本地 Supabase 函數容器名稱，請依實際情況修改
CONTAINER_NAME="supabase-edge-functions"

# 容器內函數目錄，請依實際情況修改
CONTAINER_FUNCTIONS_DIR="/home/supabase/functions"

FUNCTIONS_DIR="export_functions"

# 檢查 supabase CLI 是否存在
if ! command -v supabase &> /dev/null; then
  echo "Error: supabase CLI 未安裝"
  exit 1
fi

# 檢查 Docker 是否存在
if ! command -v docker &> /dev/null; then
  echo "Error: Docker 未安裝或無法使用"
  exit 1
fi

# 檢查容器是否存在並運行中
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Error: 找不到正在運行的 Docker container: $CONTAINER_NAME"
  exit 1
fi

echo "開始建置與部署 Edge Functions..."

for func_path in "$FUNCTIONS_DIR"/*; do
  if [ -d "$func_path" ]; then
    func_name=$(basename "$func_path")
    echo "Building function: $func_name"
    supabase functions build "$func_name"
    if [ $? -ne 0 ]; then
      echo "建置 $func_name 失敗，跳過"
      continue
    fi

    ESZIP_PATH="./functions/$func_name/$func_name.eszip"
    if [ ! -f "$ESZIP_PATH" ]; then
      echo "找不到 ESZIP 檔案：$ESZIP_PATH，跳過"
      continue
    fi

    echo "Copy $func_name.eszip 到容器 $CONTAINER_NAME"
    docker cp "$ESZIP_PATH" "$CONTAINER_NAME":"$CONTAINER_FUNCTIONS_DIR/"

    if [ $? -ne 0 ]; then
      echo "複製 $func_name.eszip 失敗"
      continue
    fi

    echo "$func_name 部署完成"
    echo "--------------------------"
  fi
done

echo "重啟函數容器: $CONTAINER_NAME"
docker restart "$CONTAINER_NAME"

echo "全部部署完成！"
