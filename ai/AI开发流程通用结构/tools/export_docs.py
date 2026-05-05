#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""导出 Flasgger 文档为 JSON 和 Markdown"""

import sys
import os
import json
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def json_to_markdown(spec, output_file):
    """将 Swagger JSON 转换为 Markdown"""
    lines = []

    lines.append("# API 文档")
    lines.append("")
    lines.append(f"> **基础路径**: `http://{{host}}:{{port}}/api`")
    lines.append(f"> **更新日期**: {datetime.now().strftime('%Y-%m-%d')}")
    lines.append(f"> **版本**: {spec.get('info', {}).get('version', '1.0')}")
    lines.append("")
    lines.append("---")
    lines.append("")

    paths = spec.get('paths', {})
    tag_apis = {}

    for path, methods in paths.items():
        for method, details in methods.items():
            tags = details.get('tags', [])
            for tag in tags:
                if tag not in tag_apis:
                    tag_apis[tag] = []
                tag_apis[tag].append({'path': path, 'method': method.upper(), 'details': details})

    lines.append("## 目录")
    lines.append("")
    for tag in sorted(tag_apis.keys()):
        sub_module = tag.split('/', 1)[1] if '/' in tag else tag
        lines.append(f"- [{tag}](#{tag})")
    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append("## 通用规范")
    lines.append("")
    lines.append("### 认证方式")
    lines.append("")
    lines.append("系统采用 JWT Token 认证机制，大部分接口需要携带 Token 才能访问。")
    lines.append("")
    lines.append("#### 获取 Token")
    lines.append("")
    lines.append("**接口地址**：`POST /api/auth/login`")
    lines.append("")
    lines.append("**请求参数**：")
    lines.append("| 参数名 | 类型 | 必填 | 说明 |")
    lines.append("|:------|:----:|:----:|------|")
    lines.append("| username | string | 是 | 用户名 |")
    lines.append("| password | string | 是 | 密码 |")
    lines.append("")
    lines.append("**请求示例**：")
    lines.append("```json")
    lines.append('{')
    lines.append('  "username": "admin",')
    lines.append('  "password": "password"')
    lines.append('}')
    lines.append("```")
    lines.append("")
    lines.append("**响应示例**：")
    lines.append("```json")
    lines.append('{')
    lines.append('  "code": 0,')
    lines.append('  "msg": "success",')
    lines.append('  "data": {')
    lines.append('    "token": "xxx"')
    lines.append('  }')
    lines.append('}')
    lines.append("```")
    lines.append("")
    lines.append("#### 使用 Token")
    lines.append("")
    lines.append("在请求头中添加 Authorization 字段，格式为：")
    lines.append("")
    lines.append("`Authorization: Bearer {token}`")
    lines.append("")
    lines.append("### 响应格式")
    lines.append("")
    lines.append("**成功响应：**")
    lines.append("```json")
    lines.append('{')
    lines.append('  "code": 0,')
    lines.append('  "msg": "success",')
    lines.append('  "data": {}')
    lines.append('}')
    lines.append("```")
    lines.append("")
    lines.append("**失败响应：**")
    lines.append("```json")
    lines.append('{')
    lines.append('  "code": 400,')
    lines.append('  "msg": "错误信息"')
    lines.append('}')
    lines.append("```")
    lines.append("")
    lines.append("### 错误码")
    lines.append("")
    lines.append("| 错误码 | 说明 |")
    lines.append("|:------:|:-----|")
    lines.append("| 0 | 成功 |")
    lines.append("| 400 | 参数错误 |")
    lines.append("| 401 | 未登录或token过期 |")
    lines.append("| 403 | 无权限 |")
    lines.append("| 404 | 资源不存在 |")
    lines.append("| 500 | 服务器错误 |")
    lines.append("")
    lines.append("---")
    lines.append("")

    for tag in sorted(tag_apis.keys()):
        sub_module = tag.split('/', 1)[1] if '/' in tag else tag
        lines.append(f"## {tag}")
        lines.append("")

        apis = tag_apis[tag]
        apis.sort(key=lambda x: x['path'])

        for k, api in enumerate(apis, 1):
            path = api['path']
            method = api['method']
            details = api['details']

            summary = details.get('summary', f'{method} {path}')
            description = details.get('description', '')
            requires_auth = details.get('security', [])

            lines.append(f"### {k}. {summary}")
            lines.append("")
            lines.append(f"**接口地址**: `{method} {path}`")
            lines.append("")

            if requires_auth:
                lines.append("**认证**: 是")
                lines.append("")

            if description:
                lines.append(f"**说明**: {description}")
                lines.append("")

            parameters = details.get('parameters', [])
            if parameters:
                lines.append("**请求参数**:")
                lines.append("")

                has_body = any(p.get('in') == 'body' for p in parameters)
                has_query = any(p.get('in') == 'query' for p in parameters)

                if has_body:
                    body_params = [p for p in parameters if p.get('in') == 'body']
                    if body_params:
                        schema = body_params[0].get('schema', {})
                        properties = schema.get('properties', {})
                        required = schema.get('required', [])

                        lines.append("| 参数名 | 类型 | 必填 | 说明 |")
                        lines.append("|:------|:----:|:----:|------|")
                        for prop_name, prop_info in properties.items():
                            if not isinstance(prop_info, dict):
                                continue
                            prop_type = prop_info.get('type', 'string')
                            is_required = '是' if prop_name in required else '否'
                            prop_desc = prop_info.get('description', '')
                            lines.append(f"| {prop_name} | {prop_type} | {is_required} | {prop_desc} |")
                        lines.append("")

                        lines.append("**请求示例**:")
                        lines.append("```json")
                        example = schema.get('example', {})
                        if example:
                            lines.append(json.dumps(example, ensure_ascii=False, indent=2))
                        lines.append("```")
                        lines.append("")

                if has_query or any(p.get('in') not in ('body',) for p in parameters):
                    lines.append("| 参数名 | 位置 | 类型 | 必填 | 说明 |")
                    lines.append("|:------|:----:|:----:|:----:|------|")
                    for param in parameters:
                        if param.get('in') == 'body':
                            continue
                        lines.append(f"| {param.get('name')} | {param.get('in')} | {param.get('type')} | {'是' if param.get('required') else '否'} | {param.get('description', '')} |")
                    lines.append("")

            responses = details.get('responses', {})
            if '200' in responses:
                response_200 = responses['200']
                schema = response_200.get('schema', {})

                lines.append("**响应参数**:")
                lines.append("")
                lines.append("| 字段 | 类型 | 说明 |")
                lines.append("|:-----|:-----|:-----|")

                props = schema.get('properties', {})
                for prop_name, prop_info in props.items():
                    if not isinstance(prop_info, dict):
                        continue
                    prop_type = prop_info.get('type', 'string')
                    prop_desc = prop_info.get('description', '')
                    lines.append(f"| {prop_name} | {prop_type} | {prop_desc} |")
                lines.append("")

                lines.append("**响应示例**:")
                lines.append("```json")
                example_response = {}
                if 'example' in schema:
                    example_response = schema.get('example')
                elif 'properties' in schema:
                    for prop_name, prop_info in schema.get('properties', {}).items():
                        if isinstance(prop_info, dict) and 'example' in prop_info:
                            example_response[prop_name] = prop_info['example']
                lines.append(json.dumps(example_response, ensure_ascii=False, indent=2) if example_response else '{}')
                lines.append("```")
                lines.append("")

            lines.append("---")
            lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))


def main():
    print("开始导出 API 文档...")

    from apps import create_app

    app = create_app(protect_swagger=False)

    with app.test_client() as client:
        response = client.get('/apispec_1.json')
        if response.status_code == 200:
            spec = response.get_json()

            tools_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.dirname(tools_dir)

            json_file = os.path.join(project_root, 'docs', 'API文档', 'swagger_spec.json')
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(spec, f, ensure_ascii=False, indent=2)
            print(f"JSON 规范已保存: {json_file}")

            md_file = os.path.join(project_root, 'docs', 'API文档', 'API文档.md')
            json_to_markdown(spec, md_file)
            print(f"文档导出成功: {md_file}")
            print(f"共导出 {len(spec.get('paths', {}))} 个接口")
        else:
            print(f"导出失败: {response.status_code}")


if __name__ == '__main__':
    main()
