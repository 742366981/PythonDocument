

### 1.安装及配置settings.py

安装djangorestframework

`pip install djangorestframework`

```
INSTALLED_APPS = (
    ...
    'rest_framework.authtoken'
)
```

### 2.生成相关表

```
# 直接migrate
python manage.py migrate
```

### 3.创建token

修改models.py

（1）第一种，配置所有，推荐第这种方法，sender指定settings.AUTH_USER_MODEL，这种方法会为每个用户添加token值

```
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token

# 为每个用户添加token验证
@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)
```

（2）第二种，sender指定实体

```
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

@receiver(post_save, sender=User)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)
```

### 4.rest_framework配置

在settings.py中添加

```
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated', #必须有
    ),
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.TokenAuthentication',
    )
}
```

### 5.客户端获取token

登录页面写如下的js代码

```
<script>
        $('form').on('submit',function () {
            var csrf=$('input[name=csrfmiddlewaretoken]').val();
            $.ajax({
                type:'POST',
                url:'/video/api-token-auth/',
                data:{'username':$('input[name=username]').val(),'password':$('input[name=password]').val()},
                dataType:'json',
                headers:{'X-CSRFToken':csrf},
                success:function (data) {
                    if(data){
                        localStorage.token=data.token;
                    }
                }
            });
        });
    </script>
```

内容加载页面发ajax请求时必须加入请求头 headers:{'Authorization':'token '+localStorage.token}

注：token后面有个空格

参考代码如下

```
<script>
		var parameter=location.search;
        $.ajax({
            type:'GET',
            url:'/video/movies/'+parameter,
            dataType:'json',
            headers:{'Authorization':'token '+localStorage.token},
            success:function (data) {
                if(data.data.previous){
                    $('#prev').attr('href',data.data.previous.replace('movies','index'));
                }
                if(data.data.next){
                    $('#next').attr('href',data.data.next.replace('movies','index'));
                }
                for(var i=0;i<data.data.results.length;i++){
                    $('#content').append($('<img>').attr({'src':data.data.results[i].movie_img,'width':196,'height':256}));
                }
            }
        });
    </script>
```