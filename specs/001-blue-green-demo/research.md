# 研究報告：藍綠佈署展示系統

**功能分支**: `001-blue-green-demo`
**日期**: 2025-12-04

## 研究項目

### 1. Spring Cloud Gateway 加權路由實作方式

**決策**: 使用 Spring Cloud Gateway 內建的 Weight 路由謂詞（Predicate）

**理由**:
- Spring Cloud Gateway 原生支援加權路由，無需額外開發
- 配置簡單，僅需在 YAML 中定義權重
- 效能優異，基於 Netty 的非阻塞架構

**考慮的替代方案**:
| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| Nginx 加權 | 成熟穩定 | 需要額外基礎設施 | 不採用 |
| 自訂 Filter | 完全控制 | 開發成本高、易出錯 | 不採用 |
| LoadBalancer | 動態調整 | 需要服務發現 | 過度複雜 |
| Weight Predicate | 原生支援 | 權重固定 | ✅ 採用 |

**實作方式**:
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: blue-service
          uri: http://localhost:8081
          predicates:
            - Path=/greeting
            - Weight=group1, 2
        - id: green-service
          uri: http://localhost:8082
          predicates:
            - Path=/greeting
            - Weight=group1, 8
```

### 2. Gradle 多專案架構

**決策**: 採用 Gradle 多專案（Multi-project）架構

**理由**:
- 統一管理依賴版本
- 可共享建置邏輯
- 支援獨立建置和測試
- 與 Spring Boot 整合良好

**專案結構**:
```
settings.gradle    # 定義子專案
build.gradle       # 共用建置配置
spring-cloud-gateway/build.gradle
blue-service/build.gradle
green-service/build.gradle
```

### 3. 測試策略

**決策**: 採用 JUnit 5 + Spring Boot Test + MockMvc

**理由**:
- Spring Boot Test 提供完整的測試支援
- MockMvc 可在不啟動完整伺服器的情況下測試 Controller
- JUnit 5 提供現代化的測試 API

**測試類型**:
| 類型 | 工具 | 範圍 |
|------|------|------|
| 單元測試 | JUnit 5 | Controller 方法 |
| 整合測試 | Spring Boot Test | API 端點 |
| 契約測試 | MockMvc | HTTP 回應格式 |

### 4. 健康檢查機制

**決策**: 使用 Spring Boot Actuator

**理由**:
- 零配置即可啟用
- 提供標準 `/actuator/health` 端點
- 可輕鬆擴展自訂健康指標

**配置**:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      show-details: always
```

### 5. 錯誤處理策略

**決策**: 使用 Spring 預設錯誤處理 + 自訂錯誤回應

**理由**:
- 保持簡單，展示專案不需複雜錯誤處理
- Spring Boot 已提供完善的預設錯誤頁面
- 可透過 `@ControllerAdvice` 自訂特定錯誤回應

**錯誤情境**:
| 情境 | HTTP 狀態 | 回應 |
|------|----------|------|
| 服務不可用 | 503 | Service Unavailable |
| 路由不存在 | 404 | Not Found |
| 閘道錯誤 | 502 | Bad Gateway |

## 技術決策摘要

| 項目 | 決策 | 理由 |
|------|------|------|
| 建置工具 | Gradle 8.x | 多專案支援佳 |
| 框架版本 | Spring Boot 3.2.x | 最新穩定版 |
| 路由方式 | Weight Predicate | 原生支援、配置簡單 |
| 測試框架 | JUnit 5 + MockMvc | Spring 標準測試 |
| 健康檢查 | Actuator | 零配置啟用 |

## 未解決項目

無。所有技術決策已確定。
