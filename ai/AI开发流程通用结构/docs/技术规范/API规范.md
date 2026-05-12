# API 设计规范

本文档定义通用的 API 设计规范，适用于所有后端框架（Flask、Node.js、Go、Java 等）。

> **核心原则**：规范内容语言无关，代码示例仅作参考

---

## 1. 错误码规范（强制）

### 1.1 错误码定义（强制）

错误码采用**分层设计**：

| 层级 | 范围 | 说明 |
|:-----|:-----|:-----|
| 系统错误码 | 0, 400-599 | HTTP状态语义，通用 |
| 业务错误码 | 10001+ | 自定义业务错误 |

**系统错误码定义**：

| code | 说明 | 使用场景 |
|:----:|:-----|:---------|
| 0 | 成功 | 操作成功 |
| 400 | 参数错误 | 请求参数校验失败 |
| 401 | 未授权 | 未登录或token过期 |
| 403 | 禁止访问 | 无权限 |
| 404 | 资源不存在 | 资源不存在 |
| 500 | 服务器错误 | 服务器内部错误 |

**业务错误码定义**：

| code | 说明 | 使用场景 |
|:----:|:-----|:---------|
| 10001 | 用户不存在 | 登录时用户不存在 |
| 10002 | 用户已禁用 | 用户状态不可用 |
| ... | 其他 | 按业务需求扩展 |

> 📝 **Python示例参考**
```python
class ErrCode:
    SUCCESS = 0
    PARAM_ERROR = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404
    INTERNAL_ERROR = 500

class BizErrCode:
    USER_NOT_FOUND = 10001
    USER_DISABLED = 10002
```

> 📝 **Java示例参考**
```java
public enum ErrCode {
    SUCCESS(0),
    PARAM_ERROR(400),
    UNAUTHORIZED(401),
    FORBIDDEN(403),
    NOT_FOUND(404),
    INTERNAL_ERROR(500);
    private final int code;
}
```

### 1.2 错误码速查表（强制）

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

### 2.1 统一响应结构（所有语言适用）

**响应格式**：

| 字段 | 类型 | 必须 | 说明 |
|:-----|:-----|:-----|:-----|
| code | int | 是 | 状态码，0=成功，非0=失败 |
| msg | string | 是 | 消息，成功为"success"或自定义 |
| data | object | 否 | 数据，null时不返回此字段 |

**JSON示例**：
```json
// 成功
{"code": 0, "msg": "success", "data": {"id": 1}}

// 失败
{"code": 400, "msg": "参数错误"}

// 成功无data
{"code": 0, "msg": "删除成功"}
```

> 📝 **Python示例参考**
```python
def api_success(data=None, msg='success', code=0):
    response = {'code': code, 'msg': msg}
    if data is not None:
        response['data'] = data
    return jsonify(response)
```

> 📝 **Java示例参考**
```java
public class Response<T> {
    private int code;
    private String msg;
    private T data;
    // getters, setters
}
```

### 2.2 分页响应结构（所有语言适用）

**分页格式**：

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| records | array | 数据列表 |
| page_no | int | 当前页码 |
| page_size | int | 每页条数 |
| total_page | int | 总页数 |
| total_count | int | 总记录数 |

**JSON示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "records": [],
    "page_no": 1,
    "page_size": 20,
    "total_page": 5,
    "total_count": 100
  }
}
```

> 📝 **Python示例参考**
```python
def api_page(records, page_no, page_size, total_count):
    total_page = (total_count + page_size - 1) // page_size if page_size > 0 else 0
    return jsonify({
        'code': 0, 'msg': 'success',
        'data': {
            'records': records,
            'page_no': page_no,
            'page_size': page_size,
            'total_page': total_page,
            'total_count': total_count
        }
    })
