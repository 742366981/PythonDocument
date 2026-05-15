# API 文档通用模板

**版本**: 1.0.0
**更新日期**: 2026-05-15

---

## 目录

- [通用规范](#通用规范)
- [接口文档模板](#接口文档模板)
  - [GET 列表接口](#get-列表接口)
  - [GET 详情接口](#get-详情接口)
  - [POST 创建接口](#post-创建接口)
  - [POST 更新接口](#post-更新接口)
  - [POST 状态修改接口](#post-状态修改接口)
  - [POST 删除接口](#post-删除接口)
  - [POST 批量删除接口](#post-批量删除接口)
  - [POST 导入接口](#post-导入接口)
  - [GET 导出接口](#get-导出接口)
  - [GET 模板下载接口](#get-模板下载接口)
  - [GET 下拉接口](#get-下拉接口)
  - [POST 登录接口](#post-登录接口)
  - [POST 登出接口](#post-登出接口)

---

## 通用规范

### 基础路径

```
http://{host}:{port}/{项目前缀}
```

### 认证方式

系统采用 JWT Token 认证机制。大部分接口需要携带 Token 才能访问。

#### 1. 获取 Token

**接口地址**: `POST /{项目前缀}/auth/login`

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|------|
| username | string | 是 | 用户名（手机号也可以） |
| password | string | 是 | 密码（MD5格式） |

**请求示例**:
```json
{"username": "admin", "password": "e10adc3949ba59abbe56e057f20f883e"}
```

**响应示例**:
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "token": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    "user_id": 1,
    "username": "admin"
  }
}
```

#### 2. 使用 Token

在请求头中添加 Authorization 字段，格式为：

```
Authorization: Bearer {token}
```

---

### 统一响应说明

**所有接口统一返回 HTTP 200 状态码**，成功或失败通过响应体中的 `code` 字段判断：

| code | 说明 |
|:----:|:-----|
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或token过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

**响应格式**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

> 注意：`api_success` 不传 data 时不返回 data 字段

---

### 接口字段规范

#### 列表接口返回规范

| 场景 | 返回格式 | 示例 |
|:-----|:---------|:-----|
| 查询本表数据 | 返回本表字段（包含主键 id） | `{"id": 1, "name": "管理员"}` |
| 需展示关联信息 | 本表字段 + 关联表的 id+name | `{"id": 1, "role_id": 1, "role_name": "管理员"}` |

#### 详情接口返回规范

详情接口请求只需 `id`，返回本表字段 + 业务需要的关联字段：

| 场景 | 返回格式 | 示例 |
|:-----|:---------|:-----|
| 本表字段 | 本表所有字段 | `{"id": 1, "username": "admin", "balance": 100}` |
| 需展示关联信息 | 本表字段 + 关联表的 id+name | `{"id": 1, "role_id": 1, "role_name": "管理员"}` |

#### 创建/更新接口参数规范

| 接口类型 | 接收参数 | 示例 |
|:---------|:---------|:-----|
| 创建本表 | 本表字段（除自增 id） | `{"name": "管理员", "status": 1}` |
| 更新本表 | 本表 id + 要更新的字段 | `{"id": 1, "name": "新名称"}` |
| 创建/更新关联表 | 关联 id 字段 | `{"user_id": 1, "role_id": 2}` |

#### 删除接口参数规范

| 接口类型 | 接收参数 | 示例 |
|:---------|:---------|:-----|
| 删除本表（单个） | 本表 id | `{"id": 1}` |
| 删除本表（批量） | 本表 id 数组 | `{"ids": [1, 2, 3]}` |

---

### 导入导出字段规范

> 详见 `docs/技术规范/导入导出规范.md` 第1章

---

## 接口文档模板

本文档提供每种类型接口的通用模板，开发者可参考此模板编写具体接口文档。

---

### GET 列表接口

**接口地址**: `GET /{前缀}/{模块}/list`

**需认证**: 是

**说明**: 分页查询列表，支持按关键词、状态等条件筛选。

**请求参数**:

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|:----:|------|
| keyword | query | string | 否 | 关键词（模糊搜索） |
| status | query | integer | 否 | 状态（0禁用/1启用） |
| page_no | query | integer | 否 | 页码，从1开始（示例: 1） |
| page_size | query | integer | 否 | 每页显示数量（示例: 10） |

**响应说明**: 查询成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| data | object | 数据对象 |
| msg | string | 消息 |

**data 响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| records | array | 记录列表 |
| page_no | integer | 当前页码 |
| page_size | integer | 每页数量 |
| total_page | integer | 总页数 |
| total_count | integer | 总记录数 |

**records 字段说明**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| id | integer | 记录ID |
| name | string | 名称 |
| code | string | 编码 |
| role_id | integer | 关联角色ID（按业务需要） |
| role_name | string | 关联角色名称（按业务需要） |
| status | integer | 状态（0禁用/1启用） |
| create_time | string | 创建时间 |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "page_no": 1,
    "page_size": 10,
    "records": [
      {
        "id": 1,
        "name": "管理员",
        "code": "ADMIN",
        "role_id": 1,
        "role_name": "超级管理员",
        "status": 1,
        "create_time": "2026-05-15 10:00:00"
      }
    ],
    "total_count": 50,
    "total_page": 5
  },
  "msg": "success"
}
```

---

### GET 详情接口

**接口地址**: `GET /{前缀}/{模块}/detail`

**需认证**: 是

**说明**: 根据ID查询详细信息。

**请求参数**:

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|:----:|------|
| id | query | integer | 是 | 记录ID（示例: 1） |

**响应说明**: 查询成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| data | object | 数据对象 |
| msg | string | 消息 |

**data 响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| id | integer | 记录ID |
| name | string | 名称 |
| code | string | 编码 |
| role_id | integer | 关联角色ID（按业务需要） |
| role_name | string | 关联角色名称（按业务需要） |
| status | integer | 状态（0禁用/1启用） |
| create_time | string | 创建时间 |
| update_time | string | 更新时间 |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "id": 1,
    "name": "管理员",
    "code": "ADMIN",
    "role_id": 1,
    "role_name": "超级管理员",
    "status": 1,
    "create_time": "2026-05-15 10:00:00",
    "update_time": "2026-05-15 10:00:00"
  },
  "msg": "success"
}
```

---

### POST 创建接口

**接口地址**: `POST /{前缀}/{模块}/create`

**需认证**: 是

**说明**: 创建新记录，字段需唯一性校验。

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|------|
| name | string | 是 | 名称（示例: 管理员） |
| code | string | 是 | 编码（示例: ADMIN） |
| role_id | integer | 否 | 关联角色ID（示例: 1） |
| status | integer | 否 | 状态（0禁用/1启用）（示例: 1） |
| description | string | 否 | 描述（示例: 这是一个描述） |

**请求示例**:
```json
{
  "name": "管理员",
  "code": "ADMIN",
  "role_id": 1,
  "status": 1,
  "description": "这是一个描述"
}
```

**响应说明**: 创建成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| data | object | 数据对象 |
| msg | string | 消息 |

**data 响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| id | integer | 新创建的记录ID |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "id": 2
  },
  "msg": "创建成功"
}
```

---

### POST 更新接口

**接口地址**: `POST /{前缀}/{模块}/update`

**需认证**: 是

**说明**: 更新记录信息。

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|------|
| id | integer | 是 | 记录ID（示例: 1） |
| name | string | 否 | 名称（示例: 新管理员） |
| code | string | 否 | 编码（示例: ADMIN_NEW） |
| role_id | integer | 否 | 关联角色ID（示例: 1） |
| status | integer | 否 | 状态（0禁用/1启用）（示例: 1） |
| description | string | 否 | 描述（示例: 更新后的描述） |

**请求示例**:
```json
{
  "id": 1,
  "name": "新管理员",
  "code": "ADMIN_NEW",
  "role_id": 1,
  "status": 1,
  "description": "更新后的描述"
}
```

**响应说明**: 更新成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| msg | string | 消息 |

**响应示例**:
```json
{
  "code": 0,
  "msg": "更新成功"
}
```

---

### POST 状态修改接口

**接口地址**: `POST /{前缀}/{模块}/update-status`

**需认证**: 是

**说明**: 修改记录状态。

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|------|
| id | integer | 是 | 记录ID（示例: 1） |
| status | integer | 是 | 状态（0禁用/1启用）（示例: 1） |

**请求示例**:
```json
{
  "id": 1,
  "status": 0
}
```

**响应说明**: 修改成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| msg | string | 消息 |

**响应示例**:
```json
{
  "code": 0,
  "msg": "修改成功"
}
```

---

### POST 删除接口

**接口地址**: `POST /{前缀}/{模块}/delete`

**需认证**: 是

**说明**: 删除记录（软删除），删除前检查关联数据。

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|------|
| id | integer | 是 | 记录ID（示例: 1） |

**请求示例**:
```json
{
  "id": 1
}
```

**响应说明**: 删除成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| msg | string | 消息 |

**响应示例**:
```json
{
  "code": 0,
  "msg": "删除成功"
}
```

---

### POST 批量删除接口

**接口地址**: `POST /{前缀}/{模块}/batch-delete`

**需认证**: 是

**说明**: 批量删除记录。

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|------|
| ids | array | 是 | 记录ID列表（示例: [1, 2, 3]） |

**请求示例**:
```json
{
  "ids": [1, 2, 3]
}
```

**响应说明**: 删除成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| msg | string | 消息 |

**响应示例**:
```json
{
  "code": 0,
  "msg": "删除成功"
}
```

---

### POST 导入接口

**接口地址**: `POST /{前缀}/{模块}/import`

**需认证**: 是

**说明**: 通过 Excel 文件导入数据，支持批量新增。

**请求参数**:

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|:----:|------|
| file | formData | file | 是 | Excel文件(.xlsx/.csv) |

**响应说明**: 导入结果

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| data | object | 数据对象 |
| msg | string | 消息 |

**data 响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| total | integer | 总处理数 |
| success | integer | 成功数 |
| fail | integer | 失败数 |
| errors | array | 错误详情列表（最多10条） |

**errors 字段说明**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| row | integer | 失败行号 |
| message | string | 错误原因 |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "total": 100,
    "success": 98,
    "fail": 2,
    "errors": [
      {"row": 3, "message": "第4行角色编码不存在"},
      {"row": 5, "message": "第6行名称不能为空"}
    ]
  },
  "msg": "导入完成"
}
```

---

### GET 导出接口

**接口地址**: `GET /{前缀}/{模块}/export`

**需认证**: 是

**说明**: 导出数据为 Excel 文件。

**请求参数**:

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|:----:|------|
| keyword | query | string | 否 | 关键词（模糊搜索） |
| status | query | integer | 否 | 状态（0禁用/1启用） |

**响应说明**: Excel 文件流

**响应示例**:
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename={模块}_export_20260515.xlsx
```

---

### GET 模板下载接口

**接口地址**: `GET /{前缀}/{模块}/template/download`

**需认证**: 是

**说明**: 下载 Excel 导入模板。

**请求参数**: 无

**响应说明**: Excel 文件流

**响应示例**:
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename={模块}_template.xlsx
```

---

### GET 下拉接口

**接口地址**: `GET /{前缀}/{模块}/dict`

**需认证**: 是

**说明**: 获取启用的数据字典列表，用于下拉选项。

**请求参数**:

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|:----:|------|
| type | query | string | 是 | 字典类型（示例: status） |

**响应说明**: 查询成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| data | array | 数据数组 |
| msg | string | 消息 |

**data 响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| dictCode | integer | 字典编码（对应数据库id） |
| dictLabel | string | 显示文本（对应数据库name） |
| dictValue | string | 存储值（对应数据库code） |
| dictType | string | 字典类型 |
| dictSort | integer | 排序号 |
| cssClass | string | CSS样式类 |
| listClass | string | 列表样式类 |
| defaultFlag | string | 默认标志 |
| status | string | 状态 |
| remark | string | 备注 |

**响应示例**:
```json
{
  "code": 0,
  "data": [
    {
      "dictCode": 1,
      "dictLabel": "启用",
      "dictValue": "1",
      "dictType": "status",
      "dictSort": 1,
      "cssClass": null,
      "listClass": null,
      "defaultFlag": "1",
      "status": "0",
      "remark": null
    },
    {
      "dictCode": 2,
      "dictLabel": "禁用",
      "dictValue": "0",
      "dictType": "status",
      "dictSort": 2,
      "cssClass": null,
      "listClass": null,
      "defaultFlag": "0",
      "status": "0",
      "remark": null
    }
  ],
  "msg": "success"
}
```

---

### POST 登录接口

**接口地址**: `POST /{前缀}/auth/login`

**需认证**: 否

**说明**: 使用用户名或手机号和密码登录，返回Token。

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|:------|:----:|:----:|------|
| username | string | 是 | 用户名（手机号也可以）（示例: admin） |
| password | string | 是 | 密码(MD5)（示例: e10adc3949ba59abbe56e057f20f883e） |

**请求示例**:
```json
{
  "username": "admin",
  "password": "e10adc3949ba59abbe56e057f20f883e"
}
```

**响应说明**: 登录成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| data | object | 数据对象 |
| msg | string | 消息 |

**data 响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| token | string | 访问令牌 |
| user_id | integer | 用户ID |
| username | string | 用户名 |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "token": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    "user_id": 1,
    "username": "admin"
  },
  "msg": "success"
}
```

---

### POST 登出接口

**接口地址**: `POST /{前缀}/auth/logout`

**需认证**: 是

**说明**: 用户退出登录，使当前Token失效。

**请求参数**: 无

**响应说明**: 退出成功

**响应参数**:

| 字段 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | integer | 状态码 |
| msg | string | 消息 |

**响应示例**:
```json
{
  "code": 0,
  "msg": "退出成功"
}
```

---

## 标签对照表

> **Swagger 标签规范引用**：详见 `docs/API文档/swagger_template.md` 末尾的标签对照表

---

## 编写说明

1. **基础路径**：根据实际部署环境修改 `{host}`、`{port}` 和 `{项目前缀}`
2. **模块名称**：将 `{模块}` 替换为实际的模块名（如 user、role、order 等）
3. **字段定义**：根据实际业务需求增删请求参数和响应字段
4. **关联字段**：列表/详情接口按业务需要返回关联字段的 id+name
5. **示例数据**：使用有意义的示例数据，便于理解接口用途
6. **状态码**：通用错误码 + 业务错误码结合使用
