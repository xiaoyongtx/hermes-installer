#!/usr/bin/env python3
"""
Coze Workflow Parameter Discovery Tool

This tool helps discover what parameters a Coze workflow expects by:
1. Analyzing workflow metadata (if available)
2. Testing with common parameter names
3. Providing interactive guidance
"""

import json
import sys
import argparse

try:
    import requests
except ImportError:
    print("Error: 'requests' library is required. Install with: pip install requests")
    sys.exit(1)

API_BASE = "https://api.coze.cn"


def test_workflow_parameters(token: str, workflow_id: str, test_params: dict, stream: bool = False):
    """Test workflow with given parameters and return result."""
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    
    endpoint = f"{API_BASE}/v1/workflow/stream_run" if stream else f"{API_BASE}/v1/workflow/run"
    
    body = {
        "workflow_id": workflow_id,
        "parameters": test_params
    }
    
    try:
        response = requests.post(endpoint, headers=headers, json=body, timeout=30)
        response.raise_for_status()
        
        if stream:
            # For streaming, just check if connection succeeds
            return {"status": "success", "streaming": True, "message": "Stream connection established"}
        else:
            result = response.json()
            return {
                "status": "success" if result.get("code") == 0 else "error",
                "data": result.get("data"),
                "message": result.get("msg", ""),
                "debug_url": result.get("debug_url")
            }
    except requests.exceptions.RequestException as e:
        return {"status": "error", "message": str(e)}


def discover_parameters(token: str, workflow_id: str):
    """Try to discover workflow parameters by testing common names."""
    
    print("=" * 60)
    print("Coze Workflow Parameter Discovery Tool")
    print("=" * 60)
    print(f"\nWorkflow ID: {workflow_id}\n")
    
    # Common parameter names to test
    common_params = [
        {"input": "test"},
        {"text": "test"},
        {"prompt": "test"},
        {"content": "test"},
        {"query": "test"},
        {"message": "test"},
    ]
    
    print("Testing common parameter names...\n")
    
    results = []
    for params in common_params:
        param_name = list(params.keys())[0]
        print(f"Testing parameter: '{param_name}'...", end=" ")
        
        result = test_workflow_parameters(token, workflow_id, params)
        
        if result["status"] == "success":
            print("✓ SUCCESS")
            results.append({
                "param": param_name,
                "result": result
            })
        else:
            print("✗ FAILED")
    
    print("\n" + "=" * 60)
    print("Discovery Results:")
    print("=" * 60)
    
    if results:
        print(f"\nFound {len(results)} working parameter(s):\n")
        for i, r in enumerate(results, 1):
            print(f"{i}. Parameter name: '{r['param']}'")
            if r['result'].get('data'):
                print(f"   Sample output: {r['result']['data'][:100]}...")
            if r['result'].get('debug_url'):
                print(f"   Debug URL: {r['result']['debug_url']}")
            print()
        
        print("\nRecommendation:")
        print(f"Use the parameter name: '{results[0]['param']}'")
        print(f"\nExample usage:")
        print(f'python scripts/coze_workflow.py --token "TOKEN" --workflow-id "{workflow_id}" --parameters \'{{"{results[0]["param"]}":"your content"}}\'')
    else:
        print("\nNo working parameters found with common names.")
        print("\nSuggestions:")
        print("1. Check the workflow documentation for expected parameters")
        print("2. Ask the workflow creator about input requirements")
        print("3. Try accessing the workflow in Coze editor to see start node configuration")
        print("4. The workflow might require specific parameter structure")


def create_parameter_template(workflow_id: str, param_name: str, description: str = ""):
    """Create a parameter template file."""
    
    template = {
        "workflow_id": workflow_id,
        "parameter_name": param_name,
        "description": description,
        "examples": [
            {
                "name": "Basic Example",
                "params": {param_name: "Your content here"}
            },
            {
                "name": "Detailed Example", 
                "params": {param_name: "More detailed content with specific instructions"}
            }
        ]
    }
    
    filename = f"workflow_{workflow_id}_template.json"
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(template, f, ensure_ascii=False, indent=2)
    
    print(f"\nTemplate created: {filename}")
    return filename


def main():
    parser = argparse.ArgumentParser(description="Discover Coze workflow parameters")
    parser.add_argument("--token", required=True, help="Coze API access token")
    parser.add_argument("--workflow-id", required=True, help="Workflow ID to test")
    parser.add_argument("--param-name", default=None, help="Specific parameter name to test")
    parser.add_argument("--test-value", default="test", help="Test value to use (default: 'test')")
    parser.add_argument("--create-template", action="store_true", help="Create a parameter template file")
    parser.add_argument("--stream", action="store_true", help="Test with streaming mode")
    
    args = parser.parse_args()
    
    if args.param_name:
        # Test specific parameter
        print(f"Testing specific parameter: '{args.param_name}'")
        test_params = {args.param_name: args.test_value}
        result = test_workflow_parameters(args.token, args.workflow_id, test_params, args.stream)
        
        print(f"\nResult: {json.dumps(result, indent=2, ensure_ascii=False)}")
        
        if args.create_template and result["status"] == "success":
            create_parameter_template(args.workflow_id, args.param_name)
    else:
        # Auto-discover parameters
        discover_parameters(args.token, args.workflow_id)


if __name__ == "__main__":
    main()
