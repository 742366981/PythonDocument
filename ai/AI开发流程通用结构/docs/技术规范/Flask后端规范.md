# Flask后端项目规范

本文档定义 Flask 后端项目的通用规范，适用于快速搭建完整的Flask项目框架。

---

## 1. 目录结构

```
project/
├── apps/                              # 应用模块（蓝图）
│   ├── __init__.py                   # 应用工厂、蓝图注册
│   ├── auth/                          # 示例：认证模块
│   │   ├── __init__.py
│   │   └── views.py
│   ├── user/                          # 示例：用户模块
│   ├── role/                          # 示例：角色模块
│   └── xxx/                           # 其他业务模块...
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
│       └── helpers.py                # Redis客户端
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
│   └── loggings.py                    # 日志封装
│
├── docs/                               # 文档
│   └── swagger_template.md            # Swagger文档模板
│
├── tools/                            # 工具脚本
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
├── requirements.txt                   # 依赖
├── gunicorn.conf.py                   # Gunicorn配置
├── Dockerfile                          # Docker镜像
└── docker-compose.yml                  # Docker Compose编排
```

---

## 2. 路径管理规范

### 2.1 禁止使用 sys.path

**严格禁止**在代码中使用 `sys.path.insert`、`sys.path.append` 等方式动态修改路径。

```python
# ❌ 禁止这样做
import sys
sys.path.insert(0, '/path/to/module')
```

### 2.2 禁止硬编码绝对路径

**严格禁止**在代码中写死绝对路径。

```python
# ❌ 禁止这样做
config_path = '/app/config/config_dev.ini'
upload_dir = '/data/uploads'

# ❌ 禁止这样做
file_path = 'D:\\project\\uploads\\file.xlsx'
```

### 2.3 统一使用 BASE_DIR

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

### 2.4 路径拼接示例

```python
import os
from common.constants import BASE_DIR

# 配置文件路径
config_dir = os.path.join(BASE_DIR, 'config')
config_path = os.path.join(config_dir, 'config_dev.ini')

# 日志目录
log_dir = os.path.join(BASE_DIR, 'logs')

# 上传文件目录
upload_dir = os.path.join(BASE_DIR, 'uploads')

# 数据库初始化脚本
db_init_dir = os.path.join(BASE_DIR, 'db_init')
```

---

## 3. Flask应用工厂

### 3.1 完整应用工厂

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
    cors_origins = config.get('cors', 'origins', fallback='*')
    cors_origins_list = '*' if cors_origins == '*' else [o.strip() for o in cors_origins.split(',')]
    supports_credentials = config.getboolean('cors', 'supports_credentials', fallback=True)
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

### 3.2 蓝图注册

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

## 4. 配置管理

### 4.1 配置加载器

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

### 4.2 配置文件格式

```ini
# config_dev.ini

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
debug = true
port = 8000

[request_log]
# 记录完整响应体的接口路径（逗号分隔）
full_response_paths = /auth/login,/auth/logout

[cors]
# 允许跨域的域名（逗号分隔，* 表示允许所有）
origins = *
supports_credentials = true
```

---

## 5. 中间件

### 5.1 请求ID中间件

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

### 5.2 全局请求日志中间件

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

## 6. 日志规范

### 6.1 日志封装类

