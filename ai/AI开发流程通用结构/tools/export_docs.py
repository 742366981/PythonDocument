#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""导出 Flasgger 文档为 JSON 和 Markdown

使用方式：
    python tools/export_docs.py

注意：需从项目根目录执行
"""

import os
import sys
import json
from datetime import datetime

# 设置环境变量
os.environ['ENV_TYPE'] = 'dev'


def get_error_codes():
    """返回业务错误码定义"""
    return """## 错误码

| 错误码 | 说明 |
|:------:|:-----|
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或token过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

| 业务错误码 | 说明 | 错误信息示例 |
|:------:|:-----|:------------|
| 10001 | 用户不存在 | 用户不存在 |
| 10002 | 用户已禁用 | 用户已禁用 |
| 10003 | 密码错误 | 密码错误，剩余N次机会 |
| 10004 | 登录失败次数过多 | 登录失败次数过多，账户已锁定 |
| 10005 | 旧密码错误 | 旧密码错误 |
| 20001 | 角色不存在 | 角色不存在 |
| 20002 | 角色已存在 | 角色已存在 |
| 30001 | 用户角色关联已存在 | 用户角色关联已存在 |
| 30002 | 用户角色关联不存在 | 用户角色关联不存在 |

"""


def json_to_markdown(spec, output_file):
    """将 Swagger JSON 转换为 Markdown"""
    lines = []

    # 文档头部
    lines.append("# SSO用户系统 API 文档")
    lines.append("")
    lines.append(f"**版本**: {spec.get('info', {}).get('version', '1.0.0')}")
    lines.append(f"**更新日期**: {datetime.now().strftime('%Y-%m-%d')}")
    lines.append(f"**基础路径**: `http://{{host}}:{spec.get('port', '{{port}}')}/sso`")
    lines.append("")

    # 目录
    paths = spec.get('paths', {})
    tag_apis = {}

    for path, methods in paths.items():
        for method, details in methods.items():
            if method.upper() not in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                continue
            tags = details.get('tags', [])
            for tag in tags:
                if tag not in tag_apis:
                    tag_apis[tag] = []
                tag_apis[tag].append({'path': path, 'method': method.upper(), 'details': details})

    lines.append("## 目录")
    lines.append("")
    for tag in sorted(tag_apis.keys()):
        lines.append(f"- [{tag}](#{tag})")
    lines.append("")
    lines.append("---\n")

    # 通用规范
    lines.append("## 通用规范")
    lines.append("")
    lines.append("### 认证方式")
    lines.append("")
    lines.append("系统采用 JWT Token 认证机制。大部分接口需要携带 Token 才能访问。")
    lines.append("")
    lines.append("#### 1. 获取 Token")
    lines.append("")
    lines.append("**接口地址**: `POST /sso/auth/login`")
    lines.append("")
    lines.append("**请求参数**:")
    lines.append("")
    lines.append("| 参数名 | 类型 | 必填 | 说明 |")
    lines.append("|:------|:----:|:----:|------|")
    lines.append("| username | string | 是 | 用户名（手机号也可以） |")
    lines.append("| password | string | 是 | 密码（MD5格式） |")
    lines.append("")
    lines.append("**请求示例**:")
    lines.append("```json")
    lines.append('{"username": "admin", "password": "e10adc3949ba59abbe56e057f20f883e"}')
    lines.append("```")
    lines.append("")
    lines.append("**响应示例**:")
    lines.append("```json")
    lines.append("""{
  "code": 0,
  "msg": "success",
  "data": {
    "token": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    "user_id": 1,
    "username": "admin"
  }
}""")
    lines.append("```")
    lines.append("")
    lines.append("#### 2. 使用 Token")
    lines.append("")
    lines.append("在请求头中添加 Authorization 字段，格式为：")
    lines.append("")
    lines.append("```")
    lines.append("Authorization: Bearer {token}")
    lines.append("```")
    lines.append("")
    lines.append("---\n")

    # 错误码
    lines.append(get_error_codes())
    lines.append("---\n")

    # 各模块接口
    for tag in sorted(tag_apis.keys()):
        lines.append(f"## {tag}")
        lines.append("")

        apis = tag_apis[tag]
        apis.sort(key=lambda x: (x['path'], x['method']))

        for idx, api in enumerate(apis, 1):
            path = api['path']
            method = api['method']
            details = api['details']

            summary = details.get('summary', f'{method} {path}')
            description = details.get('description', '')
            description = description.replace('<br/>', '').strip() if description else ''
            requires_auth = details.get('security', [])
            is_auth_api = 'login' in path or 'logout' in path or 'verify' in path
            need_auth = bool(requires_auth) or not is_auth_api

            lines.append(f"### {idx}. {summary}")
            lines.append("")
            lines.append(f"**接口地址**: `{method} {path}`")
            lines.append("")
            lines.append(f"**需认证**: {'是' if need_auth else '否'}")
            lines.append("")

            if description:
                lines.append(f"**说明**: {description}")
                lines.append("")

            # 请求参数
            parameters = details.get('parameters', [])
            if parameters:
                lines.append("**请求参数**:")
                lines.append("")

                body_params = [p for p in parameters if p.get('in') == 'body']
                query_path_params = [p for p in parameters if p.get('in') in ('query', 'path')]

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
                        prop_example = prop_info.get('example', '')
                        if prop_example:
                            prop_desc = f"{prop_desc}（示例: {prop_example}）"
                        lines.append(f"| {prop_name} | {prop_type} | {is_required} | {prop_desc} |")
                    lines.append("")

                if query_path_params:
                    lines.append("| 参数名 | 位置 | 类型 | 必填 | 说明 |")
                    lines.append("|:------|:----:|:----:|:----:|------|")
                    for param in query_path_params:
                        lines.append(f"| {param.get('name')} | {param.get('in')} | {param.get('type')} | {'是' if param.get('required') else '否'} | {param.get('description', '')} |")
                    lines.append("")

                # 请求示例
                if body_params:
                    schema = body_params[0].get('schema', {})
                    example = schema.get('example', {})

                    if example:
                        lines.append("**请求示例**:")
                        lines.append("```json")
                        # 格式化JSON
                        example_str = json.dumps(example, ensure_ascii=False, indent=2)
                        lines.append(example_str)
                        lines.append("```")
                        lines.append("")
                    else:
                        # 根据properties生成示例
                        props = schema.get('properties', {})
                        if props:
                            lines.append("**请求示例**:")
                            lines.append("```json")
                            ex = {}
                            for pk, pv in props.items():
                                if isinstance(pv, dict):
                                    ex[pk] = pv.get('example', '' if pv.get('type') == 'string' else 0)
                            lines.append(json.dumps(ex, ensure_ascii=False, indent=2))
                            lines.append("```")
                            lines.append("")

            # 响应
            responses = details.get('responses', {})
            if '200' in responses:
                response_200 = responses['200']
                resp_schema = response_200.get('schema', {})
                resp_desc = response_200.get('description', '')

                lines.append(f"**响应说明**: {resp_desc}")
                lines.append("")

                # 响应参数
                resp_props = resp_schema.get('properties', {})
                if resp_props:
                    lines.append("**响应参数**:")
                    lines.append("")
                    lines.append("| 字段 | 类型 | 说明 |")
                    lines.append("|:-----|:-----|:-----|")

                    for prop_name, prop_info in resp_props.items():
                        if not isinstance(prop_info, dict):
                            continue
                        prop_type = prop_info.get('type', 'string')
                        prop_desc = prop_info.get('description', '')
                        lines.append(f"| {prop_name} | {prop_type} | {prop_desc} |")
                    lines.append("")

                # 响应示例
                lines.append("**响应示例**:")
                lines.append("```json")

                # 优先从examples字段获取完整响应示例
                example_response = response_200.get('examples', {}).get('application/json')
                if not example_response:
                    # 回退到从schema.properties构建
                    example_response = {}
                    for prop_name, prop_info in resp_props.items():
                        if isinstance(prop_info, dict):
                            example_response[prop_name] = prop_info.get('example', '')

                if not example_response:
                    example_response = {'code': 0, 'msg': 'success', 'data': {}}

                lines.append(json.dumps(example_response, ensure_ascii=False, indent=2))
                lines.append("```")
                lines.append("")

            lines.append("---\n")

    # 写入文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))


def main():
    print("开始导出 API 文档...")

    # 确保可以导入应用
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.path.insert(0, project_root)

    from apps import create_app

    app = create_app(protect_swagger=False)

    with app.test_client() as client:
        response = client.get('/apispec_1.json')
        if response.status_code == 200:
            spec = response.get_json()

            # 保存 JSON
            json_file = os.path.join(project_root, 'docs', 'API文档', 'swagger_spec.json')
            os.makedirs(os.path.dirname(json_file), exist_ok=True)
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(spec, f, ensure_ascii=False, indent=2)
            print(f"JSON 规范已保存: {json_file}")

            # 生成 Markdown
            md_file = os.path.join(project_root, 'docs', 'API文档', 'API文档.md')
            json_to_markdown(spec, md_file)
            print(f"Markdown 文档已保存: {md_file}")

            # 统计
            path_count = len(spec.get('paths', {}))
            method_count = sum(len([m for m in methods if m.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']])
                          for methods in spec.get('paths', {}).values())
            print(f"共导出 {path_count} 个路径，{method_count} 个接口")
        else:
            print(f"导出失败: {response.status_code}")


if __name__ == '__main__':
    main()
