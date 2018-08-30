##### flask反向解析 : manage.py 

```

from flask import Flask
from flask_script import Manager

from app.views import app_blue

app = Flask(__name__)
# 注册蓝图
app.register_blueprint(app_blue, url_prefix='/app')

manager = Manager(app)


if __name__ == '__main__':
    manager.run()

# 以上为启动文件

```

##### 蓝图参数的使用 : views.py

```

from flask import Blueprint, redirect, url_for

# 实例化蓝图
app_blue = Blueprint('first', __name__)


@app_blue.route('/')
def hello():
    return 'hello 美女! '


# 定义一个方法实现跳转
@app_blue.route('/getRedirect/')
def get_redirect():

    # 跳转到第一个方法, 第一种跳转, 地址固定
    # return redirect('/app/')
    # first为蓝图第一个参数, hello为函数名
    # 使用反向解析, url_for('初始化蓝图的第一个参数.函数名')
    return redirect(url_for('first.hello'))
```

##### 抛出一个异常 : 

```
from flask import Blueprint, redirect, url_for, abort

# 异常处理
abort(400)
errorhandler(400)

# 获取错误
@app_blue.route('/getError')
def get_error():
    # 捕获异常
    try:
        # 3除以0, 一定报错
        3/0
    except Exception as e:
        # 抛出一个错误
        abort(400)

    return '计算'


# 接收错误
@app_blue.errorhandler(400)
def handler(exception):
	# 返回错误的400页面 - 指定异常
    return '捕获的异常: %s' % exception
```

##### 前言 :

访问者的标识问题服务器需要识别来自同一访问者的请求。这主要是通过浏览器的cookie实现的。 访问者在第一次访问服务器时，服务器在其cookie中设置一个唯一的ID号——会话ID(session)。 这样，访问者后续对服务器的访问头中将自动包含该信息，服务器通过这个ID号，即可区 隔不同的访问者。 

```
我访问这个网址 - 怎么知道访问者是谁呢? - flask框架中访问服务器 - 就会去标识这个人的身份 - 访问者第一访问服务器时 - 就会记录访问者信息 - 第二次访问时机会区分访问者的身份信息

例如 : 京东商城 - 没登录 - 商品加入购物车 - 购物车中有数据 - 结算 - 不知道登录购物车的用户信息 - 清除浏览器缓存信息(清空Cookie) - 再访问购物车 - 变空

京东商城 - 登录状态 - 加入购物车 - 清空缓存(Cookie) - 用户需重新登录 - 登陆过后 - 购物车商品仍然存在 

分享实现结果 : Cookie中有一个唯一标识符sessionid值
cookie与session有关联关系
京东再次访问时 - 区分你是谁 - 下次访问时 - 通过cookie信息去区分用户信息(保存商品id)

浏览器 : 购物车 - cookies中存用户信息 - 加sessionid值

服务端 : 存sessionid值 

浏览器与服务端同步sessionid值,cookie中购物车信息同步到服务端用户的购物车信息

王老师总结(购物车实现) :
	第一次访问网站 :
		cookies中存sessionid值, 服务器也保存相同的session值
	没登录的情况 :
		购物车中的商品数据, 在清空cookie的时候会被清除
	登录清空 :
		服务端登录用户后, 立马知道sessionid值, 可以通过cookies中的sessionid值知道购物车保存的商品信息
```

##### Cookie : 



##### 安装session与redis :

```
新建一个文件夹 : requeirement
在requeirement文件夹中建一个文件 : re_install.txt
	其中放入我们需要安装的包 :
		flask
		flask-script
		flask-blueprint
		flask-session
		redis
(flaskenv3)workspace/projects/flask02/requeirement> pip install -r re_install.txt
这样直接安装文件 - 就可以安装我们所需要安装的包
```

http://flask.pocoo.org/extensions/

##### session的用法(从哪里导入) : 

定义一个登陆的方法，post请求获取到username，直接写入到redis中，并且在页面中展示出redis中的username 

需要先启动redis，开启redis-server，使用redis-cli进入客户端 

##### 定义方法  :

```
# session用法 - 普通的字典
@app_blue.route('/login/', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        # 第一次访问判断session中是否有值
        username = request.form.get('username')
        return render_template('login.html', username=username)

    if request.method == 'POST':
        username = request.form.get('username')
        # session中存入username
        session['username'] = username
        return redirect(url_for('first.login'))
        
```

##### 定义模板 :

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>login</title>
</head>
<body>
<form action="" method="post">
    姓名: <input type="text" name="username">
    <input type="submit" value="提交">
</form>
</body>
</html>
```

##### redis数据 :

注意：我们在定义app.config的时候指定了SESSION_KEY_PREFIX为flask，表示存在session中的key都会加一个前缀名flask 

##### cookie与session的联系 :

访问者在第一次访问服务器时，服务器在其cookie中设置一个唯一的ID号——会话ID(session)。 这样，访问者后续对服务器的访问头中将自动包含该信息，服务器通过这个ID号，即可区 隔不同的访问者。然后根据不同的访问者来获取其中保存的value值信息。 

session应用场景 : 登录

##### 简单装饰器app应用同级目录下创建一个utils文件夹,其中创建一个function.py文件 :

```

