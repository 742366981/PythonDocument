# API 设计规范

本文档定义通用的 API 设计规范，适用于所有后端框架（Flask、Node.js、Go、Java 等）。

---

## 1. 错误码规范（强制）

### 1.1 错误码定义

```python
class ErrCode:
    SUCCESS = 0
    PARAM_ERROR = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404
    INTERNAL_ERROR = 500


ERROR_MESSAGES = {
    ErrCode.SUCCESS: '操作成功',
    ErrCode.PARAM_ERROR: '参数错误',
    ErrCode.UNAUTHORIZED: '未授权',
    ErrCode.FORBIDDEN: '禁止访问',
    ErrCode.NOT_FOUND: '资源不存在',
    ErrCode.INTERNAL_ERROR: '服务器内部错误',
}


class BizErrCode:
    # 业务错误码，从10001开始
    USER_NOT_FOUND = 10001
    USER_DISABLED = 10002
    # ... 其他业务错误码


BIZ_ERROR_MESSAGES = {
    BizErrCode.USER_NOT_FOUND: '用户不存在',
    # ...
}
```

### 1.2 错误码速查表

| code | 说明 | 使用场景 |
|:----:|:-----|:---------|
| 0 | 成功 | 操作成功 |
| 400 | 参数错误 | 请求参数校验失败 |
| 401 | 未授权 | 未登录或token过期 |
| 403 | 禁止访问 | 无权限 |
| 404 | 资源不存在 | 资源不存在 |
| 500 | 服务器错误 | 服务器内部错误 |
| 10001+ | 业务错误 | 业务逻辑错误（自定义） |

---

## 2. 响应规范（强制）

### 2.1 统一响应函数

```python
def api_success(data=None, msg='success', code=0):
    """成功响应"""
    response = {'code': code, 'msg': msg}
    if data is not None:
        response['data'] = data
    return jsonify(response)


def api_error(code, msg=None):
    """错误响应"""
    if msg is None:
        msg = get_error_message(code)
    response = {'code': code, 'msg': msg}
    return jsonify(response)


def api_page(records, page_no, page_size, total_count):
    """分页响应"""
    total_page = (total_count + page_size - 1) // page_size if page_size > 0 else 0
    return jsonify({
        'code': 0,
        'msg': 'success',
        'data': {
            'records': records,
            'page_no': page_no,
            'page_size': page_size,
            'total_page': total_page,
            'total_count': total_count
        }
    })
```

### 2.2 响应状态码

| code | 说明 |
|:----:|:-----|
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或token过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

### 2.3 响应使用规范

| 场景 | 使用函数 | data字段 |
|:-----|:--------|:---------|
| 创建成功 | `api_success` | 返回新记录的id |
| 操作成功（更新/删除/状态修改） | `api_success` | 无（只有msg） |
| 列表/详情查询成功 | `api_success` | 返回查询数据 |
| 分页查询成功 | `api_page` | 返回分页结构 |
| 参数/未登录/无权限/服务器错误 | `api_error` | 无 |

### 2.4 关键特性

1. **所有接口统一返回 HTTP 200**，通过响应体 `code` 字段判断成功/失败
2. **`api_success` 不传data时不返回data字段**，节省带宽
3. **操作类接口（更新/删除）成功时不需要返回data**
4. **全局异常处理器统一返回"服务器内部错误"**，不暴露具体错误信息

---

## 3. API路径规范（强制）

### 3.1 路径规范

| 类型 | 规则 | 示例 |
|:-----|:-----|:-----|
| URL路径 | 中横线分隔 | /exchange-rate |
| 列表接口 | /list | /user/list |
| 详情接口 | /detail | /user/detail |
| 创建接口 | /create | POST /user/create |
| 更新接口 | /update | POST /user/update |
| 状态修改 | /update-status | POST /user/update-status |
| 删除接口 | /delete | POST /user/delete |
| 批量删除 | /batch-delete | POST /user/batch-delete |
| 导入接口 | /import | POST /user/import |
| 导出接口 | /export | GET /user/export |
| 模板下载 | /template/download | GET /user/template/download |
| 下拉接口 | /dict/{dict_type} | GET /user/dict/status |

### 3.2 下拉接口响应格式

统一返回完整字典对象：

