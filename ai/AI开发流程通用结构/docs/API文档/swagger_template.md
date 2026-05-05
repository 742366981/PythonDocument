# Flasgger 文档模板

复制下面的模板到你的视图函数前，根据实际接口修改参数。

---

## 统一响应说明

**所有接口统一返回 HTTP 200 状态码**，成功或失败通过响应体中的 `code` 字段判断：

| code | 说明 |
|:----:|:-----|
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或token过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

**响应格式**：
```json
{
  "code": 0,
  "msg": "success",
  "data": {}
}
```

---

## 认证说明

- 除登录接口外，其他接口均需认证
- 认证格式：在 Authorization header 中填入 `Bearer {token}`
- token 通过登录接口获取

---

## GET 列表接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '查询列表',
    'description': '分页查询列表，支持筛选条件。',
    'security': [{'Bearer': []}],
    'parameters': [
        {'name': 'page_no', 'in': 'query', 'type': 'integer', 'default': 1, 'description': '页码，从1开始', 'example': 1},
        {'name': 'page_size', 'in': 'query', 'type': 'integer', 'default': 10, 'description': '每页显示数量', 'example': 10},
        {'name': 'keyword', 'in': 'query', 'type': 'string', 'description': '关键词（模糊查询）', 'example': ''},
        {'name': 'status', 'in': 'query', 'type': 'integer', 'description': '状态（0=禁用，1=启用）', 'example': 1}
    ],
    'responses': {
        200: {
            'description': '查询成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'properties': {
                            'records': {
                                'type': 'array',
                                'items': {
                                    'type': 'object',
                                    'properties': {
                                        'id': {'type': 'integer', 'description': '记录ID', 'example': 1},
                                        'name': {'type': 'string', 'description': '名称', 'example': '示例'},
                                        'status': {'type': 'integer', 'description': '状态', 'example': 1}
                                    }
                                }
                            },
                            'page_no': {'type': 'integer', 'description': '当前页码', 'example': 1},
                            'page_size': {'type': 'integer', 'description': '每页数量', 'example': 10},
                            'total_page': {'type': 'integer', 'description': '总页数', 'example': 1},
                            'total_count': {'type': 'integer', 'description': '总记录数', 'example': 1}
                        },
                        'example': {
                            'records': [{'id': 1, 'name': '示例', 'status': 1}],
                            'page_no': 1,
                            'page_size': 10,
                            'total_page': 1,
                            'total_count': 1
                        }
                    }
                }
            }
        }
    }
})
```

---

## GET 详情接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '查询详情',
    'description': '根据ID查询详细信息。',
    'security': [{'Bearer': []}],
    'parameters': [
        {'name': 'id', 'in': 'query', 'type': 'integer', 'required': True, 'description': '记录ID', 'example': 1}
    ],
    'responses': {
        200: {
            'description': '查询成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'properties': {
                            'id': {'type': 'integer', 'description': '记录ID', 'example': 1},
                            'name': {'type': 'string', 'description': '名称', 'example': '示例'},
                            'status': {'type': 'integer', 'description': '状态', 'example': 1}
                        },
                        'example': {'id': 1, 'name': '示例', 'status': 1}
                    }
                }
            }
        }
    }
})
```

---

## POST 创建接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '创建',
    'description': '创建新记录。',
    'security': [{'Bearer': []}],
    'parameters': [
        {
            'name': 'body',
            'in': 'body',
            'required': True,
            'schema': {
                'type': 'object',
                'properties': {
                    'name': {'type': 'string', 'description': '名称', 'example': '示例名称'},
                    'code': {'type': 'string', 'description': '编码', 'example': 'CODE001'},
                    'status': {'type': 'integer', 'description': '状态（0=禁用，1=启用）', 'example': 1}
                },
                'required': ['name', 'code'],
                'example': {'name': '示例名称', 'code': 'CODE001', 'status': 1}
            }
        }
    ],
    'responses': {
        200: {
            'description': '创建成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'properties': {
                            'id': {'type': 'integer', 'description': '新创建的记录ID', 'example': 2}
                        },
                        'example': {'id': 2}
                    }
                }
            }
        }
    }
})
```

---

## POST 更新接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '更新',
    'description': '更新记录信息。',
    'security': [{'Bearer': []}],
    'parameters': [
        {
            'name': 'body',
            'in': 'body',
            'required': True,
            'schema': {
                'type': 'object',
                'properties': {
                    'id': {'type': 'integer', 'description': '记录ID', 'example': 1},
                    'name': {'type': 'string', 'description': '名称', 'example': '新名称'},
                    'status': {'type': 'integer', 'description': '状态（0=禁用，1=启用）', 'example': 1}
                },
                'required': ['id'],
                'example': {'id': 1, 'name': '新名称'}
            }
        }
    ],
    'responses': {
        200: {
            'description': '更新成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'example': {}
                    }
                }
            }
        }
    }
})
```

---

