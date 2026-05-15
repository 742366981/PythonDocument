# Flask后端项目规范

本文档定义 Flask 后端项目的特定规范，Flask 特有的内容（如应用工厂、蓝图、装饰器等）详见本章。

> ⚠️ **通用规范引用**：数据库、缓存、定时任务、部署等通用内容详见各自独立规范文档：
> - `数据库规范.md`
> - `缓存规范.md`
> - `定时任务规范.md`
> - `部署规范.md`

---

## 1. 目录结构（强制）

### 1.1 整体目录结构

```
project/
├── apps/                              # 应用模块（蓝图）
│   ├── __init__.py                   # 应用工厂、蓝图注册
│   │
│   ├── system/                        # 系统管理模块
│   │   ├── __init__.py               # 蓝图注册
│   │   ├── auth/                      # 认证子模块（登录、退出、Token刷新）
│   │   │   ├── __init__.py
│   │   │   └── views.py
│   │   ├── user/                      # 用户子模块（用户CRUD、状态管理）
│   │   │   ├── __init__.py
│   │   │   └── views.py
│   │   ├── role/                      # 角色子模块（角色CRUD、角色分配）
│   │   │   ├── __init__.py
│   │   │   └── views.py
│   │   ├── permission/                # 权限子模块（权限项CRUD、权限分配）
│   │   │   ├── __init__.py
│   │   │   └── views.py
│   │   ├── menu/                      # 菜单子模块（菜单CRUD、菜单树）
│   │   │   ├── __init__.py
│   │   │   └── views.py
│   │   └── dict/                      # 字典子模块（字典类型、字典项）
│   │       ├── __init__.py
│   │       └── views.py
│   │
│   ├── operation/                      # 运营管理模块
│   │   ├── __init__.py               # 蓝图注册
│   │   └── log/                       # 日志子模块（操作日志、登录日志）
│   │       ├── __init__.py
│   │       └── views.py
│   │
│   ├── file/                          # 文件管理模块
│   │   ├── __init__.py               # 蓝图注册
│   │   └── upload/                    # 上传子模块（通用文件上传）
│   │       ├── __init__.py
│   │       └── views.py
│   │
│   └── business/                       # 业务模块（按需创建）
│       ├── __init__.py               # 蓝图注册
│       ├── order/                     # 订单模块
│       │   ├── __init__.py
│       │   └── views.py
│       └── product/                   # 商品模块
│           ├── __init__.py
│           └── views.py
│
├── common/                             # 公共模块
│   ├── __init__.py
│   ├── constants.py                   # 常量定义（BASE_DIR/RedisKey/ENV_TYPE）
│   ├── codes.py                       # 错误码定义
│   └── settings.py                    # 配置加载器
│
├── config/                             # 配置文件
│   ├── config_dev.ini                 # 开发环境
│   ├── config_test.ini                # 测试环境
│   └── config_prod.ini                # 生产环境
│
├── db/                                # 数据库相关
│   ├── mysql/
│   │   ├── __init__.py
│   │   ├── helpers.py                # SQLAlchemy实例、BaseModel
│   │   └── models/                   # 数据模型
│   └── redis/
│       ├── __init__.py
│       └── helpers.py                 # Redis客户端
│
├── utils/                              # 工具函数
│   ├── __init__.py
│   ├── responses.py                   # 统一响应
│   ├── decorators.py                  # 装饰器（login_required, permission_required）
│   ├── exceptions.py                  # 自定义异常
│   ├── validators.py                  # 参数验证
│   ├── helpers.py                     # 辅助函数
│   ├── middleware.py                  # 请求ID中间件
│   ├── request_log.py                 # 请求日志中间件
│   ├── loggings.py                    # 日志封装
│   └── scheduler.py                   # 定时任务调度器
│
├── docs/                               # 文档
│   └── swagger_template.md            # Swagger文档模板
│
├── tools/                             # 工具脚本
│   └── export_docs.py                 # 导出API文档脚本
│
├── db_init/                            # 数据库初始化
│   ├── init_all.py                    # 初始化所有表和数据
│   └── init_*.py                      # 其他初始化脚本
│
├── jobs/                             # 定时任务
│   ├── __init__.py
│   └── example.py                     # 示例任务
│
├── app.py                              # 应用入口
├── requirements.txt                    # 依赖
├── gunicorn_loader.py                  # Gunicorn启动器
└── Dockerfile                          # Docker镜像
```

### 1.2 模块划分规范