```json
{
  "code": 0,
  "msg": "success",
  "data": [
    {
      "dictCode": 1146,
      "dictSort": 20,
      "dictLabel": "PayPal",
      "dictValue": "PAY_PAL",
      "dictType": "account_type",
      "cssClass": null,
      "listClass": null,
      "defaultFlag": "1",
      "status": "0",
      "remark": null
    }
  ]
}
```

**字段映射：**

| 字典字段 | 数据库字段 | 说明 |
|:---------|:-----------|:-----|
| dictCode | id | 唯一标识 |
| dictLabel | name | 显示文本（没有name时用code） |
| dictValue | code | 存储值（没有code时用name） |
| dictSort | sort | 排序号 |
| dictType | type | 字典类型 |
| cssClass | css_class | CSS样式类 |
| listClass | list_class | 列表样式类 |
| defaultFlag | default_flag | 默认标志 |
| status | status | 状态 |
| remark | remark | 备注 |

**只有一个字段时**：dictLabel 和 dictValue 都用那一个。

---

## 4. API参数命名规范（强制）

### 4.1 单资源接口

**统一使用 `id` 作为参数名**：

| 接口类型 | 参数位置 | 参数名 | 示例 |
|:---------|:--------|:-------|:-----|
| 详情 | query | `id` | `GET /user/detail?id=1` |
| 更新 | body | `id` | `POST /user/update {"id": 1, "username": "xxx"}` |
| 删除 | body | `id` | `POST /user/delete {"id": 1}` |

**✅ 正确示例：**
```python
GET /user/detail?id=1
POST /user/update {"id": 1, "username": "xxx"}
POST /user/delete {"id": 1}
```

**❌ 错误示例：**
```python
GET /user/detail?user_id=1
POST /user/update {"user_id": 1, "username": "xxx"}
POST /user/delete {"user_id": 1}
```

### 4.2 关联表接口

**关联表保留具体参数名**（ user_id、role_id 等），更清晰明确：

| 接口 | 参数 | 示例 |
|:-----|:-----|:-----|
| 用户角色绑定 | user_id, role_id | `POST /user_role/bind {"user_id": 1, "role_id": 1}` |
| 用户角色解绑 | user_id, role_id | `POST /user_role/unbind {"user_id": 1, "role_id": 1}` |
| 查询用户角色 | user_id | `GET /user_role/list?user_id=1` |

### 4.3 参数命名速查表

| 场景 | 参数名 | 示例 |
|:-----|:-------|:-----|
| 单资源主键 | `id` | `?id=1` 或 `{"id": 1}` |
| 单资源外键 | `xxx_id` | `role_id=1` |
| 关联表主键 | `xxx_id` + `yyy_id` | `{"user_id": 1, "role_id": 1}` |

---

## 5. 参数验证规范（强制）

### 5.1 验证函数

```python
def validate_phone(phone):
    if not phone:
        return False, '手机号不能为空'
    if not re.match(r'^1[3-9]\d{9}$', phone):
        return False, '手机号格式不正确'
    return True, None


def validate_password(password):
    if not password:
        return False, '密码不能为空'
    if len(password) < 6:
        return False, '密码长度不能少于6位'
    return True, None


def validate_email(email):
    if not email:
        return False, '邮箱不能为空'
    if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
        return False, '邮箱格式不正确'
    return True, None
```

### 5.2 查询条件类型

#### 5.2.1 单选查询

**单值精确匹配**：

```python
# GET /user/list?status=1
# GET /user/list?role_id=3

query = User.query
if status := request.args.get('status'):
    query = query.filter(User.status == int(status))
if role_id := request.args.get('role_id'):
    query = query.filter(User.role_id == int(role_id))
```

#### 5.2.2 多选查询

**多个值任一匹配（IN查询）**：

```python
# GET /user/list?role_id=1,2,3
# GET /user/list?status=1,2

def parse_multi_ids(value):
    """解析逗号分隔的ID列表"""
    if not value:
        return []
    if isinstance(value, list):
        return value
    return [int(x) for x in value.split(',') if x.strip().isdigit()]

role_ids = parse_multi_ids(request.args.get('role_id'))
if role_ids:
    query = query.filter(User.role_id.in_(role_ids))
```

#### 5.2.3 范围查询

**数值范围**：

