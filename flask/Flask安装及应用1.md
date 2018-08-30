##### Python的web框架 : 

```
 django(前后分离template,static几乎用不到) 
 Flask 
 Tornado(微服务) 
 web.py / twisted(后端) 
 sanic(性能比flask/tornado快)
```

django商城 : gitHub找项目

##### 爬虫 : 

```
urlib / scrapy / bs / lxml / 验证码, 滑动模块
```

##### 框架之间的区别 : 

```
django的模板引擎 : djangotemplates

flask的模板引擎 : jinja2

模板不一样, 语法也不一样

flask微型项目 : 很灵 - 将model / views/ templates 提炼出来
```

##### 创建Flask项目 :

```
1.Terminal中 : 创建项目文件夹 : cd / workspace/projects : mkdir flask01
2.创建虚拟环境 : cd /workspace/venv : virtaulenv --no-site-packages flaskenv3
3.进入虚拟环境 : File - settings - project interpreter - 选择虚拟环境所在路径 - 选择python.exe文件
```

##### 基于flask的最小的应用 - ⑦行代码 :

##### 创建hello.py文件

```
from flask import Flask

app = Flask(__name__)

@app.route('/')
def gello_world():
	return 'Hello World'

if __name__ == '__main__':

	app.run()
```

##### 运行 Terminal: 

```
Python hello.py
```

##### 初始化 :

```
from flask import Flask

app = Flask(__name__)
```

##### 路由 :

```
@app.route('/')
```

##### 什么是蓝图

在Flask项目中可以用Blueprint(蓝图)实现模块化的应用，使用蓝图可以让应用层次更清晰，开发者更容易去维护和开发项目。蓝图将作用于相同的URL前缀的请求地址，将具有相同前缀的请求都放在一个模块中，这样查找问题，一看路由就很快的可以找到对应的视图，并解决问题了。

##### 使用蓝图

##### 安装 : 虚拟环境的下的项目路径下

```
pip install flask_blueprint
```

##### hello.py :

```

from flask import Flask

from app.views import app_blueprint

# 实例化app
app = Flask(__name__)

# 注册蓝图 - 用app_blueprint找到路由
app.register_blueprint(app_blueprint)


if __name__ == '__main__':

    # run()函数让应用运行在本地服务器上, 添加主机, 指定端口, ctrl + s 后自动重启
    app.run(debug=True, host='127.0.0.1', port=8081)

```

##### views.py :

```

from flask import Blueprint


# 创建蓝图 - 蓝图对象app_blueprint用来管理路由
app_blueprint = Blueprint('first', __name__)


# route路由用来装饰函数 - axf首页,登录注册可以写入这个文件
@app_blueprint.route('/')
# 装饰函数
def hello():
    return "Hello World!"


@app_blueprint.route('/hello')
def hello_u():
    return "Hello %s" % '小明'
```

##### 实力化蓝图应用 :

注意：Blueprint中传入了两个参数，第一个是蓝图的名称，第二个是蓝图所在的包或模块，__name__代表当前模块名或者包名

##### 注册

```
app = Flask(\_\_name\_\_)

app.register_blueprint(blue, url_prefix='/user')
```

注意：第一个参数即我们定义初始化定义的蓝图对象，第二个参数url_prefix表示该蓝图下，所有的url请求必须以/user开始。这样对一个模块的url可以很好的进行统一管理

##### 使用蓝图 : 

修改视图上的装饰器，修改为@blue.router(‘/’) 

```
@blue.route('/', methods=['GET', 'POST'])
def hello():
    # 视图函数
    return 'Hello World'
```

注意：该方法对应的url为127.0.0.1:5000/user/ 

##### 启动命令 :

```
python hello.py runserver
-p 8080 -h 0.0.0.0 -d
```

##### 请求方式定义 :

```
methods = ['GET', 'POST']
```

##### 路由规则:

```
接收参数类型 :
	string : 默认的参数类型 , 可写可不写
	int : 接收整型参数, 必须写
	float : 接收浮点型参数, 必须写
	True : 布尔类型参数可进行加减操作吗 ?
	Flase : 布尔类型参数可进行加减操作吗 ?
	path : 接收路径
	uuid : uid
```

##### 路由对应视图函数 :

```
# 路由请求方式methods=['GET', 'POST', 'PUT']
@app_blueprint.route('/postName/', methods=['GET', 'POST', 'PUT'])
def post_name():
    return '我是post请求'


# <string:name>可接收url传递的字符串 - string参数是默认类型
@app_blueprint.route('/GetName/<string:name>', methods=['GET', 'POST', 'PUT'])
def get_name(name):
    return '我是:%s' % name


# 传入int类型 -  需要指定int类型, 否则默认传入参数类型为str类型
@app_blueprint.route('/get_id/<int:id>')
def get_id(id):
    return '我的年龄: %d' % id


# 接收浮点型参数
@app_blueprint.route('/get_float/<float:fid>')
def get_fid(fid):
    return '浮点数: %.1f' % fid


# 接收路径
@app_blueprint.route('/get_path/<path:path>')
def get_path(path):
    return '路径: %s' % path


# 获取uuid - axf获取订单号
@app_blueprint.route('get_uuid')
def get_uuid():
    uid = uuid.uuid4()
    return 'uid: %s' % uid


@app_blueprint.route('/get_uu/<uuid:uid>')
def get_uu(uid):
    return 'uid :%s' % uid

```

##### 获取请求参数args / form表单 : 服务端传给页面

```
GET : request.args.get('')
POST : request.form.get('')
```

http get请求 最大长度 :

工作问题 : 没办法将get请求变成post请求

洋葱浏览器 : 

日利息 : 

旁氏骗局 : 

linux系统 : Kali linux - 攻击别人网站(渗透)

##### 响应 : 页面传给服务端

```
make_response('<h3></h3>', 200)
```

面试 : 对状态码的理解  (拓展) - code : 200 表示成功

##### 使用Manager

安装

```
pip install flask-script
```

使用

```
from flask import Flask
from flask_script import Manager

from app.views import app_blueprint

app = Flask(__name__)


app.register_blueprint(app_blueprint, url_prefix='/app')
manager = Manager(app)


if __name__ == '__main__':
    manager.run()
```

