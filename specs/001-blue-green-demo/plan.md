# 實作計畫：藍綠佈署展示系統

**分支**: `001-blue-green-demo` | **日期**: 2025-12-04 | **規格書**: [spec.md](./spec.md)
**輸入**: 功能規格書 `/specs/001-blue-green-demo/spec.md`

## 摘要

本功能實作一個展示藍綠佈署的微服務系統，包含三個獨立服務：
1. **API Gateway**: Spring Cloud Gateway，負責接收請求並根據權重（20%/80%）分流至後端服務
2. **Blue Service**: 藍色服務，提供 `/greeting` API 回傳 "Greeting from Blue Service"
3. **Green Service**: 綠色服務，提供 `/greeting` API 回傳 "Greeting from Green Service"

技術方案採用 Spring Boot 3 + Spring Cloud Gateway + Gradle 建置。

## 技術上下文

**語言/版本**: Java 17
**建置工具**: Gradle 8.x
**主要相依性**: Spring Boot 3.2.x, Spring Cloud Gateway 2023.0.x, Spring Boot Actuator
**儲存**: 無（純展示用途，不需持久化）
**測試**: JUnit 5, Spring Boot Test, MockMvc
**目標平台**: 任何支援 Java 17 的環境（Linux/macOS/Windows）
**專案類型**: Monorepo（三個獨立 Gradle 子專案）
**效能目標**: 單一請求 < 1 秒，100 次請求 < 30 秒
**約束條件**: 服務啟動時間 < 30 秒
**規模/範圍**: 展示專案，預期負載極低

## 憲法檢查

*關卡：必須在 Phase 0 研究前通過。Phase 1 設計後重新檢查。*

| 原則 | 狀態 | 備註 |
|------|------|------|
| I. 程式碼品質 | ✅ 通過 | 遵循命名規範、單一職責、避免重複 |
| II. 測試標準 | ✅ 通過 | 使用 JUnit 5 + Spring Boot Test，目標 80% 覆蓋率 |
| III. 行為驅動開發 | ✅ 通過 | 規格書已包含 Given/When/Then 驗收情境 |
| IV. 領域驅動設計 | ⚠️ 簡化 | 展示專案無複雜領域模型，採用簡單 Controller 架構 |
| V. SOLID 原則 | ✅ 通過 | 服務職責單一、依賴抽象 |
| VI. 基礎設施層隔離 | ⚠️ 簡化 | 展示專案無複雜分層需求，採用簡單架構 |
| VII. 使用者體驗一致性 | ✅ 通過 | API 回應格式一致、錯誤訊息清楚 |
| VIII. 效能要求 | ✅ 通過 | 目標 < 1 秒回應時間 |
| IX. 文件語言規範 | ✅ 通過 | 規格書與計畫使用繁體中文 |

**結論**: 所有適用原則均通過或已說明簡化理由。可進入 Phase 0。

## 專案結構

### 文件（本功能）

```text
specs/001-blue-green-demo/
├── plan.md              # 本檔案
├── research.md          # Phase 0 輸出
├── data-model.md        # Phase 1 輸出
├── quickstart.md        # Phase 1 輸出
├── contracts/           # Phase 1 輸出
└── tasks.md             # Phase 2 輸出（/speckit.tasks 指令）
```

### 原始碼（儲存庫根目錄）

```text
blue-green-deployment/
├── spring-cloud-gateway/        # API 閘道服務
│   ├── build.gradle
│   └── src/
│       ├── main/
│       │   ├── java/com/example/gateway/
│       │   │   └── ApiGatewayApplication.java
│       │   └── resources/
│       │       └── application.yml
│       └── test/
│           └── java/com/example/gateway/
│               └── ApiGatewayApplicationTests.java
│
├── blue-service/                # 藍色服務
│   ├── build.gradle
│   └── src/
│       ├── main/
│       │   ├── java/com/example/blue/
│       │   │   ├── BlueServiceApplication.java
│       │   │   └── GreetingController.java
│       │   └── resources/
│       │       └── application.yml
│       └── test/
│           └── java/com/example/blue/
│               └── BlueServiceApplicationTests.java
│
├── green-service/               # 綠色服務
│   ├── build.gradle
│   └── src/
│       ├── main/
│       │   ├── java/com/example/green/
│       │   │   ├── GreenServiceApplication.java
│       │   │   └── GreetingController.java
│       │   └── resources/
│       │       └── application.yml
│       └── test/
│           └── java/com/example/green/
│               └── GreenServiceApplicationTests.java
│
├── settings.gradle              # Gradle 多專案設定
├── build.gradle                 # 根專案建置檔
└── gradle/
    └── wrapper/                 # Gradle Wrapper
```

**結構決策**: 採用 Gradle 多專案架構。每個微服務為獨立子專案，可單獨建置和執行。根目錄 `settings.gradle` 統一管理三個子專案。

## 複雜度追蹤

| 簡化項目 | 原因 | 完整實作替代方案 |
|---------|------|-----------------|
| 無分層架構 | 展示專案，邏輯簡單 | 完整 DDD 分層（domain/application/infrastructure） |
| 無服務發現 | 本地開發，固定端口 | Eureka/Consul 服務發現 |
| 無容器化 | 簡化啟動流程 | Docker Compose 編排 |