```python
# utils/loggings.py

import os
import logging
from logging.handlers import RotatingFileHandler, TimedRotatingFileHandler
import colorlog

from common.constants import LOGGING_BASE_DIR, IS_PRODUCT, IS_MULTIPLE

if IS_MULTIPLE:
    from concurrent_log_handler import ConcurrentRotatingFileHandler as RotatingFileHandler, \
        ConcurrentTimedRotatingFileHandler as TimedRotatingFileHandler


class Logger:
    CRITICAL = 50
    ERROR = 40
    WARNING = 30
    INFO = 20
    DEBUG = 10
    FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    LOG_COLORS_CONFIG = {'DEBUG': 'cyan', 'INFO': 'green', 'WARNING': 'yellow', 'ERROR': 'red', 'CRITICAL': 'bold_red'}

    def __init__(self, name, folder, type_=1, backup_count=9, vol=1, is_switch=True, is_save_file=True,
                 is_print_console=True):
        self.name = name
        if IS_PRODUCT:
            self.log_folder = f'{LOGGING_BASE_DIR}/{folder}'
        else:
            self.log_folder = f'{LOGGING_BASE_DIR}/{folder}/test'
        self.formatter = logging.Formatter(self.FORMAT)
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
                    file_handler = TimedRotatingFileHandler(
                        f'{self.log_folder}/{self.name}_{level}.log',
                        encoding='utf-8', when='D', interval=self.vol,
                        backupCount=self.backup_count)
                elif self.type_ == 2:
                    file_handler = RotatingFileHandler(
                        f'{self.log_folder}/{self.name}_{level}.log',
                        maxBytes=self.vol, backupCount=self.backup_count, encoding='utf-8')
                else:
                    file_handler = None
                file_handler.setLevel(eval(f'self.{level.upper()}'))
                file_handler.setFormatter(self.formatter)
                logger.addHandler(file_handler)
            if self.is_print_console:
                console_formatter = colorlog.ColoredFormatter(
                    f'%(log_color)s{self.FORMAT}', log_colors=self.LOG_COLORS_CONFIG)
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
admin_request_log = Logger('admin_request', 'logs', is_switch=True, is_save_file=False, is_print_console=True)
admin_response_log = Logger('admin_response', 'logs', is_switch=True, is_save_file=False, is_print_console=True)
http_requests_log = Logger('http_requests', 'logs', is_switch=True, is_save_file=False, is_print_console=True)
general_log = Logger('general', 'logs', is_switch=True, is_save_file=False, is_print_console=True)
```

---

## 7. 异常处理

### 7.1 全局异常处理

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

### 7.2 自定义异常

```python
# utils/exceptions.py

class GeneralError(Exception):
    def __init__(self, *args, **kwargs):
        pass

    def __str__(self):
        return self.args[0]
```

---

## 8. 错误码

### 8.1 错误码定义

```python
# common/codes.py

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
    # 示例：业务错误码，从10001开始
    USER_NOT_FOUND = 10001
    USER_DISABLED = 10002
    # ... 其他业务错误码


BIZ_ERROR_MESSAGES = {
    BizErrCode.USER_NOT_FOUND: '用户不存在',
    # ...
}


def get_error_message(code, default=None):
    if code in ERROR_MESSAGES:
        return ERROR_MESSAGES[code]
    if code in BIZ_ERROR_MESSAGES:
        return BIZ_ERROR_MESSAGES[code]
    return default or f'未知错误({code})'
```

---

## 9. 响应规范

### 9.1 统一响应函数

```python
# utils/responses.py

from flask import jsonify
from common.codes import get_error_message


def api_success(data=None, msg='success', code=0):
    """成功响应

    Args:
        data: 响应数据，None时不返回data字段
        msg: 成功消息，默认success
        code: 状态码，默认0
    """
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

### 9.2 响应状态码

| code | 说明 |
|:----:|:-----|
| 0 | 成功 |
| 400 | 参数错误 |
| 401 | 未登录或token过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

### 9.3 实际响应示例

**1. 无数据成功响应**
```json
{
  "code": 0,
  "msg": "success"
}
```

**2. 有数据成功响应**
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**3. 分页响应**
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "records": [
      {"id": 1, "name": "示例"},
      {"id": 2, "name": "示例2"}
    ],
    "page_no": 1,
    "page_size": 10,
    "total_page": 1,
    "total_count": 2
  }
}
```

**4. 错误响应**
```json
{
  "code": 400,
  "msg": "参数错误"
}
```

### 9.4 使用规范

| 场景 | 使用函数 | data字段 |
|:-----|:--------|:---------|
| 创建成功 | `api_success` | 返回新记录的id |
| 操作成功（更新/删除/状态修改） | `api_success` | 无（只有msg） |
| 列表/详情查询成功 | `api_success` | 返回查询数据 |
| 分页查询成功 | `api_page` | 返回分页结构 |
| 参数错误 | `api_error` | 无 |
| 未登录 | `api_error` | 无 |
| 无权限 | `api_error` | 无 |
| 服务器错误 | `api_error` | 无（统一返回"服务器内部错误"） |