| 模块层级 | 模块名 | 说明 | 是否必须 |
|:---------|:-------|:-----|:--------|
| 一级 | `system/` | 系统管理：用户、角色、权限、菜单、字典、认证 | 必须 |
| 一级 | `operation/` | 运营管理：日志、监控 | 必须 |
| 一级 | `file/` | 文件管理：上传、附件 | 必须 |
| 一级 | `business/` | 业务模块：订单、商品等 | 按需扩展 |

### 1.3 子模块划分规范

**system/ 系统管理模块的子模块**：

| 子模块 | 职责 | 接口示例 |
|:-------|:-----|:---------|
| `auth/` | 认证管理 | 登录、退出、Token刷新、验证码 |
| `user/` | 用户管理 | 用户CRUD、状态管理、个人信息 |
| `role/` | 角色管理 | 角色CRUD、角色分配 |
| `permission/` | 权限管理 | 权限项CRUD、权限分配 |
| `menu/` | 菜单管理 | 菜单CRUD、菜单树 |
| `dict/` | 字典管理 | 字典类型CRUD、字典项CRUD |

**operation/ 运营管理模块的子模块**：

| 子模块 | 职责 | 接口示例 |
|:-------|:-----|:---------|
| `log/` | 日志管理 | 操作日志、登录日志、异常日志 |
| `monitor/` | 监控管理 | 在线用户、访问统计 |

**file/ 文件管理模块的子模块**：

| 子模块 | 职责 | 接口示例 |
|:-------|:-----|:---------|
| `upload/` | 文件上传 | 通用文件上传、图片上传 |
| `attachment/` | 附件管理 | 附件列表、附件删除 |

### 1.4 蓝图注册规范

```python
# apps/__init__.py

def register_blueprints(app):
    url_prefix = '/api'

    # system 模块
    from apps.system.auth.views import auth_bp
    from apps.system.user.views import user_bp
    from apps.system.role.views import role_bp
    from apps.system.permission.views import permission_bp
    from apps.system.menu.views import menu_bp
    from apps.system.dict.views import dict_bp

    app.register_blueprint(auth_bp, url_prefix=f'{url_prefix}/auth')
    app.register_blueprint(user_bp, url_prefix=f'{url_prefix}/user')
    app.register_blueprint(role_bp, url_prefix=f'{url_prefix}/role')
    app.register_blueprint(permission_bp, url_prefix=f'{url_prefix}/permission')
    app.register_blueprint(menu_bp, url_prefix=f'{url_prefix}/menu')
    app.register_blueprint(dict_bp, url_prefix=f'{url_prefix}/dict')

    # operation 模块
    from apps.operation.log.views import log_bp
    app.register_blueprint(log_bp, url_prefix=f'{url_prefix}/log')

    # file 模块
    from apps.file.upload.views import upload_bp
    app.register_blueprint(upload_bp, url_prefix=f'{url_prefix}/upload')

    # business 模块（按需注册）
    # from apps.business.order.views import order_bp
    # app.register_blueprint(order_bp, url_prefix=f'{url_prefix}/order')
```

### 1.5 视图文件拆分规范（强制）

#### 1.5.1 拆分条件

满足以下任一条件时，必须拆分文件：

| 条件 | 阈值 | 说明 |
|:-----|:-----|:-----|
| 单文件接口数 | > 10 个 | 必须拆分 |
| 单文件行数 | > 500 行 | 含注释和空行 |

#### 1.5.2 拆分原则

**按业务子模块拆分，不按接口类型拆分**：

```
# ❌ 错误：按接口类型拆分
apps/user/list_view.py      # 所有 list 接口
apps/user/create_view.py   # 所有 create 接口

# ✅ 正确：按业务子模块拆分
apps/user/user_view.py     # 用户基础 CRUD
apps/user/address_view.py  # 用户地址相关
apps/user/profile_view.py # 用户资料相关
```

#### 1.5.3 拆分后命名规范

| 场景 | 命名规则 | 示例 |
|:-----|:---------|:-----|
| 子模块接口少 | `{module}_view.py` | `user_view.py` |
| 子模块接口多 | `{module}_{sub}_view.py` | `user_address_view.py` |
| 继续拆分 | `{module}_{sub}_{func}_view.py` | `user_address_list_view.py` |

#### 1.5.4 拆分检查清单

| 检查项 | 要求 |
|:-------|:-----|
| 单文件接口数 | ≤ 10 |
| 单文件行数 | ≤ 500 |
| 拆分方式 | 按业务拆分，不按接口类型 |
| 命名规范 | 符合 1.5.3 命名规则 |

---

## 2. 路径管理规范（强制）

### 2.1 禁止使用 sys.path（强制）

**严格禁止**在代码中使用 `sys.path.insert`、`sys.path.append` 等方式动态修改路径。

