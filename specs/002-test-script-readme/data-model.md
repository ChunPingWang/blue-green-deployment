# 資料模型：測試腳本與專案文件

**功能分支**: `002-test-script-readme`
**日期**: 2025-12-04

## 概述

本功能為工具腳本，不涉及持久化資料儲存。以下描述腳本執行時的暫態資料結構。

## 實體定義

### 1. 測試配置 (TestConfig)

腳本執行時的配置參數。

| 欄位 | 類型 | 預設值 | 說明 |
|------|------|--------|------|
| gateway_url | 字串 | `http://localhost:8080` | API 閘道基礎 URL |
| endpoint | 字串 | `/greeting` | 測試端點路徑 |
| request_count | 整數 | `100` | 請求次數 |
| timeout | 整數 | `5` | 單一請求逾時秒數 |

**驗證規則**:
- `request_count` 必須為正整數 (> 0)
- `gateway_url` 必須為有效 URL 格式
- `timeout` 必須為正整數 (> 0)

### 2. 請求結果 (RequestResult)

單一請求的回應資料。

| 欄位 | 類型 | 說明 |
|------|------|------|
| response_body | 字串 | 回應內容 |
| http_status | 整數 | HTTP 狀態碼 |
| source_service | 列舉 | `BLUE` / `GREEN` / `UNKNOWN` |
| success | 布林 | 請求是否成功 |

**判斷邏輯**:
- `source_service = BLUE` 當 `response_body` 包含 "Blue"
- `source_service = GREEN` 當 `response_body` 包含 "Green"
- `source_service = UNKNOWN` 其他情況

### 3. 統計報告 (StatisticsReport)

測試完成後的統計結果。

| 欄位 | 類型 | 說明 |
|------|------|------|
| total_requests | 整數 | 總請求數 |
| blue_count | 整數 | 藍色服務回應數 |
| green_count | 整數 | 綠色服務回應數 |
| failed_count | 整數 | 失敗請求數 |
| blue_percentage | 浮點數 | 藍色服務比例 |
| green_percentage | 浮點數 | 綠色服務比例 |
| failed_percentage | 浮點數 | 失敗比例 |
| elapsed_time | 浮點數 | 執行總時間（秒） |

**計算公式**:
```
blue_percentage = (blue_count / total_requests) * 100
green_percentage = (green_count / total_requests) * 100
failed_percentage = (failed_count / total_requests) * 100
```

## 資料流程

```text
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ TestConfig  │ ──▶ │ 執行請求    │ ──▶ │ RequestResult │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                                                │ 累積
                                                ▼
                                        ┌─────────────────┐
                                        │ StatisticsReport │
                                        └─────────────────┘
```

## 狀態轉換

腳本執行狀態：

```text
[初始化] ──▶ [驗證參數] ──▶ [執行測試] ──▶ [產生報告] ──▶ [完成]
    │              │              │
    ▼              ▼              ▼
 [錯誤退出]    [錯誤退出]    [部分失敗]
```

## README 文件結構

| 章節 | 必要性 | 說明 |
|------|--------|------|
| 專案標題 | 必要 | 專案名稱與一句話說明 |
| 簡介 | 必要 | 專案目的與藍綠佈署概念 |
| 架構說明 | 必要 | 三個微服務的關係圖 |
| 前置需求 | 必要 | 執行環境需求 |
| 快速開始 | 必要 | 啟動服務的步驟 |
| 測試說明 | 必要 | 測試腳本使用方式 |
| 專案結構 | 選用 | 目錄結構說明 |
