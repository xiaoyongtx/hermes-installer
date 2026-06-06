#!/usr/bin/env python3
"""
Coze Workflow API Client - Execute published workflows with streaming/non-streaming support.

Usage:
    python coze_workflow.py --token TOKEN --workflow-id WF_ID --parameters '{"key":"value"}'
    python coze_workflow.py --token TOKEN --workflow-id WF_ID --parameters '{"key":"value"}' --stream
    python coze_workflow.py --token TOKEN --workflow-id WF_ID --bot-id BOT_ID --parameters '{"input":"Hello"}'
    python coze_workflow.py --token TOKEN --workflow-id WF_ID --parameters '{"key":"value"}' --async-run
"""

import argparse
import json
import sys
import time

try:
    import requests
except ImportError:
    print("Error: 'requests' library is required. Install with: pip install requests")
    sys.exit(1)

API_BASE = "https://api.coze.cn"
WORKFLOW_RUN_ENDPOINT = f"{API_BASE}/v1/workflow/run"
WORKFLOW_STREAM_RUN_ENDPOINT = f"{API_BASE}/v1/workflow/stream_run"
WORKFLOW_HISTORY_ENDPOINT = f"{API_BASE}/v1/workflow/run_history"


def run_workflow(
    token: str,
    workflow_id: str,
    parameters: dict = None,
    bot_id: str = None,
    app_id: str = None,
    ext: dict = None,
    is_async: bool = False,
    stream: bool = False,
    workflow_version: str = None,
    connector_id: str = None,
):
    """Execute a published Coze workflow."""

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

    body = {
        "workflow_id": workflow_id,
    }

    if parameters is not None:
        body["parameters"] = parameters

    if bot_id:
        body["bot_id"] = bot_id

    if app_id:
        body["app_id"] = app_id

    if ext:
        body["ext"] = ext

    if is_async:
        body["is_async"] = True

    if workflow_version:
        body["workflow_version"] = workflow_version

    if connector_id:
        body["connector_id"] = connector_id

    if stream:
        return _handle_stream(headers, body)
    else:
        return _handle_non_stream(headers, body, token, is_async)


def _handle_stream(headers: dict, body: dict):
    """Handle streaming (SSE) workflow execution."""

    response = requests.post(
        WORKFLOW_STREAM_RUN_ENDPOINT,
        headers=headers,
        json=body,
        stream=True,
        timeout=600,
    )

    if response.status_code != 200:
        print(f"Error: HTTP {response.status_code}")
        print(response.text)
        return None

    result = {
        "messages": [],
        "full_output": "",
        "status": None,
        "interrupt_data": None,
        "error": None,
    }

    current_event = None
    current_id = None
    data_buffer = ""

    for line in response.iter_lines(decode_unicode=True):
        if line is None:
            continue

        line = line.strip()

        if not line:
            # Empty line = end of event block
            if current_event and data_buffer:
                _process_workflow_event(current_event, current_id, data_buffer, result)
            current_event = None
            current_id = None
            data_buffer = ""
            continue

        if line.startswith("id:"):
            current_id = line[len("id:"):].strip()
        elif line.startswith("event:"):
            current_event = line[len("event:"):].strip()
        elif line.startswith("data:"):
            data_buffer = line[len("data:"):].strip()

    # Process remaining
    if current_event and data_buffer:
        _process_workflow_event(current_event, current_id, data_buffer, result)

    print()
    return result