```python
# ❌ 禁止这样做
import sys
sys.path.insert(0, '/path/to/module')
```

### 2.2 禁止硬编码绝对路径（强制）

**严格禁止**在代码中写死绝对路径。

```python
# ❌ 禁止这样做
config_path = '/app/config/config_dev.ini'
upload_dir = '/data/uploads'

# ❌ 禁止这样做
file_path = 'D:\\project\\uploads\\file.xlsx'
```

### 2.3 统一使用 BASE_DIR（强制）

所有路径必须基于 `common.constants.BASE_DIR` 使用 `os.path.join` 拼接。

```python
# common/constants.py
import os

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
LOGGING_BASE_DIR = BASE_DIR

# ✅ 正确做法
from common.constants import BASE_DIR
config_path = os.path.join(BASE_DIR, 'config', 'config_dev.ini')
```

---

## 3. Flask应用工厂（强制）

### 3.1 完整应用工厂（强制）

```python
# apps/__init__.py

from flask import Flask
from flask_compress import Compress
from flask_migrate import Migrate
from flask_cors import CORS
from common.settings import config

compress = Compress()
migrate = Migrate()


def create_app(protect_swagger=True):
    app = Flask(__name__)

    # 基础配置
    app.config['SECRET_KEY'] = config.get('secret_key')
    app.config['DEBUG'] = config.get('debug').lower() == 'true'
    app.json.ensure_ascii = False

    # 数据库配置
    from common.settings import admin_mysql_conf
    db_user = admin_mysql_conf.get('username')
    db_pass = admin_mysql_conf.get('password')
    db_host = admin_mysql_conf.get('host')
    db_port = admin_mysql_conf.get('port')
    db_name = admin_mysql_conf.get('db_name')
    db_charset = admin_mysql_conf.get('charset')

    if db_pass:
        app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}?charset={db_charset}'
    else:
        app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{db_user}@{db_host}:{db_port}/{db_name}?charset={db_charset}'

    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SQLALCHEMY_ECHO'] = app.config['DEBUG']

    # 初始化扩展
    from db.mysql.helpers import db
    db.init_app(app)
    migrate.init_app(app, db)
    compress.init_app(app)

    # CORS跨域配置
    cors_origins = config.get('cors', 'origins')
    cors_origins_list = '*' if cors_origins == '*' else [o.strip() for o in cors_origins.split(',')]
    supports_credentials = config.getboolean('cors', 'supports_credentials')
    CORS(app, resources={r'/*': {'origins': cors_origins_list, 'supports_credentials': supports_credentials}})

    # 中间件
    from utils.middleware import init_request_id
    init_request_id(app)

    from utils.request_log import init_request_log
    init_request_log(app)

    # 注册蓝图
    register_blueprints(app)

    # 注册异常处理
    register_error_handlers(app)

    # 注册Swagger文档
    register_swagger(app, protect=protect_swagger)

    return app
```

### 3.2 蓝图注册（强制）

```python
def register_blueprints(app):
    url_prefix = '/api'

    app.register_blueprint(auth_bp, url_prefix=f'{url_prefix}/auth')
    app.register_blueprint(user_bp, url_prefix=f'{url_prefix}/user')
    app.register_blueprint(role_bp, url_prefix=f'{url_prefix}/role')
    app.register_blueprint(permission_bp, url_prefix=f'{url_prefix}/permission')
    # ... 其他蓝图
```

---

## 4. 配置管理（强制）

### 4.1 配置加载器（强制）

> ⚠️ **强制要求：配置禁止使用默认值**
>
> 所有配置项**必须**从配置文件读取，**禁止**使用默认值 fallback。
>
> ❌ 错误示例：`app_conf.getint('port', 8000)`、`config.get('debug', fallback=False)`
>
> ✅ 正确示例：`app_conf.getint('port')`、`config.getboolean('debug')`
>
> 若配置文件缺失，程序应该**启动失败**而不是使用默认值。

```python
# common/settings.py

import configparser
import os
from common.constants import BASE_DIR, ENV_TYPE


def get_config_path():
    config_dir = f'{BASE_DIR}/config'
    return f'{config_dir}/config_{ENV_TYPE}.ini'


class Config:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._load_config()
        return cls._instance

    def _load_config(self):
        config_path = get_config_path()
        if not os.path.exists(config_path):
            raise Exception(f'配置文件<{config_path}>不存在')
        self._config = configparser.ConfigParser()
        self._config.read(config_path, encoding='utf-8')

    def get(self, section, key=None, fallback=None):
        if key is None:
            key = section
            section = 'app'
        return self._config.get(section, key, fallback=fallback)

    def getint(self, section, key=None, fallback=0):
        # ... 类似实现

    def getboolean(self, section, key=None, fallback=False):
        # ... 类似实现


config = Config()
admin_mysql_conf = config.items('admin_mysql')
admin_redis_conf = config.items('admin_redis')
app_conf = config
```