### 9.5 关键特性

1. **所有接口统一返回 HTTP 200**，通过响应体 `code` 字段判断成功/失败
2. **`api_success` 不传data时不返回data字段**，节省带宽
3. **操作类接口（更新/删除）成功时不需要返回data**
4. **全局异常处理器统一返回"服务器内部错误"**，不暴露具体错误信息

---

## 10. 认证授权

### 10.1 登录装饰器

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

### 10.2 权限装饰器

```python
def permission_required(*permission_codes):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            from db.mysql.models import User, Role

            user_id = getattr(g, 'user_id', None)
            if not user_id:
                return api_error(401, '请先登录')

            user = User.query.get(int(user_id))
            if not user:
                return api_error(401, '用户不存在')

            role = Role.query.get(user.role_id)
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

### 10.3 Token管理（Redis）

```python
# common/constants.py

class AdminRedisKeys:
    ADMIN_PREFIX = 'app'
    ADMIN_USER_TOKEN = f'{ADMIN_PREFIX}:user:token:{{}}'
    ADMIN_USER_TOKEN_BY_ID = f'{ADMIN_PREFIX}:user:token_by_id:{{}}'
    ADMIN_CAPTCHA = f'{ADMIN_PREFIX}:captcha:{{}}'
    # ...
```

### 10.4 单点登录实现

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

## 11. 数据库模型

### 11.1 BaseModel基类

```python
# db/mysql/helpers.py

from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from decimal import Decimal

db = SQLAlchemy()


class BaseModel(db.Model):
    __abstract__ = True

    def save(self):
        if self.id is None:
            db.session.add(self)
        db.session.commit()
        return self

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    def to_dict(self):
        result = {}
        for column in self.__table__.columns:
            value = getattr(self, column.name)
            if value is None:
                result[column.name] = None
            elif isinstance(value, Decimal):
                result[column.name] = float(value)
            elif hasattr(value, 'isoformat'):
                result[column.name] = value.strftime('%Y-%m-%d %H:%M:%S')
            else:
                result[column.name] = value
        return result
```

### 11.2 模型示例

```python
# db/mysql/models/user.py

from db.mysql.helpers import db, BaseModel


class User(BaseModel):
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(64), unique=True, index=True, comment='用户名')
    password = db.Column(db.String(128), comment='密码')
    phone = db.Column(db.String(32), comment='手机号')
    role_id = db.Column(db.Integer, index=True, comment='角色ID')
    status = db.Column(db.Integer, default=1, comment='状态 0禁用 1启用')
    login_count = db.Column(db.Integer, default=0, comment='登录次数')
    last_login_time = db.Column(db.DateTime, comment='最后登录时间')
    create_user = db.Column(db.Integer, comment='创建人')
    update_user = db.Column(db.Integer, comment='更新人')
    create_time = db.Column(db.DateTime, default=datetime.now, comment='创建时间')
    update_time = db.Column(db.DateTime, onupdate=datetime.now, comment='更新时间')
```

### 11.3 外键规范

**禁止使用数据库外键约束**，通过业务逻辑维护数据一致性。

```python
# 外键字段使用普通INT + 索引
role_id = db.Column(db.Integer, index=True)
```

---

## 12. Redis缓存

### 12.1 Redis客户端

使用 `db/redis/helpers.py` 中的 `admin_redis`：

| 方法 | 说明 |
|:-----|:-----|
| `get(key)` | 获取值 |
| `set(key, value, ex=None)` | 设置值，ex为过期秒数 |
| `delete(*keys)` | 删除 |
| `atomic_lock(key, ex=15)` | 分布式锁（nx=True, ex指定时间） |
| `delete_pattern(pattern)` | 批量删除（支持*通配） |
| `hget/hset/hdel` | Hash操作 |

### 12.2 Key命名规范

**所有Key在 `common/constants.py` 的 `AdminRedisKeys` 类中定义，禁止硬编码。**

```python
class AdminRedisKeys:
    ADMIN_PREFIX = 'app'
    ADMIN_USER_TOKEN = f'{ADMIN_PREFIX}:user:token:{{}}'  # {{}} 运行时替换
    ADMIN_CAPTCHA = f'{ADMIN_PREFIX}:captcha:{{}}'
    # ...
