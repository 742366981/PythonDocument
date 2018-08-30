### 安装django-rest-framework

1.在终端输入以下命令安装

`pip install djangorestframework`

在settings.py的INSTALLED_APPS中加入：

```
INSTALLED_APPS = [
    ...
    'rest_framework',
    'rest_framework.authtoken',  # 设置token
    ...
]
```

2.安装django-rest-framework-jwt

安装jwt库，简单快速的生成我们所需要的token

在终端输入以下命令安装：

`pip install djangorestframework-jwt`

在你的settings.py，添加JSONWebTokenAuthentication到Django REST框架DEFAULT_AUTHENTICATION_CLASSES

    # django-rest-framework设置
    
    REST_FRAMEWORK = {
        'PAGE_SIZE': 10,
    # 设置所有接口都需要被验证
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_jwt.authentication.JSONWebTokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ),
    }
### 安装django-cors-headers

解决api跨域请求有好几种方法，比如（jsonp,在apache或nginx中设置，在请求头里设置），我们这里使用这个包来方便的跨域

1.在终端输入如下命令：
`pip install django-cors-headers`
2.配置settings.py文件

```
INSTALLED_APPS = [
    ...
    'corsheaders'，
    ...
 ] 

MIDDLEWARE_CLASSES = (
    ...
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware', # 注意顺序
    ...
)

CORS_ORIGIN_WHITELIST = (
    #'*'
    '127.0.0.1:8080',# 请求的域名
    'localhost:8080',
    'localhost',
)
```



### 配置

##### 后端配置

1.在setting里设置token的过期时间

```
import datetime

JWT_AUTH = {
    'JWT_EXPIRATION_DELTA': datetime.timedelta(seconds=300),
}
```

当然还有很多其他相关设置，可以自己翻阅文档

2.修改使用jwt验证的URL

```
from rest_framework_jwt.views import obtain_jwt_token

url(r'^api-token-auth/', obtain_jwt_token),
```

3.配置页面访问权限

按需设置访问权限(上面已设置所有接口都需要被验证)

加上token之后基本上是不经过认证是不能查看或修改数据的

##### 前端配置

（在前端我们使用jQuery封装的ajax来操作get和post）

1.使用post方法获取token并存入html的localStorage中

```
<script>
 function post_test() {
        $.post("http://127.0.0.1:8000/api-token-auth/",{
            'username':'earthchen',
            'password':'xxxxxxxx'
        },
        function(data){
            if(data){
                localStorage.token=data.token;  存入数据
            }
        })
    }
</script>
```

2.在请求数据时需要在头部添加token

```
<script>
function test(){
    $.ajax({
        headers:{
            'Authorization':'JWT '+localStorage.token  //注意：jwt后面有个空格
        },
        type:"get",
        url:"http://127.0.0.1:8000/snippets/1/",
        success:function(data){
           document.write(data.style);
        }
    })
}
<script>
```