```python
# GET /user/list?create_time_start=2024-01-01&create_time_end=2024-12-31
# GET /user/list?balance_min=100&balance_max=1000

create_time_start = request.args.get('create_time_start')
create_time_end = request.args.get('create_time_end')
balance_min = request.args.get('balance_min')
balance_max = request.args.get('balance_max')

if create_time_start:
    query = query.filter(User.create_time >= create_time_start)
if create_time_end:
    query = query.filter(User.create_time <= create_time_end)
if balance_min:
    query = query.filter(User.balance >= float(balance_min))
if balance_max:
    query = query.filter(User.balance <= float(balance_max))
```

**时间范围**：

```python
# GET /order/list?order_time_start=2024-01-01 00:00:00&order_time_end=2024-01-31 23:59:59

from datetime import datetime

order_time_start = request.args.get('order_time_start')
order_time_end = request.args.get('order_time_end')

if order_time_start:
    start_dt = datetime.strptime(order_time_start, '%Y-%m-%d %H:%M:%S')
    query = query.filter(Order.create_time >= start_dt)
if order_time_end:
    end_dt = datetime.strptime(order_time_end, '%Y-%m-%d %H:%M:%S')
    query = query.filter(Order.create_time <= end_dt)
```

#### 5.2.4 模糊查询

**字符串模糊匹配**：

```python
# GET /user/list?username=admin
# GET /user/list?real_name=张

username = request.args.get('username', '').strip()
if username:
    query = query.filter(User.username.like(f'%{username}%'))
```

#### 5.2.5 组合查询

**多种条件组合**：

```python
# GET /user/list?status=1&role_id=1,2&create_time_start=2024-01-01&username=admin

def build_query():
    query = User.query

    # 单选
    if status := request.args.get('status'):
        query = query.filter(User.status == int(status))

    # 多选
    role_ids = parse_multi_ids(request.args.get('role_id'))
    if role_ids:
        query = query.filter(User.role_id.in_(role_ids))

    # 范围
    if create_time_start := request.args.get('create_time_start'):
        query = query.filter(User.create_time >= create_time_start)

    # 模糊
    if username := request.args.get('username', '').strip():
        query = query.filter(User.username.like(f'%{username}%'))

    return query
```

---

## 6. 接口文档规范（强制）

### 6.1 强制要求：先写文档，后写代码

> **每个接口必须先在视图函数docstring中编写文档，再编写视图函数实现。**

**必须包含完整字段**：summary、description、parameters（含各参数example）、responses（含examples示例）。

### 6.2 docstring格式要求

> **重要：标题与`---`之间不能有空行**

**正确格式：**
```python
@auth_bp.route('/login', methods=['POST'])
def login():
    """用户登录
---
tags:
  - 系统管理/认证管理
summary: 用户登录
description: 使用用户名或手机号和密码登录，返回Token。
parameters:
  - in: body
    name: body
    required: true
    schema:
      type: object
      properties:
        username:
          type: string
          description: 用户名（手机号也可以）
          example: admin
        password:
          type: string
          description: 密码(MD5)
          example: e10adc3949ba59abbe56e057f20f883e
      required:
        - username
        - password
responses:
  200:
    description: 登录成功
    examples:
      application/json:
        code: 0
        data:
          token: "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
          user_id: 1
          username: "admin"
        msg: "success"
"""
    # 视图函数实现
```

**错误格式（会导致description显示<br/>）：**
```python
# ❌ 标题和---之间有空行
def login():
    """用户登录

    ---
    tags:
    ...
"""
```

### 6.3 必需字段

| 字段 | 必须 | 说明 |
|:-----|:-----|:-----|
| summary | ✅ | 接口简短描述 |
| description | ✅ | 接口详细描述 |
| parameters | ✅ | 请求参数（位置、名称、类型、必填、说明、示例） |
| responses | ✅ | 响应格式（状态码、描述、示例） |

---

## 7. 导入导出接口规范（强制）

### 7.1 模板设计标准

| 要求 | 说明 |
|:-----|:-----|
| 模板列名 | = 数据库字段含义，简短命名（如"名称"而非"名称字段"） |
| 模板列 | = 新增接口接收的参数（去除系统字段如id、create_time等） |
| 导出列 | = 模板列（保持对称） |
| 唯一约束 | 明确组合唯一字段，重复时upsert |
| 关联查询 | 填写code（如"US"），内部转ID |