### 4.2 配置文件格式（强制）

> ⚠️ **配置文件与环境变量关联（强制）**
>
> 配置文件的加载由 **环境变量** 中的 `ENV_TYPE` 控制：
> - `ENV_TYPE='dev'` → 加载 `config_dev.ini`
> - `ENV_TYPE='test'` → 加载 `config_test.ini`
> - `ENV_TYPE='prod'` → 加载 `config_prod.ini`
>
> **禁止在代码中硬编码配置文件路径**，必须通过 `ENV_TYPE` 动态拼接。

> ⚠️ **环境配置差异原则**
>
> 所有环境的配置文件内容**基本一致**，唯一区别是 `[app]` 下的 `debug` 配置：
>
> | 环境 | debug值 | 说明 |
> |:-----|:--------|:-----|
> | dev | `true` | 开发环境开启调试 |
> | test | `false` | 测试环境关闭调试 |
> | prod | `false` | 生产环境关闭调试 |

```ini
# config_dev.ini / config_test.ini / config_prod.ini
# 由 ENV_TYPE 控制加载哪个文件
# 除debug外，所有环境配置内容一致

[admin_mysql]
host = 127.0.0.1
port = 3309
username = root
password = password
db_name = myapp_db
charset = utf8mb4

[admin_redis]
host = 127.0.0.1
port = 6379
password =
db = 2

[app]
host = 0.0.0.0
secret_key = your-secret-key
# debug = true   # dev环境
# debug = false  # test/prod环境
port = 8000

[request_log]
# 记录完整响应体的接口路径（逗号分隔）
full_response_paths = /auth/login,/auth/logout

[cors]
# 允许跨域的域名（逗号分隔，* 表示允许所有）
origins = *
supports_credentials = true
```

> ⚠️ **配置加载器实现要求**
>
> 必须使用 **4.1 配置加载器** 中的 `Config` 类，**禁止**直接使用 `configparser` 或硬编码路径。

---

## 5. 中间件（强制）

### 5.1 请求ID中间件（强制）

```python
# utils/middleware.py

import uuid
from flask import g, request


def init_request_id(app):
    @app.before_request
    def set_request_id():
        g.request_id = request.headers.get('X-Request-ID') or str(uuid.uuid4())

    @app.after_request
    def add_request_id_header(response):
        response.headers['X-Request-ID'] = getattr(g, 'request_id', '-')
        return response
```

### 5.2 全局请求日志中间件（强制）

```python
# utils/request_log.py

import json
import time
from flask import request, g

SENSITIVE_FIELDS = ['password', 'pwd', 'token', 'secret', 'apiKey', 'api_key']


def mask_sensitive(data):
    """脱敏敏感字段"""
    if not isinstance(data, dict):
        return data
    masked = {}
    for k, v in data.items():
        if k.lower() in SENSITIVE_FIELDS:
            masked[k] = '******'
        elif isinstance(v, dict):
            masked[k] = mask_sensitive(v)
        else:
            masked[k] = v
    return masked


def init_request_log(app):
    @app.before_request
    def before_request():
        g.start_time = time.time()

        if request.path.startswith('/static') or request.endpoint is None:
            return

        request_id = getattr(g, 'request_id', '-')

        req_data = {
            'request_id': request_id,
            'method': request.method,
            'path': request.path,
            'ip': request.remote_addr,
        }

        if request.args:
            req_data['query'] = dict(request.args)

        if request.is_json:
            body = request.get_json(silent=True)
            if body:
                req_data['body'] = mask_sensitive(body)

        admin_request_log.save_info(json.dumps(req_data, ensure_ascii=False))

    @app.after_request
    def after_request(response):
        if request.path.startswith('/static') or request.endpoint is None:
            return response

        start_time = getattr(g, 'start_time', time.time())
        cost_time = round((time.time() - start_time) * 1000, 2)

        request_id = getattr(g, 'request_id', '-')
        user_id = getattr(g, 'user_id', '-')

        resp_data = {
            'request_id': request_id,
            'user_id': user_id,
            'method': request.method,
            'path': request.path,
            'cost_time': f'{cost_time}ms',
            'status_code': response.status_code,
        }

        if hasattr(response, 'get_json'):
            resp_json = response.get_json(silent=True)
            if resp_json:
                resp_data['code'] = resp_json.get('code', 0)
                resp_data['msg'] = resp_json.get('msg', '')

        admin_response_log.save_info(json.dumps(resp_data, ensure_ascii=False))
        return response
```

