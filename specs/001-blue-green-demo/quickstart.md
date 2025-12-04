# 快速開始指南：藍綠佈署展示系統

**功能分支**: `001-blue-green-demo`
**日期**: 2025-12-04

## 前置需求

在開始之前，請確認您的環境已安裝以下工具：

| 工具 | 最低版本 | 檢查指令 | 用途 |
|------|----------|----------|------|
| Java | 17+ | `java -version` | 執行 Spring Boot 應用程式 |
| Gradle | 8.0+ | `./gradlew --version` | 專案建置（使用 Wrapper） |

## 快速驗證

### 步驟 1：建置專案

```bash
# 在專案根目錄執行
./gradlew build
```

### 步驟 2：啟動所有服務

在三個終端機視窗中分別執行：

**終端機 1 - Blue Service (Port 8081):**
```bash
./gradlew :blue-service:bootRun
```

**終端機 2 - Green Service (Port 8082):**
```bash
./gradlew :green-service:bootRun
```

**終端機 3 - API Gateway (Port 8080):**
```bash
./gradlew :spring-cloud-gateway:bootRun
```

### 步驟 3：驗證服務

```bash
# 測試 Blue Service
curl http://localhost:8081/greeting
# 預期: Greeting from Blue Service

# 測試 Green Service
curl http://localhost:8082/greeting
# 預期: Greeting from Green Service

# 測試 API Gateway（隨機分流）
curl http://localhost:8080/greeting
# 預期: 隨機回傳 Blue 或 Green 的訊息
```

### 步驟 4：驗證流量分配

執行多次請求觀察分配比例：

```bash
# 發送 100 次請求統計
for i in {1..100}; do
  curl -s http://localhost:8080/greeting
  echo
done | sort | uniq -c
```

預期結果：約 20 次 Blue Service，約 80 次 Green Service（±5% 誤差）

## 預期結果

| 服務 | 預期流量比例 |
|------|-------------|
| Blue Service | 20% (±5%) |
| Green Service | 80% (±5%) |

## 健康檢查

```bash
# 檢查各服務健康狀態
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
```

## 常見問題

### 問題：端口已被佔用

**錯誤訊息**: `Port 8080 was already in use`

**解決方案**:
1. 找出佔用端口的程序：`lsof -i :8080`
2. 終止程序或更換端口

### 問題：Gradle 建置失敗

**可能原因**: Java 版本不符

**解決方案**:
1. 確認 Java 版本：`java -version`
2. 需要 Java 17 或更高版本

### 問題：閘道無法連線後端服務

**錯誤訊息**: `503 Service Unavailable`

**解決方案**:
1. 確認 Blue Service 和 Green Service 都已啟動
2. 檢查端口 8081 和 8082 是否正常監聽

## 下一步

- 執行 `./scripts/test-traffic.sh` 進行完整流量測試
- 閱讀 README.md 了解更多專案細節
- 調整 `spring-cloud-gateway/src/main/resources/application.yml` 修改權重
