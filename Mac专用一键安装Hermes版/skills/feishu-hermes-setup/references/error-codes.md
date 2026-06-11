# 飞书 API 常见错误码

| 错误码 | 含义 | 解决方案 |
|--------|------|----------|
| 10014 | app secret invalid | App Secret 不正确，检查 `~/.hermes/.env` 中的值 |
| 1000040345 | app_id or app_secret is invalid | 凭证无效，用 curl 直接测试 API 验证 |
| 99991663 | app not found | App ID 不存在，检查是否在正确的飞书组织中创建 |
| 99991668 | app is not approved | 应用未审批通过，需要在飞书管理后台审批 |
| 99991672 | app is disabled | 应用已禁用，需要在飞书管理后台启用 |
| 99991679 | bot not enabled | 机器人能力未开启，需要在应用后台添加机器人能力 |