---

## 6. 日志规范（强制）

### 6.1 日志封装类（强制）

```python
# utils/loggings.py
# -*- coding: utf-8 -*-
"""
日志封装
"""

import os
import logging
from concurrent_log_handler import ConcurrentTimedRotatingFileHandler, ConcurrentRotatingFileHandler
import colorlog

from common.constants import LOGGING_BASE_DIR

FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
LOG_COLORS_CONFIG = {'DEBUG': 'cyan', 'INFO': 'green', 'WARNING': 'yellow', 'ERROR': 'red', 'CRITICAL': 'bold_red'}


class Logger:
    """日志封装类"""

    CRITICAL = 50
    ERROR = 40
    WARNING = 30
    INFO = 20
    DEBUG = 10

    def __init__(self, name, folder, type_=1, backup_count=9, vol=1, is_switch=True, is_save_file=False, is_print_console=True):
        self.name = name
        self.log_folder = os.path.join(LOGGING_BASE_DIR, folder)
        self.formatter = logging.Formatter(FORMAT)
        self.type_ = type_
        self.backup_count = backup_count
        self.vol = vol
        self.is_switch = is_switch
        self.is_save_file = is_save_file
        if self.is_save_file and not os.path.exists(self.log_folder):
            os.makedirs(self.log_folder)
        self.is_print_console = is_print_console

    def set_logger(self, level):
        if not hasattr(self, f'logger_{level}'):
            logger = logging.getLogger(self.name + '_' + level)
            logger.setLevel(eval(f'self.{level.upper()}'))
            if self.is_save_file:
                if self.type_ == 1:
                    file_handler = ConcurrentTimedRotatingFileHandler(
                        os.path.join(self.log_folder, f'{self.name}_{level}.log'),
                        encoding='utf-8', when='D', interval=self.vol,
                        backupCount=self.backup_count)
                elif self.type_ == 2:
                    file_handler = ConcurrentRotatingFileHandler(
                        os.path.join(self.log_folder, f'{self.name}_{level}.log'),
                        maxBytes=self.vol, backupCount=self.backup_count, encoding='utf-8')
                else:
                    file_handler = None
                if file_handler:
                    file_handler.setLevel(eval(f'self.{level.upper()}'))
                    file_handler.setFormatter(self.formatter)
                    logger.addHandler(file_handler)
            if self.is_print_console:
                console_formatter = colorlog.ColoredFormatter(
                    f'%(log_color)s{FORMAT}', log_colors=LOG_COLORS_CONFIG)
                console_handler = logging.StreamHandler()
                console_handler.setLevel(eval(f'self.{level.upper()}'))
                console_handler.setFormatter(console_formatter)
                logger.addHandler(console_handler)
            setattr(self, f'logger_{level}', logger)

    def save_log(self, msg, level, exc_info=None):
        if self.is_switch:
            self.set_logger(level)
            eval(f'self.logger_{level}.{level}({repr(msg)}, exc_info={exc_info})')

    def save_critical(self, msg):
        self.save_log(msg, 'critical', exc_info=True)

    def save_error(self, msg):
        self.save_log(msg, 'error', exc_info=True)

    def save_warning(self, msg):
        self.save_log(msg, 'warning')

    def save_info(self, msg):
        self.save_log(msg, 'info')

    def save_debug(self, msg):
        self.save_log(msg, 'debug')


# 预定义日志实例
admin_request_log = Logger('admin_request', 'logs', is_switch=True, is_save_file=True, is_print_console=True)
admin_response_log = Logger('admin_response', 'logs', is_switch=True, is_save_file=True, is_print_console=True)
http_requests_log = Logger('http_requests', 'logs', is_switch=True, is_save_file=True, is_print_console=True)
general_log = Logger('general', 'logs', is_switch=True, is_save_file=True, is_print_console=True)
```

---

## 7. 异常处理（强制）

### 7.1 全局异常处理（强制）

```python
# apps/__init__.py

def register_error_handlers(app):
    from utils.responses import api_error
    from utils.loggings import admin_response_log
    import traceback
    from flask import request, g
    import json

    @app.errorhandler(404)
    def not_found(e):
        return api_error(404, '请求的资源不存在')

    @app.errorhandler(500)
    def server_error(e):
        return api_error(500, '服务器内部错误')

    @app.errorhandler(Exception)
    def handle_exception(e):
        request_id = getattr(g, 'request_id', '-')
        error_info = {
            'request_id': request_id,
            'path': request.path,
            'error': str(e)
        }
        admin_response_log.save_critical(json.dumps(error_info, ensure_ascii=False))
        return api_error(500, '服务器内部错误')
```

