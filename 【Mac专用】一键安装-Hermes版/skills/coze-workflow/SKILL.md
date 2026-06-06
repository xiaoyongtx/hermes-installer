---
name: coze-workflow
description: Run Coze workflows via API. Use when the user wants to execute a Coze workflow, trigger an automation pipeline, or run a published workflow with parameters. Supports both streaming (SSE) and non-streaming modes.
---

# Coze Workflow API Skill

## When to use

Use this skill when the user wants to:
- Execute a published Coze workflow
- Trigger a workflow automation pipeline via API
- Run a workflow with custom input parameters
- Get streaming output from a workflow execution

## Prerequisites

- Coze API access token with `run` permission
- Workflow ID (from Coze workflow editor URL)
- Workflow must be published
- Python 3.7+ with `requests` library

## Quick Start

**Non-streaming** (synchronous, result returned directly):
```bash
python scripts/coze_workflow.py --token "TOKEN" --workflow-id "WF_ID" --parameters '{"user_name":"George"}'
```

**Streaming** (SSE, real-time output):
```bash
python scripts/coze_workflow.py --token "TOKEN" --workflow-id "WF_ID" --parameters '{"user_name":"George"}' --stream
```

**With bot association** (for workflows with database/variable nodes):
```bash
python scripts/coze_workflow.py --token "TOKEN" --workflow-id "WF_ID" --bot-id "BOT_ID" --parameters '{"input":"Hello"}'
```

**Async execution** (for long-running workflows, premium only):
```bash
python scripts/coze_workflow.py --token "TOKEN" --workflow-id "WF_ID" --parameters '{"input":"Hello"}' --async-run
```

## API Reference

### Endpoints

| Mode | URL | Method |
|------|-----|--------|
| Non-streaming | `https://api.coze.cn/v1/workflow/run` | POST |
| Streaming | `https://api.coze.cn/v1/workflow/stream_run` | POST |

**Permission**: `run`

### Request Headers

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `workflow_id` | String | Yes | Published workflow ID |
| `parameters` | Map/String | No | Input params for workflow start node |
| `bot_id` | String | No | Associated bot ID (for DB/variable nodes) |
| `app_id` | String | No | App ID (only for app workflows) |
| `ext` | Map | No | Extra fields (latitude, longitude, user_id) |
| `is_async` | Boolean | No | Async execution (premium only, default: false) |
| `workflow_version` | String | No | Version (for library workflows) |
| `connector_id` | String | No | Channel ID (default: 1024 for API) |

Note: Do NOT set both `bot_id` and `app_id` simultaneously (error 4000).

### Non-Streaming Response

```json
{
  "code": 0,
  "msg": "",
  "data": "{\"output\":\"result text\"}",
  "debug_url": "https://www.coze.cn/work_flow?execute_id=...",
  "execute_id": "741364789030728****",
  "usage": {"input_count": 50, "output_count": 100, "token_count": 150}
}
```

### Streaming Response (SSE Events)

Event types in order:

1. **Message** - Workflow node output (content, node_title, node_seq_id, node_is_finish)
2. **Interrupt** - Workflow paused, needs user input (interrupt_data with event_id, type)
3. **Error** - Error occurred (error_code, error_message)
4. **Done** - Execution finished (data: `{}`)
5. **PING** - Heartbeat signal

SSE format:
```
id: 0
event: Message
data: {"content":"hello","node_is_finish":false,"node_seq_id":"0","node_title":"Message"}

id: 1
event: Done
data: {}
```

### curl Examples

**Non-streaming**:
```bash
curl -X POST "https://api.coze.cn/v1/workflow/run" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"workflow_id":"WF_ID","parameters":{"user_name":"George"}}'
```

**Streaming**:
```bash
curl -X POST "https://api.coze.cn/v1/workflow/stream_run" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"workflow_id":"WF_ID","parameters":{"user_name":"George"}}'
```

## Script Reference

- [scripts/coze_workflow.py](scripts/coze_workflow.py) - Python client for workflow execution
