# 部屬self hosted supabase
1. 修改.env
    * KONG_HTTP_PORT=8000  // 為supabase studio頁面的port 
    * DASHBOARD_USERNAME=lis // supabase studio的帳號
    * DASHBOARD_PASSWORD=Lis1234 // supabase studio的密碼
2. 執行docker compose up -d
3. 開啟瀏覽器輸入 http://localhost:8000

# export 線上supabase資料庫
1. bash export.sh

# import 線上supabase資料庫到本地
1. bash import.sh

# 遷移 supabase edge function
1. 