### 7.2 自定义异常（强制）

```python
# utils/exceptions.py

class GeneralError(Exception):
    def __init__(self, *args, **kwargs):
        pass

    def __str__(self):
        return self.args[0]
```

---

## 8. 错误码（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第1章

---

## 9. 响应规范（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第2章

### 9.1 Flask 响应实现（强制）

```python
# utils/responses.py

from flask import jsonify
from common.codes import get_error_message


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

---

## 10. 认证授权（强制）

### 10.1 登录装饰器（强制）

```python
# utils/decorators.py

from functools import wraps
from flask import request, g
from utils.responses import api_error
from db.redis.helpers import admin_redis
from common.constants import AdminRedisKeys


def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')

        if not token:
            return api_error(401, '请先登录')

        user_id = admin_redis.get(AdminRedisKeys.ADMIN_USER_TOKEN.format(token))
        if not user_id:
            return api_error(401, '登录已过期')

        g.user_id = user_id
        g.token = token

        return f(*args, **kwargs)

    return decorated_function
```

### 10.2 权限装饰器（强制）

```python
def permission_required(*permission_codes):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            from db.mysql.models import User, Role

            user_id = getattr(g, 'user_id', None)
            if not user_id:
                return api_error(401, '请先登录')

            user = db.session.get(User, int(user_id))
            if not user:
                return api_error(401, '用户不存在')

            role = db.session.get(Role, user.role_id)
            if not role:
                return api_error(403, '用户角色不存在')

            user_permissions = role.permissions or []

            if '*' in user_permissions:
                return f(*args, **kwargs)

            for code in permission_codes:
                if code not in user_permissions:
                    return api_error(403, f'无权限: {code}')

            return f(*args, **kwargs)

        return decorated_function

    return decorator
```

### 10.3 Token管理（Redis）（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/缓存规范.md`

```python
# 同一账号只能在一处登录，新登录会使之前的token失效

# 生成新token（含用户信息确保唯一）
token = generate_login_token(user.id, user.username)

# 存储双向映射
admin_redis.set(AdminRedisKeys.ADMIN_USER_TOKEN.format(token), user_id, ex=86400)
admin_redis.set(AdminRedisKeys.ADMIN_USER_TOKEN_BY_ID.format(user_id), token, ex=86400)

# 删除该用户之前的token
old_token = admin_redis.get(AdminRedisKeys.ADMIN_USER_TOKEN_BY_ID.format(user_id))
if old_token:
    admin_redis.delete(AdminRedisKeys.ADMIN_USER_TOKEN.format(old_token))
```

---

## 11. Swagger文档 (Flasgger)（强制）

### 11.1 Flasgger配置（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第6章

> ⚠️ **强制要求：先写文档，后写代码**
>
> **每个接口必须先在视图函数docstring中编写文档，再编写视图函数实现。**
>
> **必须包含完整字段**：summary、description、parameters（含各参数example）、responses（含examples示例）。
>
> **检查模板文件**：
> - 检查 `docs/API文档/swagger_template.md` 是否存在
> - 若不存在 → **必须先询问用户**是否需要创建模板文件
> - 若存在 → 参考模板格式编写

**仅非生产环境可用**：仅在开发/测试环境启用，生产环境自动禁用，不暴露接口信息。

```python
# apps/__init__.py

def get_internal_ip():
    import socket
    hostname = socket.gethostname()
    return socket.gethostbyname(hostname)


def register_swagger(app, protect=True):
    from common.constants import ENV_TYPE

    if ENV_TYPE == 'prod':
        return  # 生产环境不启用Swagger

    from flasgger import Swagger, NO_SANITIZER

    swagger_config = {
        "headers": [],
        "specs": [{"endpoint": "apispec_1", "route": "/apispec_1.json", "rule_filter": lambda rule: True}],
        "static_url_path": "/flasgger_static",
        "swagger_ui": True,
        "specs_route": "/apidocs/",
        "swagger_ui_bundle_js": "//unpkg.com/swagger-ui-dist@3.52.5/swagger-ui-bundle.js",
        "swagger_ui_standalone_preset_js": "//unpkg.com/swagger-ui-dist@3.52.5/swagger-ui-standalone-preset.js",
        "swagger_ui_css": "//unpkg.com/swagger-ui-dist@3.52.5/swagger-ui.css",
    }

    Swagger(app, config=swagger_config, sanitizer=NO_SANITIZER, template={
        "swagger": "2.0",
        "info": {"title": "API文档", "version": "1.0.0"},
        "host": f"{get_internal_ip()}:{app_conf.get('port')}",
        "basePath": "/api",
        "tags": [
            {"name": "系统管理/认证管理", "description": "用户登录、退出等认证相关接口"},
            {"name": "系统管理/用户管理", "description": "用户信息管理接口"},
        ],
        "securityDefinitions": {
            "Bearer": {"type": "apiKey", "name": "Authorization", "in": "header", "description": "JWT Token"}
        },
        "security": [{"Bearer": []}]
    })

    # HTTP Basic Auth保护文档
    if protect:
        @app.before_request
        def protect_swagger():
            swagger_paths = ['/apidocs', '/apispec_1.json', '/static/flasgger/']
            if any(request.path.startswith(p) for p in swagger_paths):
                auth = request.authorization
                if not auth or not (auth.username == 'admin' and auth.password == 'admin123'):
                    return Response('Login Required', 401, {'WWW-Authenticate': 'Basic realm="Login Required"'})
```

