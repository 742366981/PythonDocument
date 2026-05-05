# API 文档

> **基础路径**: `http://{host}:{port}/api`
> **版本**: 1.0.0

---

## 目录

1. [系统管理](#1-系统管理)
   - [认证管理](#11-认证管理)
   - [用户管理](#12-用户管理)
   - [角色管理](#13-角色管理)

2. [业务模块](#2-业务模块)
   - [模块A](#21-模块a)

---

## 通用规范

### 认证方式

系统采用 JWT Token 认证机制，大部分接口需要携带 Token 才能访问。

#### 获取 Token

**接口地址**：`POST /api/auth/login`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |

**请求示例**：
```json
{
  "username": "admin",
  "password": "password"
}
```

**响应示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "token": "xxx"
  }
}
```

#### 使用 Token

在请求头中添加 Authorization 字段，格式为：

`Authorization: Bearer {token}`

### 响应格式

**成功响应：**
```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

**分页响应：**
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "records": [],
    "page_no": 1,
    "page_size": 10,
    "total_page": 1,
    "total_count": 0
  }
}
```

**错误响应：**
```json
{
  "code": 400,
  "msg": "参数错误"
}
```

### 错误码

| code | 说明 |
|:----:|:-----|
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或token过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 1. 系统管理

### 1.1 认证管理

#### 用户登录

**接口地址**：`POST /api/auth/login`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |

**响应参数**：
| 参数名 | 类型 | 说明 |
|:-------|:-----|:-----|
| token | string | JWT Token |

**请求示例**：
```json
{
  "username": "admin",
  "password": "password"
}
```

**响应示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "token": "xxx"
  }
}
```

#### 用户退出

**接口地址**：`POST /api/auth/logout`

**请求头**：
| 参数名 | 说明 |
|:-------|:-----|
| Authorization | Bearer {token} |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success"
}
```

### 1.2 用户管理

#### 用户列表

**接口地址**：`GET /api/user/list`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| page_no | int | 否 | 页码，默认1 |
| page_size | int | 否 | 每页数量，默认10 |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "records": [],
    "page_no": 1,
    "page_size": 10,
    "total_page": 1,
    "total_count": 0
  }
}
```

#### 用户详情

**接口地址**：`GET /api/user/detail`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| id | int | 是 | 用户ID |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

#### 创建用户

**接口地址**：`POST /api/user/create`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |
| role_id | int | 是 | 角色ID |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success"
}
```

#### 更新用户

**接口地址**：`POST /api/user/update`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| id | int | 是 | 用户ID |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success"
}
```

#### 删除用户

**接口地址**：`POST /api/user/delete`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| id | int | 是 | 用户ID |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success"
}
```

### 1.3 角色管理

#### 角色列表

**接口地址**：`GET /api/role/list`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| page_no | int | 否 | 页码，默认1 |
| page_size | int | 否 | 每页数量，默认10 |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "records": [],
    "page_no": 1,
    "page_size": 10,
    "total_page": 1,
    "total_count": 0
  }
}
```

#### 角色详情

**接口地址**：`GET /api/role/detail`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| id | int | 是 | 角色ID |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

#### 创建角色

**接口地址**：`POST /api/role/create`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| role_name | string | 是 | 角色名称 |
| role_code | string | 是 | 角色代码 |
| permissions | array | 否 | 权限列表 |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success"
}
```

#### 更新角色

**接口地址**：`POST /api/role/update`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| id | int | 是 | 角色ID |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success"
}
```

#### 删除角色

**接口地址**：`POST /api/role/delete`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| id | int | 是 | 角色ID |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success"
}
```

---

## 2. 业务模块

（根据实际业务需求补充）

### 2.1 模块A

#### 接口列表

| 接口名称 | Method | Path | 说明 |
|:---------|:-------|:-----|:-----|
| 列表 | GET | /module-a/list | 获取列表 |
| 详情 | GET | /module-a/detail | 获取详情 |
| 创建 | POST | /module-a/create | 创建 |
| 更新 | POST | /module-a/update | 更新 |
| 删除 | POST | /module-a/delete | 删除 |

#### 列表接口

**接口地址**：`GET /api/module-a/list`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|:-------|:-----|:-----|:-----|
| page_no | int | 否 | 页码，默认1 |
| page_size | int | 否 | 每页数量，默认10 |

**响应示例**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "records": [],
    "page_no": 1,
    "page_size": 10,
    "total_page": 1,
    "total_count": 0
  }
}
```