### 7.2 是/否字段规范

| 模板列名 | 导入填写 | 内部存储 |
|:---------|:---------|:---------|
| 是否启用 | "是" / "否" | 1 / 0 |
| 是否含税 | "是" / "否" | 1 / 0 |
| 是否必填 | "是" / "否" | 1 / 0 |

### 7.3 导入接口docstring示例

```python
@bp.route('/import', methods=['POST'])
def import_data():
    """导入数据
---
tags:
  - 模块管理
summary: 批量导入数据
description: 支持Excel文件导入，自动识别新增和更新。唯一字段冲突时执行更新。
parameters:
  - in: formData
    name: file
    type: file
    required: true
    description: Excel文件(.xlsx)
responses:
  200:
    description: 导入结果
    examples:
      application/json:
        code: 0
        data:
          total: 100
          success: 98
          fail: 2
          errors:
            - row: 3
              message: "第4行角色编码不存在"
        msg: "导入成功"
"""
```

### 7.4 导入逻辑实现

```python
@bp.route('/import', methods=['POST'])
def import_data():
    # 1. 获取文件
    if 'file' not in request.files:
        return api_error(400, '请上传文件')
    file = request.files['file']
    if not file.filename.endswith('.xlsx'):
        return api_error(400, '仅支持.xlsx格式')

    # 2. 读取Excel
    from openpyxl import load_workbook
    wb = load_workbook(file)
    ws = wb.active
    rows = list(ws.iter_rows(values_only=True))

    # 3. 解析表头（第一行为表头）
    headers = [str(cell).strip() if cell else '' for cell in rows[0]]
    # 表头与字段映射：模板列名 -> 字段名
    header_map = {
        '角色编码': 'role_code',
        '角色名称': 'role_name',
        '是否启用': 'status',
        # ... 其他字段映射
    }

    # 4. 逐行处理
    success_count = 0
    fail_count = 0
    errors = []

    for i, row in enumerate(rows[1:], start=2):  # 从第2行开始
        try:
            # 解析行数据
            row_data = dict(zip(headers, row))
            # 转换为字段数据
            field_data = {}
            for header, value in row_data.items():
                if header in header_map:
                    field_name = header_map[header]
                    # 是/否转换
                    if field_name == 'status':
                        field_data[field_name] = 1 if value == '是' else 0
                    else:
                        field_data[field_name] = value

            # 唯一性检查（根据role_code）
            role_code = field_data.get('role_code')
            existing = Role.query.filter_by(role_code=role_code).first()
            if existing:
                # 更新
                for key, value in field_data.items():
                    setattr(existing, key, value)
            else:
                # 新增
                role = Role(**field_data)
                db.session.add(role)

            success_count += 1

        except Exception as e:
            fail_count += 1
            errors.append({'row': i, 'message': str(e)})

    db.session.commit()

    return api_success({
        'total': success_count + fail_count,
        'success': success_count,
        'fail': fail_count,
        'errors': errors[:10]  # 最多返回10条错误
    }, '导入完成')
```

### 7.5 导入参数接收规范

| 字段类型 | 模板填写示例 | 内部存储 | 说明 |
|:---------|:-------------|:---------|:-----|
| 普通文本 | 直接填写 | 保持原值 | - |
| 编码字段 | "ADMIN" | "ADMIN" | 用于唯一性匹配 |
| 名称字段 | "管理员" | "管理员" | 用于显示 |
| 是/否字段 | "是" / "否" | 1 / 0 | 自动转换 |
| 关联字段 | "ADMIN" | 自动转ID | 先查code再查name |

### 7.6 导出接口docstring示例

```python
@bp.route('/export', methods=['GET'])
def export_data():
    """导出数据
---
tags:
  - 模块管理
summary: 导出数据
description: 导出符合查询条件的角色数据为Excel文件。
parameters:
  - in: query
    name: status
    type: string
    description: 状态筛选（可选），1启用 0禁用
  - in: query
    name: role_ids
    type: string
    description: 角色ID列表（可选），逗号分隔，如1,2,3
responses:
  200:
    description: Excel文件下载
    content-type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
"""
```

### 7.7 导出逻辑实现

