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
        'rest_framework_jwt.authentication.JSONWebTokenAuthentication',  # 通过jwt验证
        'rest_framework.authentication.SessionAuthentication',  # 通过session验证
        'rest_framework.authentication.BasicAuthentication',  # 通过账号和密码验证
    ),
    }
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

2.配置获取token的URL

```
from rest_framework_jwt.views import obtain_jwt_token

url(r'^api-token-auth/', obtain_jwt_token),
```

获取方法：发POST请求到配好的URL,加上参数?username=用户名&password=密码

3.生成token

```
from rest_framework_jwt.settings import api_settings


def create_token(user):
    jwt_payload_handler = api_settings.JWT_PAYLOAD_HANDLER
    jwt_encode_handler = api_settings.JWT_ENCODE_HANDLER
    payload = jwt_payload_handler(user)
    token = jwt_encode_handler(payload)
    return token
```

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
        type:"GET",
        url:"http://127.0.0.1:8000/video/movies/",
        success:function(data){
           document.write(data.style);
        }
    })
}
<script>
```