### 11.2 docstring格式要求（强制）

> ⚠️ **重要：标题与`---`之间不能有空行**，否则Flasgger解析会出错

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

### 11.3 必需字段（强制）

| 字段 | 必须 | 说明 |
|:-----|:-----|:-----|
| summary | ✅ | 接口简短描述 |
| description | ✅ | 接口详细描述 |
| parameters | ✅ | 请求参数（位置、名称、类型、必填、说明、示例） |
| responses | ✅ | 响应格式（状态码、描述、示例） |

### 11.4 文档导出（强制）

1. 完成接口开发后，运行 `python tools/export_docs.py` 导出文档
2. 自动生成 `swagger_spec.json` 和 `API文档.md`

---

## 12. API路径规范（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第3章

---

## 13. API参数命名规范（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第4章

---

## 14. 参数验证（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第5章

### 14.1 Flask 参数获取示例（强制）

```python
from flask import request

# 获取查询参数
id = request.args.get('id')
status = request.args.get('status')

# 获取body参数
data = request.get_json()
user_id = data.get('id')

# 分页参数
page_no = request.args.get('page_no', 1, type=int)
page_size = request.args.get('page_size', 10, type=int)
```

---

## 15. 辅助函数

### 15.1 密码处理（强制）

```python
# utils/helpers.py

import hashlib


def hash_password(password):
    """MD5加密"""
    return hashlib.md5(password.encode()).hexdigest()


def verify_password(password, hashed):
    """验证密码"""
    return hash_password(password) == hashed
```

### 15.2 Token生成（强制）

```python
# utils/helpers.py

import uuid
import time
import hashlib


def generate_token(length=32):
    """生成随机token"""
    return str(uuid.uuid4()).replace('-', '')[:length]


def generate_login_token(user_id, username):
    """生成登录token"""
    timestamp = str(int(time.time()))
    random_str = generate_token(8)
    raw = f'{user_id}:{username}:{timestamp}:{random_str}'
    return hashlib.sha256(raw.encode()).hexdigest()
```

### 15.3 验证码生成（强制）

```python
# utils/helpers.py

import random
from PIL import Image, ImageDraw, ImageFont


def generate_captcha(length=4):
    """生成验证码"""
    chars = 'abcdefghjkmnpqrstuvwxy3456789'
    return ''.join(random.choice(chars) for _ in range(length))


def generate_captcha_image(code):
    """生成验证码图片"""
    width, height = 120, 40
    image = Image.new('RGB', (width, height), color=(255, 255, 255))
    draw = ImageDraw.Draw(image)
    font = ImageFont.load_default()
    draw.text((10, 10), code, fill=(0, 0, 0), font=font)
    # 添加干扰线...
    return image
```

---

## 16. Excel导入导出（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第7章

### 16.1 Flask 特定实现（强制）

```python
# 获取上传文件
from flask import request
from openpyxl import load_workbook

file = request.files.get('file')
if not file or not file.filename.endswith('.xlsx'):
    return api_error(400, '请上传.xlsx格式文件')

wb = load_workbook(file)
ws = wb.active
rows = list(ws.iter_rows(values_only=True))

# 返回文件下载
from io import BytesIO
from flask import make_response

output = BytesIO()
wb.save(output)
output.seek(0)
response = make_response(output.getvalue())
response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
response.headers['Content-Disposition'] = 'attachment; filename=export.xlsx'
return response
```

---

## 17. CORS跨域（强制）