```python
@bp.route('/export', methods=['GET'])
def export_data():
    # 1. 构建查询
    query = Role.query

    # 单选筛选
    if status := request.args.get('status'):
        query = query.filter(Role.status == int(status))

    # 多选筛选
    if role_ids := request.args.get('role_ids'):
        id_list = [int(x) for x in role_ids.split(',') if x.strip().isdigit()]
        if id_list:
            query = query.filter(Role.id.in_(id_list))

    roles = query.all()

    # 2. 构建导出数据
    from openpyxl import Workbook
    wb = Workbook()
    ws = wb.active
    ws.title = '角色数据'

    # 表头（与模板保持一致）
    headers = ['角色编码', '角色名称', '是否启用', '创建时间']
    ws.append(headers)

    # 数据行
    for role in roles:
        ws.append([
            role.role_code,
            role.role_name,
            '是' if role.status == 1 else '否',
            role.create_time.strftime('%Y-%m-%d %H:%M:%S') if role.create_time else ''
        ])

    # 3. 返回文件
    from io import BytesIO
    output = BytesIO()
    wb.save(output)
    output.seek(0)

    from flask import make_response
    response = make_response(output.getvalue())
    response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    response.headers['Content-Disposition'] = 'attachment; filename=role_export.xlsx'

    return response
```

### 7.8 模板下载接口

```python
@bp.route('/template/download', methods=['GET'])
def download_template():
    """下载导入模板
---
tags:
  - 模块管理
summary: 下载导入模板
description: 下载角色导入的Excel模板文件。
responses:
  200:
    description: Excel模板文件
    content-type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
"""
    from openpyxl import Workbook
    from io import BytesIO

    wb = Workbook()
    ws = wb.active
    ws.title = '角色导入模板'

    # 表头
    headers = ['角色编码', '角色名称', '是否启用']
    ws.append(headers)

    # 示例数据（可选）
    ws.append(['ADMIN', '管理员', '是'])

    output = BytesIO()
    wb.save(output)
    output.seek(0)

    from flask import make_response
    response = make_response(output.getvalue())
    response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    response.headers['Content-Disposition'] = 'attachment; filename=role_template.xlsx'

    return response
```

### 7.9 导入导出完整流程图

```
导入流程：
┌─────────────────┐
│  1. 检查文件    │
└────────┬────────┘
         ▼
┌─────────────────┐
│  2. 读取Excel   │ ← 模板列名映射到字段名
└────────┬────────┘
         ▼
┌─────────────────┐
│  3. 逐行校验    │ ← 是/否转换、必填校验、格式校验
└────────┬────────┘
         ▼
    ┌────┴────┐
    │  4. 唯一性匹配  │ ← 先查code，不存在查name
    └────┬────┘
         ▼
    ┌────┴────┐
    │  5. 判断新增/更新  │
    └────┬────┘
         ▼
┌─────────────────┐
│  6. 提交事务    │
└────────┬────────┘
         ▼
┌─────────────────┐
│  7. 返回结果    │ ← 成功数、失败数、错误详情
└─────────────────┘

导出流程：
┌─────────────────┐
│  1. 获取查询条件 │
└────────┬────────┘
         ▼
┌─────────────────┐
│  2. 构建查询     │ ← 支持单选/多选/范围查询
└────────┬────────┘
         ▼
┌─────────────────┐
│  3. 执行查询     │
└────────┬────────┘
         ▼
┌─────────────────┐
│  4. 构建Excel   │ ← 导出列=模板列
└────────┬────────┘
         ▼
┌─────────────────┐
│  5. 返回文件下载 │
└─────────────────┘
```

---

## 8. 标签对照表（强制）

| 大模块 | 子模块 | 标签 |
|:-------|:-------|:-----|
| 系统管理 | 认证管理 | 系统管理/认证管理 |
| 系统管理 | 用户管理 | 系统管理/用户管理 |
| 系统管理 | 角色管理 | 系统管理/角色管理 |
| 系统管理 | 权限管理 | 系统管理/权限管理 |
| 系统管理 | 用户角色管理 | 系统管理/用户角色管理 |
| 基础数据 | 字典管理 | 基础数据/字典管理 |
| 基础数据 | 国家管理 | 基础数据/国家管理 |
| 基础数据 | 平台管理 | 基础数据/平台管理 |
| 基础数据 | 部门管理 | 基础数据/部门管理 |
