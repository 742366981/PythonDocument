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

添加中间件

```
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
]
```

其他配置

```
# 配置允许跨站访问本站的地址
CORS_ORIGIN_ALLOW_ALL = True
# CORS_ORIGIN_WHITELIST = (
#     'localhost:8000',  # 请求的域名(此处仅在CORS_ORIGIN_ALLOW_ALL = False时有效)
# )

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

# 跨域允许证书
CORS_ALLOW_CREDENTIALS = True

# 设置允许的header
CORS_ALLOW_HEADERS = (
    'Klicen-Agent',
    'Content-Type',
    'X-Requested-With',
    'xyt-agent',
)
```

