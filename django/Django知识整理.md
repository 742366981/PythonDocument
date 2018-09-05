## 1.Django创建项目及应用

创建项目：`django-admin startproject 项目名称 .`

创建应用：`python manage.py startapp 应用名称`

## 2.Django常用配置

**1.修改setting文件：**

修改系统语言：`LANGUAGE_CODE = 'zh-hans'`

修改时区：`TIME_ZONE = 'Asia/Chongqing'`

在INSTALLED_APPS中添加应用名称，如下添加应用名称demo：

```
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'demo',
]
```

添加模板目录：`'DIRS': [os.path.join(BASE_DIR, 'templates')],`

```
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]
```

配置数据库：先安装pymsql `pip install pymysql` ,然后将项目下面的__init__.py文件的内容修改为：

```
import pymysql
pymysql.install_as_MySQLdb()
```

最后在setting文件中配置以下内容：

```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'student',
        'HOST': 'localhost',
        'PORT': 3306,
        "USER": "root",
        'PASSWORD': '123456',
    }
}
```

添加静态资源目录：`STATICFILES_DIRS = [os.path.join(BASE_DIR, "static")]`
设置静态资源路径：`STATIC_URL = '/static/'`
没有登录会跳转到该地址：`LOGIN_URl = '/demo/mylogin/'`
设置选择上传图片的资源路径：`MEDIA_URL = '/media/'`	
设置选择上传图片的资源目录`MEDIA_ROOT = os.path.join(BASE_DIR, 'media')`

备注：使用上传图片功能需安装处理图片的库Pillow `pip install Pillow`

**2.url文件映射：**

在应用目录下新建一个url.py文件，配置内容如下：

```

from django.conf.urls import url
from stu import views

urlpatterns = [
    url(r'^s_index/', views.s_index, name='sindex'),
]
```

修改项目目录下的url.py文件：

```
from django.conf.urls import url, include
from django.contrib import admin

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^stu/', include('stu.urls', namespace='stu')),
]
```

**3.安装常用模块：**

处理图片的库：Pillow `pip install Pillow`

相关配置：基于前面的setting文件配置再做内容增加

在项目目录下的url.py文件中加入

```
from pj import settings
from django.contrib.staticfiles.urls import static
'''
原来的代码不动
'''
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

django中使用restful：`pip install djangorestframework==3.4.6` 

​				     `pip install django-filter==1.0.0`

相关配置：

a.在工程目录中的settings.py文件的INSTALLED_APPS中需要添加rest_framework 

b.定义应用目录下的url

```

from django.conf.urls import url
from rest_framework.routers import SimpleRouter

from stu import views

router = SimpleRouter()
router.register('student', views.StudentSource)
router.register('grade', views.GradeSource)

urlpatterns = [
    url(r'^s_index/', views.s_index, name='sindex'),
    url(r'^s_add/', views.s_add, name='s_add'),
]

urlpatterns += router.urls
```

c.修改视图文件views

```
from django.shortcuts import render

from rest_framework import mixins, viewsets
from rest_framework.response import Response

from stu.models import Student, Grade
from stu.stu_filters import StuFilter
from stu.stu_serializer import StuSerializer, GradeSerializer


def s_index(request):
    if request.method == 'GET':
        return render(request, 'student.html')


def s_add(request):
    if request.method == 'GET':
        return render(request, 'addstu.html')


class StudentSource(mixins.ListModelMixin,
                    mixins.RetrieveModelMixin,
                    mixins.DestroyModelMixin,
                    mixins.UpdateModelMixin,
                    mixins.CreateModelMixin,
                    viewsets.GenericViewSet):

    # 查询学生的数据
    queryset = Student.objects.all()
    # 序列化
    serializer_class = StuSerializer
    # 过滤
    filter_class = StuFilter

    def retrieve(self, request, *args, **kwargs):
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance)
            data =serializer.data
            data['msg'] = '请求成功哈哈哈哈哈哈'
        except:
            data = {
                'msg': '学生不存在',
                'code': 500
            }
        return Response(data)

    def perform_destroy(self, instance):
        instance.is_del = True
        instance.save()


class GradeSource(mixins.ListModelMixin,
                  viewsets.GenericViewSet):

    queryset = Grade.objects.all()

    serializer_class = GradeSerializer

```

d.应用目录下新建文件stu_serializer.py和stu_filters.py

```

from rest_framework import serializers

from stu.models import Student, Grade


class StuSerializer(serializers.ModelSerializer):

    s_name = serializers.CharField(max_length=3, error_messages={
        'blank': '姓名不能为空',
        'max_length': '长度太长'
    })

    class Meta:
        # 指定序列化的模型
        model = Student
        # 指定需要展示的字段
        fields = ['id', 's_name', 's_sex', 'g']

    def to_representation(self, instance):
        data = super().to_representation(instance)

        data['g'] = instance.g.g_name
        return data


class GradeSerializer(serializers.ModelSerializer):

    class Meta:
        model = Grade
        fields = ['id', 'g_name']

```

```

import django_filters
from rest_framework.filters import FilterSet

from stu.models import Student


class StuFilter(FilterSet):

    s_name = django_filters.CharFilter('s_name', lookup_expr='icontains')
    create_min = django_filters.DateTimeFilter('s_create_time', lookup_expr='gt')
    create_max = django_filters.DateTimeFilter('s_create_time', lookup_expr='lt')

    class Meta:
        model = Student
        fields = ['s_name',]

```

e.根目录下新建utils文件夹，然后在里面新建renderers.py文件

```

from rest_framework.renderers import JSONRenderer


