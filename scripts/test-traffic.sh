#!/usr/bin/env bash
#
# test-traffic.sh - 藍綠佈署流量測試腳本
#
# 用途: 對 API 閘道發送多次請求，統計藍色服務和綠色服務的流量分配
# 用法: ./test-traffic.sh [請求次數]
#

set -euo pipefail

# ============================================
# 配置
# ============================================
readonly GATEWAY_URL="${GATEWAY_URL:-http://localhost:8080}"
readonly ENDPOINT="/greeting"
readonly DEFAULT_REQUEST_COUNT=100
readonly TIMEOUT=5

# ============================================
# 顏色與符號定義
# ============================================
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# ============================================
# T003: 使用說明函式
# ============================================
show_usage() {
    cat << EOF
${BOLD}藍綠佈署流量測試腳本${NC}

${BOLD}用法:${NC}
    $0 [請求次數]

${BOLD}參數:${NC}
    請求次數    要發送的 HTTP 請求數量（預設: ${DEFAULT_REQUEST_COUNT}）

${BOLD}範例:${NC}
    $0          # 使用預設值發送 ${DEFAULT_REQUEST_COUNT} 次請求
    $0 50       # 發送 50 次請求
    $0 500      # 發送 500 次請求

${BOLD}環境變數:${NC}
    GATEWAY_URL  API 閘道的基礎 URL（預設: http://localhost:8080）

${BOLD}說明:${NC}
    此腳本會對 API 閘道的 /greeting 端點發送多次請求，
    並統計來自藍色服務和綠色服務的回應數量與比例。
EOF
}

# ============================================
# T004: 參數驗證邏輯
# ============================================
validate_request_count() {
    local count="$1"

    # 檢查是否為正整數
    if ! [[ "$count" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "${RED}❌ 錯誤：請求次數必須為正整數。${NC}" >&2
        echo "" >&2
        show_usage >&2
        exit 1
    fi
}

# ============================================
# T005: curl 可用性檢查
# ============================================
check_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ 錯誤：找不到 curl。請先安裝 curl。${NC}" >&2
        echo "" >&2
        echo "安裝方式:" >&2
        echo "  Ubuntu/Debian: sudo apt-get install curl" >&2
        echo "  macOS: brew install curl" >&2
        echo "  CentOS/RHEL: sudo yum install curl" >&2
        exit 1
    fi
}

# ============================================
# T006: 閘道連線測試函式
# ============================================
test_gateway_connection() {
    local url="${GATEWAY_URL}${ENDPOINT}"

    echo -e "${YELLOW}正在測試 API 閘道連線...${NC}"

    if ! curl -s -o /dev/null -w "%{http_code}" --connect-timeout "${TIMEOUT}" "${url}" &> /dev/null; then
        echo -e "${RED}❌ 錯誤：無法連線到 API 閘道（${url}）${NC}" >&2
        echo "" >&2
        echo "請確認:" >&2
        echo "  1. API Gateway 服務已啟動" >&2
        echo "  2. 服務正在監聽正確的端口" >&2
        echo "  3. 沒有防火牆阻擋連線" >&2
        exit 1
    fi

    echo -e "${GREEN}✓ API 閘道連線成功${NC}"
    echo ""
}

# ============================================
# T007: 請求迴圈與回應收集邏輯
# ============================================
declare -a responses=()

send_requests() {
    local count="$1"
    local url="${GATEWAY_URL}${ENDPOINT}"

    for ((i=1; i<=count; i++)); do
        local response
        response=$(curl -s --connect-timeout "${TIMEOUT}" "${url}" 2>/dev/null || echo "ERROR")
        responses+=("$response")

        # T010: 更新進度指示器
        show_progress "$i" "$count"
    done

    echo ""  # 進度條結束後換行
}

# ============================================
# T008: 回應來源判斷（Blue/Green/Unknown）
# ============================================
determine_source() {
    local response="$1"

    if [[ "$response" == *"Blue"* ]]; then
        echo "BLUE"
    elif [[ "$response" == *"Green"* ]]; then
        echo "GREEN"
    elif [[ "$response" == "ERROR" ]]; then
        echo "FAILED"
    else
        echo "UNKNOWN"
    fi
}

# ============================================
# T009: 統計計算邏輯（計數與百分比）
# ============================================
calculate_statistics() {
    local total=${#responses[@]}
    local blue_count=0
    local green_count=0
    local failed_count=0
    local unknown_count=0

    for response in "${responses[@]}"; do
        local source
        source=$(determine_source "$response")

        case "$source" in
            "BLUE")    ((blue_count++)) ;;
            "GREEN")   ((green_count++)) ;;
            "FAILED")  ((failed_count++)) ;;
            "UNKNOWN") ((unknown_count++)) ;;
        esac
    done

    # 計算百分比（使用 awk 進行浮點運算）
    local blue_pct green_pct failed_pct
    blue_pct=$(awk "BEGIN {printf \"%.1f\", ($blue_count / $total) * 100}")
    green_pct=$(awk "BEGIN {printf \"%.1f\", ($green_count / $total) * 100}")
    failed_pct=$(awk "BEGIN {printf \"%.1f\", ($failed_count / $total) * 100}")

    # 輸出統計結果（供其他函式使用）
    echo "${blue_count}|${green_count}|${failed_count}|${unknown_count}|${blue_pct}|${green_pct}|${failed_pct}|${total}"
}