def _process_workflow_event(event: str, event_id: str, data: str, result: dict):
    """Process a single SSE event from workflow execution."""

    if event == "PING":
        return

    try:
        event_data = json.loads(data)
    except json.JSONDecodeError:
        event_data = data

    if event == "Message":
        content = event_data.get("content", "") if isinstance(event_data, dict) else ""
        node_title = event_data.get("node_title", "") if isinstance(event_data, dict) else ""
        node_is_finish = event_data.get("node_is_finish", False) if isinstance(event_data, dict) else False
        node_seq_id = event_data.get("node_seq_id", "") if isinstance(event_data, dict) else ""

        # Print streaming content
        if content:
            print(content, end="", flush=True)
            result["full_output"] += content

        if node_is_finish:
            result["messages"].append({
                "node_title": node_title,
                "content": content,
                "node_seq_id": node_seq_id,
                "finished": True,
            })

    elif event == "Done":
        result["status"] = "completed"
        debug_url = event_data.get("debug_url", "") if isinstance(event_data, dict) else ""
        if debug_url:
            print(f"\n[Debug URL]: {debug_url}")
        print("\n[Workflow completed]")

    elif event == "Error":
        error_code = event_data.get("error_code", -1) if isinstance(event_data, dict) else -1
        error_message = event_data.get("error_message", str(event_data)) if isinstance(event_data, dict) else str(event_data)
        result["status"] = "failed"
        result["error"] = {"code": error_code, "message": error_message}
        print(f"\n[Error] code={error_code}, message={error_message}")

    elif event == "Interrupt":
        result["status"] = "interrupted"
        result["interrupt_data"] = event_data
        interrupt_info = event_data.get("interrupt_data", {}) if isinstance(event_data, dict) else {}
        event_id_val = interrupt_info.get("event_id", "")
        interrupt_type = interrupt_info.get("type", "")
        print(f"\n[Interrupted] type={interrupt_type}, event_id={event_id_val}")
        print(f"  Data: {json.dumps(interrupt_info, ensure_ascii=False)}")


def _handle_non_stream(headers: dict, body: dict, token: str, is_async: bool):
    """Handle non-streaming workflow execution."""

    response = requests.post(
        WORKFLOW_RUN_ENDPOINT,
        headers=headers,
        json=body,
        timeout=120,
    )

    if response.status_code != 200:
        print(f"Error: HTTP {response.status_code}")
        print(response.text)
        return None

    resp_data = response.json()

    if resp_data.get("code") != 0:
        print(f"API Error: code={resp_data.get('code')}, msg={resp_data.get('msg')}")
        return None

    result = {
        "data": resp_data.get("data"),
        "debug_url": resp_data.get("debug_url"),
        "execute_id": resp_data.get("execute_id"),
        "usage": resp_data.get("usage"),
        "status": "completed",
        "interrupt_data": resp_data.get("interrupt_data"),
    }

    # Check for interrupt
    if result["interrupt_data"]:
        result["status"] = "interrupted"
        print(f"[Interrupted]")
        print(f"  Interrupt data: {json.dumps(result['interrupt_data'], ensure_ascii=False)}")
    else:
        # Parse and display result
        data_str = result["data"]
        print(f"[Workflow Output]:")
        try:
            parsed = json.loads(data_str)
            print(json.dumps(parsed, ensure_ascii=False, indent=2))
        except (json.JSONDecodeError, TypeError):
            print(data_str)

    if result["debug_url"]:
        print(f"\n[Debug URL]: {result['debug_url']}")

    if result["usage"]:
        usage = result["usage"]
        print(f"[Usage] input={usage.get('input_count', 0)}, output={usage.get('output_count', 0)}, total={usage.get('token_count', 0)}")

    if is_async and result["execute_id"]:
        print(f"\n[Async] execute_id={result['execute_id']}")
        print("  Use this ID to poll workflow execution result.")

    return result


def main():
    parser = argparse.ArgumentParser(description="Coze Workflow API Client")
    parser.add_argument("--token", required=True, help="Coze API access token")
    parser.add_argument("--workflow-id", required=True, help="Workflow ID")
    parser.add_argument("--parameters", default=None, help="Workflow input parameters as JSON string")
    parser.add_argument("--bot-id", default=None, help="Associated bot ID")
    parser.add_argument("--app-id", default=None, help="App ID (for app workflows only)")
    parser.add_argument("--ext", default=None, help="Extra fields as JSON (latitude, longitude, user_id)")
    parser.add_argument("--async-run", action="store_true", help="Run workflow asynchronously (premium only)")
    parser.add_argument("--stream", action="store_true", help="Enable streaming mode")
    parser.add_argument("--workflow-version", default=None, help="Workflow version (for library workflows)")
    parser.add_argument("--connector-id", default=None, help="Channel ID (default: 1024 for API)")
    parser.add_argument("--json-output", action="store_true", help="Output result as JSON")

    args = parser.parse_args()

    parameters = json.loads(args.parameters) if args.parameters else None
    ext = json.loads(args.ext) if args.ext else None

    result = run_workflow(
        token=args.token,
        workflow_id=args.workflow_id,
        parameters=parameters,
        bot_id=args.bot_id,
        app_id=args.app_id,
        ext=ext,
        is_async=args.async_run,
        stream=args.stream,
        workflow_version=args.workflow_version,
        connector_id=args.connector_id,
    )

    if args.json_output and result:
        print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