class MyJsonRenderer(JSONRenderer):
    """
    重构返回结构
    {
        data: {},
        msg:'请求成功/失败',
        code: 200/0/400/500
    }
    """

    def render(self, data, accepted_media_type=None, renderer_context=None):

        if isinstance(data, dict):
            msg = data.pop('msg', '请求成功')
            code = data.pop('code', 0)
        else:
            msg = '请求成功'
            code = 0

        res = {
            'data': data,
            'msg': msg,
            'code': code,
        }
        return super().render(res, accepted_media_type=None, renderer_context=None)
```

f.setting配置

```
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS':'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE':2,
    'DEFAULT_FILTER_BACKENDS':(
        'rest_framework.filters.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter'
    ),
    'DEFAULT_RENDERER_CLASSES':(
        'utils.renderers.MyJsonRenderer',
    )
}
```

# 3.Django运行原理

在url，views，setting，数据库等都没有问题的情况下Django的执行原理如下：

在客户端（浏览器）输入url过后，客户端会立刻发出http请求，请求获得在服务端相应的内容，每个url都会对应一个视图函数，而请求就是该视图函数的一个参数，客户端发请求便是要调用这个视图函数，调用这个视图函数便会渲染出一个页面或者重定向（下面有解释），页面的内容大多会和数据库绑定上，通过修改数据库的内容页面的内容也会改变，在视图函数中写入相关的代码会让页面展示出不同的风格和增加某些功能。

重定向过程：  客户浏览器发送http请求 –> web服务器接受后发送302状态码响应及对应新的location给客户浏览器 –> 客户浏览器发现是302响应，则自动再发送一个新的http请求，请求url是新的location地址 –> 服务器根据此请求寻找资源并发送给客户  可以重定向到任意URL，既然是浏览器重新发出了请求，则就没有request传递。在客户浏览器路径栏显示的是其重定向的路径。重定向行为是浏览器做了至少两次的访问请求 。

最简单的理解：进入某个url就会调用与之对应的函数，通过函数调用渲染出页面或者重定向。

# 4.登录、注册、注销、中间件、随机cookie

导入模块

```
from django.contrib.auth.hashers import check_password, make_password
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.core.urlresolvers import reverse

from users.models import UserModel,UserTicketModel
from utils.functions import get_ticket
from datetime import  datetime,timedelta
```

注册

```
def register(request):
    if request.method == 'GET':
        return render(request, 'user/user_register.html')
    if request.method == 'POST':
        username = request.POST.get('username')
        email = request.POST.get('email')
        password = request.POST.get('password')
        password2 = request.POST.get('password2')
        icon = request.FILES.get('icon')
        if password == password2:
            password = make_password(password)
            UserModel.objects.create(username=username, password=password, email=email, icon=icon)
            return HttpResponseRedirect(reverse('user:login'))
```

登录

```
def login(request):
    if request.method == 'GET':
        return render(request, 'user/user_login.html')
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        if UserModel.objects.filter(username=username).exists():
            user = UserModel.objects.get(username=username)
            if check_password(password, user.password):
                res = HttpResponseRedirect(reverse('axf:home'))
                out_time = datetime.now() + timedelta(days=1)
                ticket = get_ticket()
                res.set_cookie('ticket', ticket, expires=out_time)
                UserTicketModel.objects.create(user=user,
                                               out_time=out_time,
                                               ticket=ticket)

                return res
            else:
                return HttpResponseRedirect(reverse('user:login'))
        else:
            return HttpResponseRedirect(reverse('user:login'))
```

注销

```
def logout(request):
    if request.method == 'GET':
        res = HttpResponseRedirect(reverse('axf:home'))
        res.delete_cookie('ticket')
        return res
```

中间件

```
import re
from datetime import datetime

from django.http import HttpResponseRedirect
from django.utils.deprecation import MiddlewareMixin
from django.core.urlresolvers import reverse

from users.models import UserTicketModel


class UserMiddleware(MiddlewareMixin):

    # 请求拦截
    def process_request(self, request):

        # 过滤
        paths = ['/user/login/', '/user/register/']
        for path in paths:
            if re.match(path, request.path):
                return None
        # 验证用户的登录状态 - 获取ticket
        ticket = request.COOKIES.get('ticket')
        # 如果没有ticket，则直接跳转到登录
        if not ticket:
            return HttpResponseRedirect(reverse('user:login'))
        # 通过ticket获取user
        user = UserTicketModel.objects.filter(ticket=ticket).first()
        if not user:
            return HttpResponseRedirect(reverse('user:login'))
        # 判断过期时间
        if user.out_time.replace(tzinfo=None) < datetime.now():
            user.delete()
            return HttpResponseRedirect(reverse('user:login'))
        # 没有过期, 中间件赋值
        request.user = user.user
```

随机cookie

```
import random

def get_ticket():
    s='sadsafsdfgsauhdfuewhwquhuh12eweadswe334'
    ticket=''
    for i in range(25):
        ticket+=random.choice(s)
    return ticket
```

# 5.Django自带登录、注册、注销

注册

```
def register(request):
    if request.method.lower() == 'get':
        return render(request, 'register.html', {})

    if request.method.lower() == 'post':
        username = request.POST.get('username')
        password = request.POST.get('password1')
        password2 = request.POST.get('password2')
        if password == password2:
            User.objects.create_user(username=username, password=password)
        else:
            msg = '两次密码不一样'
            return render(request, 'register.html', {'msg': msg})
        return HttpResponseRedirect(reverse('a:login'))
```

登录

```
def login(request):
    if request.method == 'GET':
        return render(request, 'login.html', {})
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = auth.authenticate(username=username, password=password)
        if user:
            auth.login(request, user)
            return HttpResponseRedirect(reverse('a:index'))
        else:
            return render(request, 'login.html')
```

注销

```
def logout(request):
    if request.method == 'GET':
        auth.logout(request)
        return HttpResponseRedirect(reverse('a:login'))
```