# ============================================
# T010: 進度指示器（執行中進度條）
# ============================================
show_progress() {
    local current="$1"
    local total="$2"
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    # 建立進度條
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    # 使用 \r 覆蓋同一行
    printf "\r執行中... [%s] %3d%% (%d/%d)" "$bar" "$percentage" "$current" "$total"
}

# ============================================
# T011: 統計報告輸出格式
# ============================================
show_report() {
    local stats="$1"
    local elapsed="$2"

    # 解析統計數據
    IFS='|' read -r blue_count green_count failed_count unknown_count blue_pct green_pct failed_pct total <<< "$stats"

    echo ""
    echo -e "${BOLD}📊 結果統計${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "${BLUE}🔵 Blue Service:  %4d 次 (%5s%%)${NC}\n" "$blue_count" "$blue_pct"
    printf "${GREEN}🟢 Green Service: %4d 次 (%5s%%)${NC}\n" "$green_count" "$green_pct"

    if [[ "$failed_count" -gt 0 ]]; then
        printf "${RED}❌ 失敗:          %4d 次 (%5s%%)${NC}\n" "$failed_count" "$failed_pct"
    fi

    if [[ "$unknown_count" -gt 0 ]]; then
        printf "${YELLOW}❓ 未知:          %4d 次${NC}\n" "$unknown_count"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "總計: ${total} 次 | 耗時: ${elapsed} 秒"
}

# ============================================
# T012: 執行時間計算與顯示
# ============================================
get_elapsed_time() {
    local start="$1"
    local end="$2"

    awk "BEGIN {printf \"%.1f\", $end - $start}"
}

# ============================================
# T013: 錯誤處理（閘道未啟動、請求失敗）
# ============================================
handle_error() {
    local error_type="$1"
    local message="$2"

    echo -e "${RED}❌ 錯誤：${message}${NC}" >&2
    exit 1
}

# ============================================
# 主程式
# ============================================
main() {
    # 處理 --help 或 -h 參數
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        show_usage
        exit 0
    fi

    # T005: 檢查 curl
    check_curl

    # 取得請求次數
    local request_count="${1:-$DEFAULT_REQUEST_COUNT}"

    # T004: 驗證參數
    validate_request_count "$request_count"

    # 顯示標題
    echo ""
    echo -e "${BOLD}🔵 測試藍綠佈署流量分配${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "端點: ${GATEWAY_URL}${ENDPOINT}"
    echo -e "請求次數: ${request_count}"
    echo ""

    # T006: 測試閘道連線
    test_gateway_connection

    # T012: 記錄開始時間
    local start_time
    start_time=$(date +%s.%N)

    # T007: 發送請求
    send_requests "$request_count"

    # T012: 記錄結束時間
    local end_time
    end_time=$(date +%s.%N)

    # T012: 計算耗時
    local elapsed
    elapsed=$(get_elapsed_time "$start_time" "$end_time")

    # T009: 計算統計
    local stats
    stats=$(calculate_statistics)

    # T011: 顯示報告
    show_report "$stats" "$elapsed"

    echo ""
}

# 執行主程式
main "$@"
