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

### 3.1 接口前缀规范（强制）

**所有接口必须使用项目英文标识作为前缀**，与数据库表前缀保持一致：

| 前缀类型 | 格式 | 示例 |
|:---------|:-----|:-----|
| 业务接口 | `/{项目前缀}/{模块}/{操作}` | `/ec/order/list` |
| 基础数据接口 | `/{项目前缀}/base_data/{表名}` | `/ec/base_data/order_status` |

> ⚠️ **项目英文标识** 与数据库表前缀保持一致，参考 `数据库规范.md` 第5.2节前缀选择建议

**前缀选择示例**：

| 项目类型 | 项目英文标识 | 接口示例 |
|:---------|:------------|:---------|
| 电商订单 | `ec` | `GET /ec/order/list` |
| 成本计算器 | `cbjsq` | `GET /cbjsq/product/list` |
| 客户管理 | `crm` | `GET /crm/customer/list` |
| 乙方外包项目 | `proj_{甲方简写}` | `GET /proj_acme/order/list` |

### 3.2 路径规范（强制）

**在接口前缀之后，路径片段使用中横线分隔**（如 `exchange-rate`），接口路径按以下规则命名：

| 接口类型 | 路径规则 | 完整示例 |
|:---------|:---------|:---------|
| 列表接口 | `/list` | `GET /{前缀}/order/list` |
| 详情接口 | `/detail` | `GET /{前缀}/order/detail` |
| 创建接口 | `/create` | `POST /{前缀}/order/create` |
| 更新接口 | `/update` | `POST /{前缀}/order/update` |
| 状态修改 | `/update-status` | `POST /{前缀}/order/update-status` |
| 删除接口 | `/delete` | `POST /{前缀}/order/delete` |
| 批量删除 | `/batch-delete` | `POST /{前缀}/order/batch-delete` |
| 导入接口 | `/import` | `POST /{前缀}/order/import` |
| 导出接口 | `/export` | `GET /{前缀}/order/export` |
| 模板下载 | `/template/download` | `GET /{前缀}/order/template/download` |
| 基础数据接口 | `/base_data/{表名}` | `GET /{前缀}/base_data/order_status` |

### 3.3 下拉接口响应格式（强制）

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

> 详见 `docs/技术规范/导入导出规范.md`

导入导出接口的完整规范（模板设计、字段映射、关联回填、响应格式、流程图等）已移至独立文档。

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

---

## 附录

### A. 相关文档

| 文档 | 位置 |
|:-----|:-----|
| 导入导出规范 | `docs/技术规范/导入导出规范.md` |
| 导入导出样式规范 | `docs/技术规范/导入导出样式规范.md` |
| Flask后端规范 | `docs/技术规范/Flask后端规范.md` |