```

### 2.3 响应状态码（强制）

| code | 说明 |
|:----:|:-----|
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或token过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

### 2.4 响应使用规范（强制）

| 场景 | data字段 | 说明 |
|:-----|:---------|:-----|
| 创建成功 | 返回新记录的id | `{"code": 0, "msg": "success", "data": {"id": 1}}` |
| 操作成功（更新/删除/状态修改） | 无 | `{"code": 0, "msg": "删除成功"}` |
| 列表/详情查询成功 | 返回查询数据 | `{"code": 0, "msg": "success", "data": {...}}` |
| 分页查询成功 | 返回分页结构 | 使用分页格式 |
| 参数/未登录/无权限/服务器错误 | 无 | `{"code": 400, "msg": "参数错误"}` |

### 2.5 关键特性（强制）

1. **所有接口统一返回 HTTP 200**，通过响应体 `code` 字段判断成功/失败
2. **`api_success` 不传data时不返回data字段**，节省带宽
3. **操作类接口（更新/删除）成功时不需要返回data**
4. **全局异常处理器统一返回"服务器内部错误"**，不暴露具体错误信息

---

## 3. API路径规范（强制）

### 3.1 路径规范（强制）

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

### 3.2 下拉接口响应格式（强制）

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

**字段映射**：

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

### 4.1 单资源接口（强制）

**统一使用 `id` 作为参数名**：

| 接口类型 | 参数位置 | 参数名 | 示例 |
|:---------|:--------|:-------|:-----|
| 详情 | query | `id` | `GET /user/detail?id=1` |
| 更新 | body | `id` | `POST /user/update {"id": 1, "username": "xxx"}` |
| 删除 | body | `id` | `POST /user/delete {"id": 1}` |

**✅ 正确示例：**
```
GET /user/detail?id=1
POST /user/update {"id": 1, "username": "xxx"}
POST /user/delete {"id": 1}
```

**❌ 错误示例：**
```
GET /user/detail?user_id=1
POST /user/update {"user_id": 1, "username": "xxx"}
POST /user/delete {"user_id": 1}
```

### 4.2 关联表接口（强制）

**关联表保留具体参数名**（ user_id、role_id 等），更清晰明确：

| 接口 | 参数 | 示例 |
|:-----|:-----|:-----|
| 用户角色绑定 | user_id, role_id | `POST /user_role/bind {"user_id": 1, "role_id": 1}` |
| 用户角色解绑 | user_id, role_id | `POST /user_role/unbind {"user_id": 1, "role_id": 1}` |
| 查询用户角色 | user_id | `GET /user_role/list?user_id=1` |

### 4.3 参数命名速查表（强制）

| 场景 | 参数名 | 示例 |
|:-----|:-------|:-----|
| 单资源主键 | `id` | `?id=1` 或 `{"id": 1}` |
| 单资源外键 | `xxx_id` | `role_id=1` |
| 关联表主键 | `xxx_id` + `yyy_id` | `{"user_id": 1, "role_id": 1}` |

---

## 5. 参数验证规范（强制）

### 5.1 验证规则（强制）

**验证函数应返回 (是否通过, 错误信息)**：

| 验证类型 | 规则 | 错误信息示例 |
|:---------|:-----|:-------------|
| 必填检验 | 字段不能为空 | "xxx不能为空" |
| 长度检验 | 字符串长度范围 | "xxx长度不能超过N" |
| 格式检验 | 正则表达式匹配 | "xxx格式不正确" |
| 范围检验 | 数值/日期范围 | "xxx必须在N到M之间" |
| 唯一性检验 | 数据库中不存在重复 | "xxx已存在" |

### 5.2 常见验证函数（强制）

| 验证项 | 规则 | 错误信息 |
|:-------|:-----|:---------|
| 手机号 | 1[3-9]\d{9} | "手机号格式不正确" |
| 邮箱 | [\w.-]+@[\w.-]+\.\w+ | "邮箱格式不正确" |
| 密码 | 长度≥6 | "密码长度不能少于6位" |
| URL | http/https开头 | "URL格式不正确" |

> 📝 **Python示例参考**
```python
def validate_phone(phone):
    if not phone:
        return False, '手机号不能为空'
    if not re.match(r'^1[3-9]\d{9}$', phone):
        return False, '手机号格式不正确'
    return True, None
