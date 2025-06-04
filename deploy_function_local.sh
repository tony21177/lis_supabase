#!/bin/bash

# deploy_functions.sh
# 功能：將 export_functions 資料夾內的所有 Edge Functions 部署到本地 Supabase

FUNCTIONS_DIR="export_functions"

# 確認 supabase CLI 是否存在
if ! command -v supabase &> /dev/null
then
    echo "Error: supabase CLI 未安裝或無法使用"
    exit 1
fi


echo "開始部署 Edge Functions..."

# 迴圈讀取函數資料夾
for func_path in "$FUNCTIONS_DIR"/*; do
    if [ -d "$func_path" ]; then
        func_name=$(basename "$func_path")
        echo "部署函數：$func_name"
        supabase functions deploy "$func_name" --local

        if [ $? -ne 0 ]; then
            echo "部署 $func_name 失敗，請檢查錯誤訊息"
        else
            echo "$func_name 部署成功"
        fi
        echo "------------------------------"
    fi
done

echo "全部函數部署完成！"
