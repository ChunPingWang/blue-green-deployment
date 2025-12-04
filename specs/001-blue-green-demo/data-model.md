# 資料模型：藍綠佈署展示系統

**功能分支**: `001-blue-green-demo`
**日期**: 2025-12-04

## 概述

本功能為展示用途的微服務系統，不涉及持久化資料儲存。以下描述系統中的概念模型和配置結構。

## 實體定義

### 1. 問候回應 (GreetingResponse)

API 回應的資料結構。

| 欄位 | 類型 | 說明 |
|------|------|------|
| message | 字串 | 問候訊息 |

**回應值**:
- Blue Service: `"Greeting from Blue Service"`
- Green Service: `"Greeting from Green Service"`

### 2. 路由配置 (RouteConfig)

Spring Cloud Gateway 的路由設定。

| 欄位 | 類型 | 說明 |
|------|------|------|
| id | 字串 | 路由識別碼 |
| uri | 字串 | 目標服務 URL |
| predicates | 陣列 | 路由條件 |

**路由規則**:
| 路由 ID | 目標 | 權重 | 比例 |
|---------|------|------|------|
| blue-service | http://localhost:8081 | 2 | 20% |
| green-service | http://localhost:8082 | 8 | 80% |

### 3. 服務配置 (ServiceConfig)

各微服務的基本配置。

| 服務 | 端口 | 應用名稱 |
|------|------|----------|
| API Gateway | 8080 | api-gateway |
| Blue Service | 8081 | blue-service |
| Green Service | 8082 | green-service |

## 資料流程

```text
┌─────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Client  │ ──▶ │   API Gateway   │ ──▶ │  Blue/Green     │
│         │     │   (Port 8080)   │     │  Service        │
└─────────┘     └─────────────────┘     └─────────────────┘
    │                   │                       │
    │   GET /greeting   │                       │
    │──────────────────▶│   Weight: 2 (20%)    │
    │                   │──────────────────────▶│ Blue (8081)
    │                   │                       │
    │                   │   Weight: 8 (80%)    │
    │                   │──────────────────────▶│ Green (8082)
    │                   │                       │
    │◀──────────────────│◀──────────────────────│
    │    Response       │      Response         │
```

## 狀態轉換

### 請求處理狀態

```text
[接收請求] ──▶ [路由判斷] ──▶ [轉發至後端] ──▶ [回傳回應]
                  │                │
                  │                ▼
                  │         [後端不可用]
                  │                │
                  ▼                ▼
            [路徑不存在]     [503 錯誤]
                  │
                  ▼
            [404 錯誤]
```

## 健康檢查

### 端點定義

| 服務 | 健康檢查 URL |
|------|-------------|
| API Gateway | http://localhost:8080/actuator/health |
| Blue Service | http://localhost:8081/actuator/health |
| Green Service | http://localhost:8082/actuator/health |

### 健康狀態

| 狀態 | HTTP Code | 說明 |
|------|-----------|------|
| UP | 200 | 服務正常 |
| DOWN | 503 | 服務異常 |