```

### 5.3 查询条件类型（强制）

#### 5.3.1 单选查询（强制）

**单值精确匹配**：参数值与字段精确相等

```
GET /user/list?status=1
GET /user/list?role_id=3
```

#### 5.3.2 多选查询（强制）

**多个值任一匹配（IN查询）**：逗号分隔

```
GET /user/list?role_id=1,2,3
GET /user/list?status=1,2
```

#### 5.3.3 范围查询（强制）

**数值范围**：_min, _max 后缀

```
GET /user/list?balance_min=100&balance_max=1000
```

**时间范围**：_start, _end 后缀

```
GET /order/list?order_time_start=2024-01-01 00:00:00&order_time_end=2024-01-31 23:59:59
```

#### 5.3.4 模糊查询（强制）

**字符串模糊匹配**：直接传递字符串，前端自动%

```
GET /user/list?username=admin
GET /user/list?real_name=张
```

#### 5.3.5 组合查询（强制）

**多种条件组合**：支持上述所有条件的任意组合

```
GET /user/list?status=1&role_id=1,2&create_time_start=2024-01-01&username=admin
```

> 📝 **Python查询构建示例参考**
```python
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

### 6.1 强制要求：先写文档，后写代码（强制）

> **每个接口必须先在视图函数docstring中编写文档，再编写视图函数实现。**

### 6.2 必需字段（强制）

| 字段 | 必须 | 说明 |
|:-----|:-----|:-----|
| summary | 是 | 接口简短描述 |
| description | 是 | 接口详细描述 |
| parameters | 是 | 请求参数列表 |
| responses | 是 | 响应格式列表 |

**parameters 子字段**：

| 子字段 | 必须 | 说明 |
|:-------|:-----|:-----|
| name | 是 | 参数名称 |
| in | 是 | 参数位置（body/query/path/formData） |
| required | 是 | 是否必填 |
| type | 是 | 参数类型（string/integer/boolean/file） |
| description | 否 | 参数说明 |
| example | 否 | 参数示例值 |

**responses 子字段**：

| 子字段 | 必须 | 说明 |
|:-------|:-----|:-----|
| 状态码 | 是 | HTTP状态码 |
| description | 是 | 响应描述 |
| example | 否 | 响应示例 |

### 6.3 docstring模板（示例参考）

> 📝 **Flask docstring格式示例参考**
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

**重要：标题与`---`之间不能有空行**

---

## 7. 导入导出接口规范（强制）

### 7.1 模板设计标准（强制）

| 要求 | 说明 |
|:-----|:-----|
| 模板列名 | = 数据库字段含义，简短命名（如"名称"而非"名称字段"） |
| 模板列 | = 新增接口接收的参数（去除系统字段如id、create_time等） |
| 导出列 | = 模板列（保持对称） |
| 唯一约束 | 明确组合唯一字段，默认重复则失败；如需更新需用户明确说明 |
| 关联查询 | 填写code（如"US"），内部转ID |

### 7.2 是/否字段规范（强制）

| 模板列名 | 导入填写 | 内部存储 |
|:---------|:---------|:---------|
| 是否启用 | "是" / "否" | 1 / 0 |
| 是否含税 | "是" / "否" | 1 / 0 |
| 是否必填 | "是" / "否" | 1 / 0 |

### 7.3 导入参数接收规范（强制）

| 字段类型 | 模板填写示例 | 内部存储 | 说明 |
|:---------|:-------------|:---------|:-----|
| 普通文本 | 直接填写 | 保持原值 | - |
| 编码字段 | "ADMIN" | "ADMIN" | 用于唯一性匹配 |
| 名称字段 | "管理员" | "管理员" | 用于显示 |
| 是/否字段 | "是" / "否" | 1 / 0 | 自动转换 |
| 关联字段 | "ADMIN" | 自动转ID | 先查code再查name |

### 7.4 导入响应格式（强制）

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| total | int | 总处理数 |
| success | int | 成功数 |
| fail | int | 失败数 |
| errors | array | 错误详情列表（最多10条） |

**错误详情格式**：

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| row | int | 失败行号 |
| message | string | 错误原因 |

### 7.5 导入接口文档模板（示例参考）

> 📝 **导入接口docstring示例参考**
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

### 7.6 导入逻辑流程（强制）

