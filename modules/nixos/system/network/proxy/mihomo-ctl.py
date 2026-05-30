#!/usr/bin/env python3
import argparse
import json
import os
import sys
import urllib.request
import urllib.parse
import urllib.error
import yaml


CONFIG_DIR = "/var/lib/mihomo"
SUBS_DIR = os.path.join(CONFIG_DIR, "subs")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.yaml")
API_URL = "http://127.0.0.1:9090"

# 基础配置模板
BASE_CONFIG = {
    "mixed-port": 7890,
    "tproxy-port": 1536,
    "allow-lan": True,
    "mode": "rule",
    "log-level": "info",
    "ipv6": False,
    "external-controller": "0.0.0.0:9090",
    "secret": "",
    "unified-delay": True,
    "tcp-concurrent": True,
    "profile": {
        "store-selected": True,
        "store-fake-ip": True
    },
    "dns": {
        "enable": True,
        "prefer-h3": True,
        "ipv6": False,
        "enhanced-mode": "fake-ip",
        "fake-ip-range": "198.18.0.1/16",
        "fallback": [
            "https://8.8.8.8/dns-query",
            "https://1.1.1.1/dns-query"
        ]
    },
    "tun": {
        "enable": True,
        "stack": "gvisor",
        "auto-route": True,
        "auto-detect-interface": True,
        "dns-hijack": ["any:53"]
    }
}


def generate_config():
    if not os.path.exists(SUBS_DIR):
        os.makedirs(SUBS_DIR, exist_ok=True, mode=0o750)

    providers = {}
    provider_names = []

    if os.path.exists(SUBS_DIR):
        for filename in os.listdir(SUBS_DIR):
            filepath = os.path.join(SUBS_DIR, filename)
            if os.path.isfile(filepath):
                with open(filepath, 'r') as f:
                    url = f.read().strip()
                    if url:
                        providers[filename] = {
                            "type": "http",
                            "url": url,
                            "interval": 86400,
                            "path": f"./proxies/{filename}.yaml",
                            "health-check": {
                                "enable": True,
                                "url": "http://www.gstatic.com/generate_204",
                                "interval": 300
                            },
                            "override": {
                                "additional-prefix": f"[{filename}] "
                            }
                        }
                        provider_names.append(filename)

    # 动态获取默认网关
    gateway_ip = "192.168.1.1"  # fallback
    try:
        import subprocess
        # 使用 ip route show 获取默认网关
        output = subprocess.check_output(["ip", "route", "show", "default"]).decode()
        # 输出示例: "default via 192.168.1.1 dev eth0 proto dhcp"
        parts = output.split()
        if "via" in parts:
            gateway_ip = parts[parts.index("via") + 1]
    except Exception:
        pass  # Silence warning as requested

    config = BASE_CONFIG.copy()
    config["dns"]["nameserver"] = [
        f"{gateway_ip}",  # 路由器 DNS
        "https://dns.alidns.com/dns-query",
        "https://doh.pub/dns-query"
    ]
    config["proxy-providers"] = providers

    # 地区筛选规则
    hk_filter = "(?i)(港|HK|Hong Kong|HongKong|HONGKONG)"
    sg_filter = "(?i)(新|SG|Singapore|狮城)"

    config["proxy-groups"] = [
        {
            "name": "Proxy",
            "type": "select",
            "proxies": ["Auto-HK", "Auto-SG", "DIRECT"]
        },
        {
            "name": "Auto-HK",
            "type": "url-test",
            "use": provider_names if provider_names else [],
            "url": "http://www.gstatic.com/generate_204",
            "interval": 300,
            "tolerance": 50,
            "filter": hk_filter
        },
        {
            "name": "Auto-SG",
            "type": "url-test",
            "use": provider_names if provider_names else [],
            "url": "http://www.gstatic.com/generate_204",
            "interval": 300,
            "tolerance": 50,
            "filter": sg_filter
        },
        {
            "name": "direct",
            "type": "select",
            "proxies": ["DIRECT", "Proxy"]
        }
    ]

    config["rules"] = [
        "GEOSITE,github,Proxy",
        "GEOIP,CN,DIRECT",
        "MATCH,Proxy"
    ]

    # 确保 proxies 目录存在 (相对于 config.yaml)
    os.makedirs(os.path.join(CONFIG_DIR, "proxies"), exist_ok=True, mode=0o750)

    with open(CONFIG_FILE, 'w') as f:
        yaml.dump(config, f, allow_unicode=True, sort_keys=False)
    print(f"Config generated at {CONFIG_FILE}")


def api_request(path, method="GET", data=None):
    url = f"{API_URL}{path}"
    req = urllib.request.Request(url, method=method)
    if data:
        req.add_header('Content-Type', 'application/json')
        req.data = json.dumps(data).encode('utf-8')
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8')) if response.length else {}
    except urllib.error.URLError as e:
        print(f"API Request failed: {e}", file=sys.stderr)
        return None


def get_groups():
    data = api_request("/proxies")
    if not data:
        return
    groups = []
    for name, proxy in data.get('proxies', {}).items():
        if proxy.get('type') in ('Selector', 'URLTest', 'Fallback', 'LoadBalance'):
            if name not in ['GLOBAL', 'REJECT']:
                groups.append(name)
    print("\n".join(groups))


def get_delay(group):
    data = api_request(f"/proxies/{urllib.parse.quote(group)}")
    if not data:
        return

    now = data.get('now', 'N/A')
    history = data.get('history', [])
    delay = "N/A"
    if history:
        delay = f"{history[-1].get('delay', 0)}ms"

    print(f"[{delay}] {now}")


def set_group(group, node=None):
    if not node:
        node = sys.stdin.read().strip()
    if not node:
        print("No node provided", file=sys.stderr)
        sys.exit(1)

    res = api_request(f"/proxies/{urllib.parse.quote(group)}", method="PUT", data={"name": node})
    if res is not None:
        print(f"Switched {group} to {node}")


def update():
    generate_config()
    print("Reloading config in Mihomo...")
    api_request("/configs?force=true", method="PUT", data={"path": CONFIG_FILE})

    print("Updating providers...")
    data = api_request("/providers/proxies")
    if data:
        for provider in data.get('providers', {}):
            if provider != "default":
                api_request(f"/providers/proxies/{urllib.parse.quote(provider)}", method="PUT")
    print("Update complete.")


def main():
    parser = argparse.ArgumentParser(description="Mihomo Proxy Controller")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("generate", help="Generate config.yaml from subscriptions")
    subparsers.add_parser("get-groups", help="List proxy groups")

    delay_parser = subparsers.add_parser("get-delay", help="Get delay of a group")
    delay_parser.add_argument("group", help="Group name (e.g. Proxy)")

    set_parser = subparsers.add_parser("set-group", help="Set node for a group")
    set_parser.add_argument("group", help="Group name")
    set_parser.add_argument("node", nargs="?", help="Node name (can be read from stdin)")

    subparsers.add_parser("update", help="Update subscriptions and reload config")

    args = parser.parse_args()

    if args.command == "generate":
        generate_config()
    elif args.command == "get-groups":
        get_groups()
    elif args.command == "get-delay":
        get_delay(args.group)
    elif args.command == "set-group":
        set_group(args.group, args.node)
    elif args.command == "update":
        update()


if __name__ == "__main__":
    main()