```python
# 在create_app中
cors_origins = config.get('cors', 'origins')
cors_origins_list = '*' if cors_origins == '*' else [o.strip() for o in cors_origins.split(',')]
supports_credentials = config.getboolean('cors', 'supports_credentials')
CORS(app, resources={r'/*': {'origins': cors_origins_list, 'supports_credentials': supports_credentials}})
```

---

## 18. Gunicorn配置

> ⚠️ **技术锁定**：Gunicorn 是 Python WSGI 特有的应用服务器，不属于通用部署规范。

### 18.1 Gunicorn启动器（强制）

```python
# gunicorn_loader.py

import multiprocessing
from gunicorn.app.base import BaseApplication
from geventwebsocket.gunicorn.workers import GeventWebSocketWorker

from common.settings import app_conf


def create_application():
    from app import app
    return app


class StandaloneApplication(BaseApplication):
    def __init__(self, options=None):
        self.options = options or {}
        super().__init__()

    def load_config(self):
        config = {
            'bind': f'{app_conf.get("host")}:{app_conf.getint("port")}',
            'worker_class': GeventWebSocketWorker,
            'workers': (multiprocessing.cpu_count() * 2) + 1,
            'accesslog': '-',
            'errorlog': '-'
        }
        for key, value in config.items():
            self.cfg.set(key.lower(), value)

    def load(self):
        return create_application()


app = create_application()


if __name__ == '__main__':
    StandaloneApplication().run()
```

**启动命令：** `python -u gunicorn_loader.py`

---

## 19. 环境变量（强制）

### 19.1 环境类型（强制）

```python
# common/constants.py

import sys

ENV_TYPE = 'dev'
sys_args = sys.argv[1:]
if sys_args:
    if '--test' in sys_args:
        ENV_TYPE = 'test'
    elif '--prod' in sys_args:
        ENV_TYPE = 'prod'

IS_PRODUCT = ENV_TYPE == 'prod'
```

### 19.2 启动命令（强制）

```bash
# 开发环境
python app.py

# 测试环境
python app.py --test

# 生产环境
python app.py --prod
```

---

## 20. 规范执行检查清单（强制）

### 20.1 接口开发时必查（强制）

| 检查项 | 要求 |
|:-------|:-----|
| 参数名 | 单资源接口使用 `id`，关联表接口使用 `xxx_id` |
| docstring | 先写文档后写代码，标题与`---`之间不能有空行 |
| 字段注释 | 所有 `comment` 使用小写 `id`（如`角色id`） |
| responses | 必须包含 examples 示例 |
| 查询条件类型 | 单选用单值、多选用IN、范围用BETWEEN、模糊用LIKE |
| 导入接口 | docstring需包含total/success/fail/errors返回结构 |
| 导出接口 | docstring需声明content-type为Excel格式 |
| 模板下载 | 模板列名必须与需求文档字段含义一致 |

### 20.2 提交前必查（强制）

| 检查项 | 要求 |
|:-------|:-----|
| 接口参数 | 符合 **API参数命名规范** |
| docstring格式 | 符合 **11.2 docstring格式要求** |
| 查询条件 | 符合 **参数验证** 规范 |
| 导入导出 | 符合 **API规范** 导入导出流程 |
| 代码无冗余 | 无重复定义、无调试代码残留 |

### 20.3 配置管理必查（强制）

| 检查项 | 要求 |
|:-------|:-----|
| 配置文件路径 | 必须通过 `ENV_TYPE` 动态拼接（`config_{ENV_TYPE}.ini`），禁止硬编码 |
| 配置加载 | 必须使用 `Config` 类，禁止直接使用 `configparser` |
| 配置读取 | 禁止使用 `fallback` 默认值，缺失必须启动失败 |
| debug配置 | dev=true, test/prod=false，与环境匹配 |
| 敏感信息 | `secret_key`、`password` 等必须从配置文件读取，禁止硬编码 |

---

## 附录

### A. 相关文档（强制）

| 文档 | 位置 |
|:-----|:-----|
| **API通用规范** | `docs/技术规范/API规范.md` |
| **数据库规范** | `docs/技术规范/数据库规范.md` |
| **缓存规范** | `docs/技术规范/缓存规范.md` |
| **定时任务规范** | `docs/技术规范/定时任务规范.md` |
| **部署规范** | `docs/技术规范/部署规范.md` |
| Swagger文档模板 | `docs/API文档/swagger_template.md` |
| API文档导出脚本 | `tools/export_docs.py` |
| 导出后API文档 | `docs/API文档/swagger_spec.json` |
| 导出后Markdown | `docs/API文档/API文档.md` |

### B. 标签对照表（强制）

> ⚠️ **通用规范引用**：详见 `docs/技术规范/API规范.md` 第9章
