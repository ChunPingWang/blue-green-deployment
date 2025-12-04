# API 合約

本功能（測試腳本與專案文件）不定義新的 API 合約。

測試腳本會呼叫現有的 API 閘道端點：

## 使用的端點

### GET /greeting

**位置**: API Gateway (http://localhost:8080)

**說明**: 問候服務端點，由閘道根據權重分流至後端服務

**預期回應**:
- `Greeting from Blue Service` - 來自藍色服務
- `Greeting from Green Service` - 來自綠色服務

**HTTP 狀態碼**:
- `200 OK` - 成功
- `503 Service Unavailable` - 後端服務不可用
- `504 Gateway Timeout` - 請求逾時

此端點由 `001-blue-green-demo` 功能定義。