**步骤**：
1. 检查文件存在和格式
2. 读取Excel表头，映射到字段名
3. 逐行校验（必填/格式/是-否转换）
4. 唯一性匹配（先查code，不存在查name）
5. 判断新增/更新
6. 事务提交
7. 返回结果（成功数/失败数/错误详情）

> 📝 **导入逻辑Python示例参考**
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

    # 3. 解析表头映射
    headers = [str(cell).strip() if cell else '' for cell in rows[0]]
    header_map = {'角色编码': 'role_code', '角色名称': 'role_name', '是否启用': 'status'}

    # 4. 逐行处理
    success_count = 0
    fail_count = 0
    errors = []

    for i, row in enumerate(rows[1:], start=2):
        try:
            row_data = dict(zip(headers, row))
            field_data = {}
            for header, value in row_data.items():
                if header in header_map:
                    field_name = header_map[header]
                    if field_name == 'status':
                        field_data[field_name] = 1 if value == '是' else 0
                    else:
                        field_data[field_name] = value

            # 5. 唯一性匹配：默认重复则失败
            role_code = field_data.get('role_code')
            existing = Role.query.filter_by(role_code=role_code).first()
            if existing:
                raise Exception(f'角色编码{role_code}已存在')
            role = Role(**field_data)
            db.session.add(role)
            success_count += 1
        except Exception as e:
            fail_count += 1
            errors.append({'row': i, 'message': str(e)})

    db.session.commit()
    return api_success({'total': success_count + fail_count, 'success': success_count, 'fail': fail_count, 'errors': errors[:10]}, '导入完成')
```

### 7.7 导出接口文档模板（示例参考）

> 📝 **导出接口docstring示例参考**
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

### 7.8 导出逻辑流程（强制）

**步骤**：
1. 获取查询条件
2. 构建查询（支持单选/多选/范围查询）
3. 执行查询
4. 构建Excel（导出列=模板列）
5. 返回文件下载

> 📝 **导出逻辑Python示例参考**
```python
@bp.route('/export', methods=['GET'])
def export_data():
    # 1. 构建查询
    query = Role.query
    if status := request.args.get('status'):
        query = query.filter(Role.status == int(status))
    if role_ids := request.args.get('role_ids'):
        id_list = [int(x) for x in role_ids.split(',') if x.strip().isdigit()]
        if id_list:
            query = query.filter(Role.id.in_(id_list))
    roles = query.all()

    # 2. 构建Excel
    from openpyxl import Workbook
    wb = Workbook()
    ws = wb.active
    ws.title = '角色数据'
    headers = ['角色编码', '角色名称', '是否启用', '创建时间']
    ws.append(headers)
    for role in roles:
        ws.append([
            role.role_code, role.role_name,
            '是' if role.status == 1 else '否',
            role.create_time.strftime('%Y-%m-%d %H:%M:%S') if role.create_time else ''
        ])

    # 3. 返回文件
    from io import BytesIO
    output = BytesIO()
    wb.save(output)
    output.seek(0)
    response = make_response(output.getvalue())
    response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    response.headers['Content-Disposition'] = 'attachment; filename=role_export.xlsx'
    return response
```

### 7.9 模板下载接口（强制）

提供标准化模板下载，确保用户使用正确格式。

> 📝 **模板下载Python示例参考**
```python
@bp.route('/template/download', methods=['GET'])
def download_template():
    from openpyxl import Workbook
    from io import BytesIO
    wb = Workbook()
    ws = wb.active
    ws.title = '角色导入模板'
    headers = ['角色编码', '角色名称', '是否启用']
    ws.append(headers)
    ws.append(['ADMIN', '管理员', '是'])
    output = BytesIO()
    wb.save(output)
    output.seek(0)
    response = make_response(output.getvalue())
    response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    response.headers['Content-Disposition'] = 'attachment; filename=role_template.xlsx'
    return response
```

### 7.10 导入导出完整流程图（强制）

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

> **Swagger 标签规范引用**：详见 `docs/API文档/swagger_template.md` 末尾的标签对照表

**标签格式**：`大模块/子模块`

**使用示例**：
```python
@auth_bp.route('/login', methods=['POST'])
def login():
    """用户登录
---
tags:
  - 系统管理/认证管理
...
"""
```
