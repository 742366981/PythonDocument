# Django跨域配置

### 1.安装django-cors-headers

`pip install django-cors-headers `

### 2.配置settings.py文件

添加应用

```
INSTALLED_APPS = [
    'corsheaders',
]
```

添加中间件(必须放在django.middleware.common.CommonMiddleware之前)

```
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
]
```

其他配置

```
# 所有的跨域请求都被允许
CORS_ORIGIN_ALLOW_ALL = True

# 跨域请求白名单(如果配置了CORS_ORIGIN_ALLOW_ALL = True，可以忽略此项配置)
CORS_ORIGIN_WHITELIST = (
     'localhost:8000',
)

# 定义允许的匹配路径正则表达式
CORS_URLS_REGEX = '^.*$'

# 设置允许访问的方法
CORS_ALLOW_METHODS = (
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'OPTIONS',
)

# 后端是否支持对cookie的操作
CORS_ALLOW_CREDENTIALS = True

# 设置允许的请求头属性
CORS_ALLOW_HEADERS = (
    'XMLHttpRequest',
    'X_FILENAME',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'Pragma',
)
```