## POST 删除接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '删除',
    'description': '删除记录。',
    'security': [{'Bearer': []}],
    'parameters': [
        {
            'name': 'body',
            'in': 'body',
            'required': True,
            'schema': {
                'type': 'object',
                'properties': {
                    'id': {'type': 'integer', 'description': '记录ID', 'example': 1}
                },
                'required': ['id'],
                'example': {'id': 1}
            }
        }
    ],
    'responses': {
        200: {
            'description': '删除成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'example': {}
                    }
                }
            }
        }
    }
})
```

---

## POST 批量删除接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '批量删除',
    'description': '批量删除记录。',
    'security': [{'Bearer': []}],
    'parameters': [
        {
            'name': 'body',
            'in': 'body',
            'required': True,
            'schema': {
                'type': 'object',
                'properties': {
                    'ids': {'type': 'array', 'items': {'type': 'integer'}, 'description': '记录ID列表', 'example': [1, 2, 3]}
                },
                'required': ['ids'],
                'example': {'ids': [1, 2, 3]}
            }
        }
    ],
    'responses': {
        200: {
            'description': '删除成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'example': {}
                    }
                }
            }
        }
    }
})
```

---

## POST 状态修改接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '修改状态',
    'description': '修改记录状态。',
    'security': [{'Bearer': []}],
    'parameters': [
        {
            'name': 'body',
            'in': 'body',
            'required': True,
            'schema': {
                'type': 'object',
                'properties': {
                    'id': {'type': 'integer', 'description': '记录ID', 'example': 1},
                    'status': {'type': 'integer', 'description': '状态（0=禁用，1=启用）', 'example': 1}
                },
                'required': ['id', 'status'],
                'example': {'id': 1, 'status': 0}
            }
        }
    ],
    'responses': {
        200: {
            'description': '修改成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'example': {}
                    }
                }
            }
        }
    }
})
```

---

## GET 数据字典接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '获取数据字典',
    'description': '获取启用的数据字典列表，用于下拉选项。',
    'security': [{'Bearer': []}],
    'responses': {
        200: {
            'description': '查询成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'array',
                        'items': {
                            'type': 'object',
                            'properties': {
                                'value': {'type': 'integer', 'description': '值', 'example': 1},
                                'label': {'type': 'string', 'description': '标签', 'example': '启用'}
                            }
                        },
                        'example': [{'value': 1, 'label': '启用'}, {'value': 0, 'label': '禁用'}]
                    }
                }
            }
        }
    }
})
```

---

## GET 导出列表接口模板（文件下载）

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '导出列表',
    'description': '导出数据为 Excel 文件。',
    'security': [{'Bearer': []}],
    'parameters': [
        {'name': 'keyword', 'in': 'query', 'type': 'string', 'description': '关键词', 'example': ''},
        {'name': 'status', 'in': 'query', 'type': 'integer', 'description': '状态', 'example': 1}
    ],
    'responses': {
        200: {
            'description': 'Excel 文件流',
            'schema': {
                'type': 'file'
            }
        }
    }
})
```

---

## GET 模板下载接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '下载导入模板',
    'description': '下载 Excel 导入模板。',
    'security': [{'Bearer': []}],
    'responses': {
        200: {
            'description': 'Excel 文件流',
            'schema': {
                'type': 'file'
            }
        }
    }
})
```

---

## POST 导入接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '导入数据',
    'description': '通过 Excel 文件导入数据，支持批量新增和更新。',
    'security': [{'Bearer': []}],
    'parameters': [
        {
            'name': 'file',
            'in': 'formData',
            'type': 'file',
            'required': True,
            'description': 'Excel 文件'
        }
    ],
    'responses': {
        200: {
            'description': '导入结果',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'properties': {
                            'total': {'type': 'integer', 'description': '总行数', 'example': 100},
                            'success': {'type': 'integer', 'description': '成功行数', 'example': 95},
                            'fail': {'type': 'integer', 'description': '失败行数', 'example': 5}
                        },
                        'example': {'total': 100, 'success': 95, 'fail': 5}
                    }
                }
            }
        }
    }
})
```

---

## POST 文件上传接口模板

```python
@swag_from({
    'tags': ['大模块/子模块'],
    'summary': '上传文件',
    'description': '上传文件到服务器。',
    'security': [{'Bearer': []}],
    'parameters': [
        {
            'name': 'file',
            'in': 'formData',
            'type': 'file',
            'required': True,
            'description': '文件'
        }
    ],
    'responses': {
        200: {
            'description': '上传成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'description': '状态码', 'example': 0},
                    'msg': {'type': 'string', 'description': '响应消息', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'properties': {
                            'url': {'type': 'string', 'description': '文件访问URL', 'example': '/uploads/xxx.png'}
                        },
                        'example': {'url': '/uploads/xxx.png'}
                    }
                }
            }
        }
    }
})
```

---

## 标签对照表

| 大模块 | 子模块 | 标签 |
|:-------|:-------|:-----|
| 系统管理 | 认证管理 | 系统管理/认证管理 |
| 系统管理 | 用户管理 | 系统管理/用户管理 |
| 系统管理 | 角色管理 | 系统管理/角色管理 |
| 系统管理 | 权限管理 | 系统管理/权限管理 |
| 基础数据 | 字典管理 | 基础数据/字典管理 |
| 基础数据 | 国家管理 | 基础数据/国家管理 |
| 基础数据 | 平台管理 | 基础数据/平台管理 |
| 基础数据 | 部门管理 | 基础数据/部门管理 |
| 业务模块 | XXX管理 | 业务模块/XXX管理 |