from functools import wraps
from flask import session, redirect, url_for


# 装饰器 - @wraps装饰函数(func)让装饰器保持原有调用函数的特性
def is_login(func):
    @wraps(func)
    def check_login(*args, **kwargs):
        if 'user_id' in session:
            # func 接收参数 *args, **kwargs 代表元组和列表 - 定义函数传参
            return func(*args, **kwargs)
        else:
            return redirect(url_for('first.new_login'))

    return check_login

```

#####  Python 中实现装饰器时使用 @functools.wraps 的理由 :

Python 中使用装饰器对在运行期对函数进行一些外部功能的扩展。但是在使用过程中，由于装饰器的加入导致解释器认为函数本身发生了改变，在某些情况下——比如测试时——会导致一些问题。Python 通过 `functool.wraps` 为我们解决了这个问题：在编写装饰器时，在实现前加入 `@functools.wraps(func)` 可以保证装饰器不会对被装饰函数造成影响。比如，在 Flask 中，我们要自己重写 `login_required` 装饰器，但不想影响被装饰器装饰的方法，则 `login_required` 装饰器本身可以写成下面的样子： 

```
def login_required_(func):
    @wraps(func)
    def decorated_view(*args, **kwargs):
        if current_app.login_manager._login_disabled:
            return func(*args, **kwargs)
        elif not current_user.is_authenticated:
            # return current_app.login_manager.unauthorized()
            return redirect(url_for("login.loginPage", next=request.url))
        return func(*args, **kwargs)

    return decorated_view
```

##### 模板语法 主要分为两种 (变量和标签) :

```
模板中的变量：{{ var }} 
	
    视图传递给模板的数据

    前面定义出来的数据

    变量不存在，默认忽略	
    
模板中的标签：{% tag %}

    控制逻辑

    使用外部表达式

    创建变量

    宏定义
```

##### 结构标签 :

```
block 块操作 : 父模板挖坑, 子模板填坑
	{% block xxx %}

	{% endblock %}
	
extends
	{% extends ‘xxx.html’ %}

    继承以后保留块中的内容
    {{ super() }}
    
挖坑继承体现的化整为零的操作
macro : 宏定义，可以在模板中定义函数，在其他地方调用
	{% macro hello(name) %}

            你好，{{ name }}

    {% endmacro %}
    
    #调用函数
    {{ hello() }}

宏定义可导入
	
	{% from '文件名.html' import 函数 %}
	
宏定义中没有ifequal，由if来代替
{% for i in list %}
	{{i}}
	{% if i == 1 %}
	美女
	{% endif %}
```

##### 定义基础模板base.html 挖坑, 填坑 :

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>
        {% block title %}
        {% endblock %}
    </title>
    {% block extCSS %}
    {% endblock %}
</head>
<body>
{% block content %}
{% endblock %}

{% block extJS %}
{% endblock %}
</body>
</html>
```

##### index.html 继承base.html模板 :

```
{% extends 'base.html' %}

{% block title %}
我是index
{% endblock %}

{% block content %}

<!--宏定义公共页面: hello()定义一个函数 / <h3>自定义函数内容 / {{id}}表示与参数相关的内容用{{}}占位-->

{% macro hello(id) %}
    <h3>你好, Python!{{id}}</h3>
{% endmacro %}

<!--调用函数-->
{{ hello(2) }}

{% endblock %}

```

##### 参数类型 : 位置参数 / 默认参数 (一定放在最后面) :

```
# x为位置参数, *和**表示参数不定, *args储存元组参数, **kwargs储存字典参数 - 按照位置参数顺序排位

def fn_args(x, *args):
    print(x)
    print(args)


fn_args(1, 2, 3)  # 除了1以外, 其他的参数的传值以元组的方式都传给了args


def fn_kwargs(x, **kwargs):
    print(x)
    print(kwargs)


fn_kwargs(1, a=1, b=2, c=3)  # 除了1以外, 其他的参数的传值以字典的方式都传给了kwargs


def fn_args_kwargs(x, *args, **kwargs):
    print(x)
    print(args)
    print(kwargs)


fn_args_kwargs(1, 2, 3, a=1, b=2, c=3)  # 1传给x, 2,3以元组的方式传给args, a=1, b=2, c=3以字典的形式传给了kwargs


此程序运行结果 : 
1
(2, 3)
1
{'a': 1, 'b': 2, 'c': 3}
1
(2, 3)
{'a': 1, 'b': 2, 'c': 3}

```

##### 静态文件信息配置 :

```
django :
第一种方式 :
    {% load static %}
    <link rel="stylesheet" href="{% static 'css/index.css' %}">
第二种方式：
	<link rel="stylesheet" href="/static/css/index.css">
	
flask :
第一种方式：
	<link rel="stylesheet" href="/static/css/index.css">
第二种方式：
	<link rel="stylesheet" href="{{ url_for('static', filename='css/index.css') }}">
```