```

### 12.3 使用示例

```python
from common.constants import AdminRedisKeys
from db.redis.helpers import admin_redis

# 存储（运行时替换{{}}）
admin_redis.set(AdminRedisKeys.ADMIN_USER_TOKEN.format(token), user_id, ex=86400)

# 批量清除缓存
admin_redis.delete_pattern(f'{AdminRedisKeys.ADMIN_PREFIX}:cache:*')

# 定时任务分布式锁
@with_scheduler_lock('task_name', expire_seconds=3600)
def my_task():
    pass
```

---

## 13. Swagger文档 (Flasgger)

### 13.1 Flasgger配置

```python
# apps/__init__.py

def register_swagger(app, protect=True):
    from common.settings import config
    is_dev = config.getboolean('app', 'debug', fallback=False)

    if not is_dev:
        return  # 生产环境不启用Swagger

    from flasgger import Swagger

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

    Swagger(app, config=swagger_config, template={
        "swagger": "2.0",
        "info": {"title": "API文档", "version": "1.0.0"},
        "host": f"{get_internal_ip()}:{app_conf.get('port')}",
        "basePath": "/api",
        "tags": [
            {"name": "系统管理/认证管理", "description": "用户登录、退出等认证相关接口"},
            {"name": "系统管理/用户管理", "description": "用户信息管理接口"},
            # ... 其他标签
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

### 13.2 接口文档装饰器

```python
# apps/auth/views.py

from flasgger import swag_from


@auth_bp.route('/login', methods=['POST'])
@swag_from({
    'tags': ['系统管理/认证管理'],
    'summary': '用户登录',
    'description': '使用用户名和密码进行登录，返回JWT token。',
    'parameters': [
        {
            'name': 'body',
            'in': 'body',
            'required': True,
            'schema': {
                'type': 'object',
                'example': {'username': 'admin', 'password': '0192023a7bbd73250516f069df18b500'},
                'properties': {
                    'username': {'type': 'string', 'example': 'admin', 'description': '用户名'},
                    'password': {'type': 'string', 'example': '0192023a7bbd73250516f069df18b500', 'description': '密码(MD5)'}
                },
                'required': ['username', 'password']
            }
        }
    ],
    'responses': {
        200: {
            'description': '登录成功',
            'schema': {
                'type': 'object',
                'properties': {
                    'code': {'type': 'integer', 'example': 0},
                    'msg': {'type': 'string', 'example': 'success'},
                    'data': {
                        'type': 'object',
                        'properties': {
                            'token': {'type': 'string'},
                            'user': {'type': 'object'}
                        }
                    }
                }
            }
        }
    }
})
def login():
    # ...
```

### 13.3 文档导出

接口文档通过 `@swag_from` 装饰器定义，运行脚本自动生成可读文档：

| 文件 | 说明 |
|:-----|:-----|
| `docs/API文档/swagger_template.md` | 接口文档模板，复制到视图函数前 |
| `tools/export_docs.py` | 导出脚本 |
| `docs/API文档/swagger_spec.json` | 导出的 JSON 规范文件 |
| `docs/API文档/API文档.md` | 生成的 Markdown 文档 |

**使用流程**：
1. 参考 `swagger_template.md` 中的模板，在视图函数添加 `@swag_from` 装饰器
2. 运行 `python tools/export_docs.py` 导出文档
3. 自动生成 `swagger_spec.json` 和 `API文档.md`

---

## 14. API路径规范

| 类型 | 规则 | 示例 |
|:-----|:-----|:-----|
| URL路径 | 中横线分隔 | /exchange-rate |
| 列表接口 | /list | /user/list |
| 详情接口 | /detail | /user/detail |
| 创建接口 | /create | POST /user/create |
| 更新接口 | /update | POST /user/update |
| 删除接口 | /delete | POST /user/delete |
| 批量删除 | /batch-delete | POST /user/batch-delete |
| 导入接口 | /import | POST /user/import |
| 导出接口 | /export | GET /user/export |
| 模板下载 | /template/download | GET /user/template/download |

---

## 15. 参数验证

### 15.1 验证函数

```python
# utils/validators.py

import re


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

### 15.2 多选查询参数

```python
# GET /user/list?role_id=1,2,3

def parse_multi_ids(value):
    if not value:
        return []
    if isinstance(value, list):
        return value
    return [int(x) for x in value.split(',') if x.strip().isdigit()]
```

---

## 16. 辅助函数

### 16.1 密码处理

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

### 16.2 Token生成

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

### 16.3 验证码生成

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

## 17. Excel导入导出

### 17.1 模板修改标准

**重要规范**：

1. **模板列名** = 数据库字段含义，简短命名（如"名称"而非"名称字段"）
2. **模板列** = 新增接口接收的参数（去除系统字段如id、create_time等）
3. **导入逻辑**：用code匹配（优先），code不匹配再用name
4. **导出列** = 模板列（保持对称）
5. **唯一约束**：明确组合唯一字段，重复时upsert
6. **字段注释**：数据库注释与API文档描述一致
7. **是/否字段**：填写"是"或"否"，内部转1/0
8. **关联查询**：填写code（如"US"），内部转ID

### 17.2 通用模板示例

**示例：基础数据导入模板**

| 模块 | 模板列 |
|:-----|:-------|
| 国家/地区 | 代码, 名称, 类型, 币种, 区域, 层级 |
| 平台 | 代码, 名称 |
| 部门 | 代码, 名称 |
| 币种 | 代码, 名称, 符号 |
| 分类 | 代码, 名称, 上级代码 |

**示例：业务配置导入模板**

| 模块 | 模板列 |
|:-----|:-------|
| 费率配置 | 类型, 名称, 费率, 生效日期, 失效日期 |
| 价格配置 | 商品分类, 规格, 单位, 单价, 最低价, 最高价 |

### 17.3 是/否字段规范

| 模板列名 | 导入填写 | 内部存储 |
|:---------|:---------|:---------|
| 是否启用 | "是" / "否" | 1 / 0 |
| 是否含税 | "是" / "否" | 1 / 0 |
| 是否必填 | "是" / "否" | 1 / 0 |

---

## 18. CORS跨域

### 18.1 配置

```python
# 在create_app中
cors_origins = config.get('cors', 'origins', fallback='*')
cors_origins_list = '*' if cors_origins == '*' else [o.strip() for o in cors_origins.split(',')]
supports_credentials = config.getboolean('cors', 'supports_credentials', fallback=True)
CORS(app, resources={r'/*': {'origins': cors_origins_list, 'supports_credentials': supports_credentials}})
```

---

## 19. Gunicorn配置

### 19.1 配置文件

```python
# gunicorn.conf.py

import multiprocessing

bind = "0.0.0.0:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "gevent"
keepalive = 65
timeout = 30
graceful_timeout = 10
max_requests = 1000
max_requests_jitter = 50
accesslog = "-"
errorlog = "-"
loglevel = "info"
```

---

## 20. Docker配置

### 20.1 Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
```

### 20.2 docker-compose.yml

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - ENV_TYPE=prod
    volumes:
      - ./logs:/app/logs
```

---

## 21. 环境变量

### 21.1 环境类型

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

### 21.2 启动命令

```bash
# 开发环境
python app.py

# 测试环境
python app.py --test

# 生产环境
python app.py --prod
```

---

## 22. 数据库初始化

### 22.1 初始化脚本结构

```python
# db_init/init_all.py

from apps import create_app
from db.mysql.helpers import db


def init_database():
    app = create_app(protect_swagger=False)
    with app.app_context():
        # 创建所有表
        db.create_all()
        # 初始化数据
        init_default_data()


if __name__ == '__main__':
    init_database()
```

---

## 23. 命名规范

### 23.1 数据库字段

| 类型 | 规则 | 示例 |
|:-----|:-----|:-----|
| 普通字段 | 下划线 | user_name |
| 外键 | xxx_id | role_id |
| 状态 | status (0禁用/1启用) | status |
| 时间 | create_time, update_time | create_time |
| 创建人 | create_user (存ID) | create_user |
| 更新人 | update_user (存ID) | update_user |

### 23.2 Python变量

| 类型 | 规则 | 示例 |
|:-----|:-----|:-----|
| 普通变量 | 下划线 | user_list |
| 常量 | 全大写 | PAGE_SIZE |
| 类名 | 大驼峰 | UserService |

### 23.3 API路径

| 类型 | 规则 | 示例 |
|:-----|:-----|:-----|
| URL | 中横线 | /user-info |
| 文件名 | 下划线 | user_info.py |

---

## 24. 创建人/更新人规范

### 24.1 字段规范

- 使用 `create_user` / `update_user` 存储用户ID，不存储用户名
- 创建时自动填充：`create_user = g.user_id`
- 更新时自动填充：`update_user = g.user_id`

### 24.2 表设计

```python
create_user = db.Column(db.Integer, comment='创建人')
update_user = db.Column(db.Integer, comment='更新人')
create_time = db.Column(db.DateTime, default=datetime.now, comment='创建时间')
update_time = db.Column(db.DateTime, onupdate=datetime.now, comment='更新时间')
```

---

## 25. 定时任务机制

### 25.1 技术选型

| 组件 | 技术 | 说明 |
|:-----|:-----|:-----|
| 调度器 | APScheduler BackgroundScheduler | 后台定时任务调度 |
| 分布式锁 | Redis | 多进程环境下的任务互斥 |
| 执行器 | ThreadPoolExecutor | 线程池执行任务 |

### 25.2 目录结构

```
project/
├── utils/
│   ├── scheduler.py          # 调度器配置和初始化
│   └── scheduler_lock.py     # Redis分布式锁
├── jobs/                     # 定时任务目录
│   ├── __init__.py
│   └── example.py            # 示例任务
└── app.py                    # 启动时初始化调度器
```

### 25.3 调度器配置

```python
# utils/scheduler.py

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.executors.pool import ThreadPoolExecutor

scheduler = BackgroundScheduler(
    executors={
        'default': ThreadPoolExecutor(10)  # 线程池大小
    },
    job_defaults={
        'coalesce': False,   # 不合并错过的任务
        'max_instances': 1   # 同一任务最多一个实例
    }
)
```

### 25.4 App Context包装器

定时任务在独立线程中执行，需要手动注入Flask应用上下文：

```python
# utils/scheduler.py

_app = None

def _job_wrapper(func):
    """为定时任务包装app_context"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        with _app.app_context():
            return func(*args, **kwargs)
    return wrapper


def init_scheduler(app: Flask):
    """初始化调度器，注册定时任务"""
    global _app
    _app = app

    from jobs.example import daily_cleanup, sync_data

    # 每日清理任务：每天凌晨2:00执行
    scheduler.add_job(
        _job_wrapper(daily_cleanup),
        'cron',
        hour=2,
        minute=0,
        id='daily_cleanup',
        name='每日清理任务',
        replace_existing=True
    )

    # 数据同步任务：每5分钟执行
    scheduler.add_job(
        _job_wrapper(sync_data),
        'interval',
        minutes=5,
        id='sync_data',
        name='数据同步任务',
        replace_existing=True
    )

    scheduler.start()
```

### 25.5 执行时间类型

| 类型 | 参数 | 示例 |
|:-----|:-----|:-----|
| cron | hour, minute, day | 每天凌晨2:00执行 |
| interval | minutes/hours/days | 每5分钟执行 |
| date | run_date | 特定日期执行 |

```python
# Cron表达式
scheduler.add_job(func, 'cron', hour=2, minute=0)           # 每天2:00
scheduler.add_job(func, 'cron', hour=2, minute=0, day='*')  # 同上
scheduler.add_job(func, 'cron', day_of_week='mon-fri')    # 工作日

# Interval表达式
scheduler.add_job(func, 'interval', minutes=5)             # 每5分钟
scheduler.add_job(func, 'interval', hours=1)               # 每小时
scheduler.add_job(func, 'interval', days=1)                # 每天
```

### 25.6 Redis分布式锁

多进程环境下，使用Redis分布式锁防止任务重复执行：

```python
# utils/scheduler_lock.py

class SchedulerLock:
    """Redis分布式锁"""

    LOCK_PREFIX = f'{AdminRedisKeys.ADMIN_PREFIX}:scheduler:lock'

    def __init__(self, lock_key, expire_seconds=300):
        self.lock_key = f'{self.LOCK_PREFIX}:{lock_key}'
        self.expire_seconds = expire_seconds

    def acquire(self):
        """尝试获取锁"""
        result = admin_redis.atomic_lock(self.lock_key, ex=self.expire_seconds)
        return result is not None and result != 0

    def release(self):
        """释放锁"""
        admin_redis.delete(self.lock_key)

    def __enter__(self):
        return self.acquire()

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.release()
```

### 25.7 任务装饰器

使用 `@with_scheduler_lock` 装饰器为任务添加分布式锁：

```python
# jobs/example.py

from utils.scheduler_lock import with_scheduler_lock
from utils.loggings import general_log


@with_scheduler_lock('daily_cleanup', expire_seconds=3600)
def daily_cleanup():
    """
    每日清理任务示例

    执行时间: 每天凌晨2:00
    锁超时: 1小时
    """
    general_log.save_info("[daily_cleanup] 开始执行每日清理")
    # 任务逻辑...


@with_scheduler_lock('sync_data', expire_seconds=300)
def sync_data():
    """
    数据同步任务示例

    执行间隔: 每5分钟
    锁超时: 5分钟
    """
    general_log.save_info("[sync_data] 开始同步数据")
    # 任务逻辑...
```

### 25.8 启动配置

```python
# app.py

def init_scheduler_on_startup():
    """仅在生产环境启动定时任务"""
    if not IS_PRODUCT:
        print("定时任务调度器仅在生产模式启动")
        return

    import atexit
    from utils.scheduler import init_scheduler, shutdown_scheduler

    init_scheduler(app)
    print("定时任务调度器已启动 (生产模式)")
    atexit.register(shutdown_scheduler)


if __name__ == '__main__':
    app = create_app()
    init_scheduler_on_startup()
    app.run(host='0.0.0.0', port=8000)
```

### 25.9 添加新任务

**Step 1**: 在 `jobs/` 目录下创建任务文件

```python
# jobs/my_task.py

from utils.scheduler_lock import with_scheduler_lock
from utils.loggings import general_log


@with_scheduler_lock('my_task', expire_seconds=300)
def my_task():
    """我的定时任务"""
    general_log.save_info("[my_task] 开始执行")
    # 任务逻辑...
    general_log.save_info("[my_task] 执行完成")
```

**Step 2**: 在 `utils/scheduler.py` 中注册任务

```python
from jobs.my_task import my_task

scheduler.add_job(
    _job_wrapper(my_task),
    'interval',
    minutes=10,
    id='my_task',
    name='我的定时任务',
    replace_existing=True
)
```

### 25.10 任务日志

任务执行日志通过 `general_log` 记录：

```python
general_log.save_info(f"[{lock_key}] 开始执行")
general_log.save_info(f"[{lock_key}] 执行完成")
general_log.save_warning(f"[{lock_key}] 已被其他进程执行，跳过")
general_log.save_error(f"[{lock_key}] 执行异常: {e}")
```

日志输出到 `logs/general_info.log`。

### 25.11 注意事项

| 注意事项 | 说明 |
|:---------|:-----|
| 生产模式 | 定时任务仅在 `--prod` 模式下启动 |
| app_context | 任务函数会自动包装app_context，可直接使用db/redis |
| 分布式锁 | 多进程部署时必须使用 `@with_scheduler_lock` 装饰器 |
| 锁超时 | 根据任务预估执行时间设置 `expire_seconds`，避免任务卡死 |
| replace_existing | 使用 `replace_existing=True` 确保任务ID唯一，允许更新 |
