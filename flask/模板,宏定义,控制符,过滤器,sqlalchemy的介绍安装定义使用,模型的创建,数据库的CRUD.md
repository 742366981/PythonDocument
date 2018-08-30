##### 引入宏定义macro ( index.html) ：

```
提炼公共文件
{% from 'functions.html' import hello %}

{% extends 'base.html' %}

{% block title %}
我是index
{% endblock %}

{% block content %}

    <!--宏定义 公共页面 hello()定义一个函数 <h3>自定义函数内容 {{id}}与参数相关的内容用{{}}占位-->
    {% macro hello(id) %}
        <h3>你好, Python!{{id}}</h3>
    {% endmacro %}

    <!--调用函数 以下多次调用 *3 表示调用的次数 - 例如俄罗斯方块项目则会用到-->
    {{ hello(2)*3 }}
    {{ hello(2) }}
    {{ hello(2) }}
    {{ hello(2) }}

{% endblock %}

```

##### 与py文件挂钩的H5页面注释需要加{#  #} functions.html :

```
<!--{# 宏定义 公共页面 hello()定义一个函数 <h3>自定义函数内容 {{id}}与参数相关的内容用{{}}占位 #}-->

{% macro hello() %}
    <h3>你好, Python!</h3>
{% endmacro %}

{% macro show_goods(id, name, price) %}
    <h4>id: {{ id }}, 商品名称: {{ name }}, 价格: {{ price }}</h4>
{% endmacro %}

```

##### 循环 for / if  (index.html) :

```
<!-- 偶数展示为红色, 奇数展示为绿色 -->
    <br>
    {% for i in list1 %}
        {% if i%2 == 0 %}
            <p style="color: red;">{{ i }}</p>
        {% else %}
            <p style="color: green;">{{ i }}</p>
        {% endif %}
    {% endfor %}
<br>

for : 
    {% for i in list1 %}
        {{ i }}
    {% endfor %}
    
if :
	ifequal 在jinja中没有
	{% if i == 1 %}
	
	{% else %}
	
	{% endif %}
	

```

##### loop 控制符(index.html) :

```
<!-- 第一个参数展示为红色, 最后一个参数展示为绿色 -->

    {% for i in list1 %}
        <!-- loop.index/first/last打印循环次数, 从1开始 -->
        {{ loop.index }}
        {% if loop.first %}
            <p style="color: red;">{{ i }}</p>
        {% endif %}
        {% if loop.last %}
            <p style="color: green;">{{ i }}</p>
        {% endif %}
        <br>
    {% endfor %}
    
loop :
	forloop.counter : 的值是一个整数，表示循环的次数。这个属性的值从 1 开始，因此第一次循环时，
forloop.counter 等于 1 
	forloop.counter0 : 与 forloop.counter 类似，不过是从零开始的。第一次循环时，其值为 0
	forloop.revconter : 的值是一个整数，表示循环中剩余的元素数量。第一次循环时， for-
loop.revcounter 的值是序列中要遍历的元素总数。最后一次循环时， forloop.revcounter 的值为 1
	forloop.revconter0 : 与 forloop.revcounter 类似，不过索引是基于零的。第一次循环时， for-
loop.revcounter0 的值是序列中元素数量减去一。最后一次循环时， forloop.revcounter0 的值为 0
	
序号 : loop.index
反转 : loop.revindex

 loop.index 当前迭代的索引，从1开始算

 loop.index0 当前迭代的索引，从0开始算

 loop.revindex 相 对于序列末尾的索引，从1开始算

 loop.revindex0 相对于序列末尾的索引，从0开始算

 loop.first 相 当于 loop.index == 1.

 loop.last 相当于 loop.index == len(seq) - 1

第一次 : loop.first
最后一次 : loop/last
```

##### 过滤器  index.html :

```
  <br>
    {% for f in config %}
        <!--变小写-->
        {{ f|lower|capitalize|length }}
        <br>
    {% endfor %}
    
safe : 将标签渲染出来
stripags : 将标签去掉
length : 计算长度
capitalize : 首字母大写
lower : 单词变为小写
upper : 单词变为大写
```

##### flask模型  (ORM - CRUD - 写原生SQL) : 

django model.objects.raw(select * from ) : Django中执行原生SQL语句

makefile : 安装文件

##### 安装驱动 :

```
在requeirement中 - re_install.txt文件中添加 : pymysql / flask-sqlalchemy
 -r : 表示递归 , 后边跟文件
Terminal 中 : cd requeirement 路径下 : pip install -r re_install.txt 进行安装

单独安装 :
	pip install flask-sqlalchemy
	pip install pymysql
```

#### SQLALchemy配置 :

##### 第一步 : 定义模型 :

使用SQLALchemy的对象去创建字段

其中__tablename__指定创建的数据库的名称

```
其中：

Integer表示创建的s_id字段的类型为整形，

primary_key表示是否为主键

String表示该字段为字符串

unique表示该字段唯一

default表示默认值

autoincrement表示是否自增
	
创建models.py文件，其中定义模型

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy() # 获取对象


class Student(db.Model):

	# 通过db定义字段 - db是一个模块
    s_id = db.Column(db.Integer, primary_key=True, autoincrement=True)  # int类型id,手动定义主键primary_key,自增autoincrement, nullable = Ttue为空
    s_name = db.Column(db.String(16), unique=True)
    s_age = db.Column(db.Integer, default=1)

    __tablename__ = "student"   # 数据库对应表名称
```

##### 第二步 : 初始化db和app  -- manage.py :

```
from app.models import db

db.init_app(app)  # 将对象与app进行绑定
```

##### 第三步 : 马上配置数据库 :

```
app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:123456@localhost:3306/flask3"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
```

##### 第四步 : 创建表 在flask3里  -  db.create_all()方法  --  views.py  创建模型:

```
from app.models import db

@app_blue.route('/create_db/', methods=['GET'])
def create_db():
    # 实现功能 - create_all 创建数据库中的表
    db.create_all()
    return '创建数据库'
```

##### 第五步 navicat中 :

```
新建数据库, 与模型中数据库名称同步
访问http://127.0.0.1:8080/app/create_db/
数据库中建表成功 
```

##### 删除数据库 : (最好不要使用这个)

```
@app_blue.route('/drop_db/', methods=['GET'])
def drop_db():
    db.drop_db()
    return '删除数据库'
```

#### CRUD ( 增 删 该 查 ) :

```
增 :
    db.session.add(stu)  # 添加修改信息
    db.session.commit()  # 提交到数据库
```

##### 创建数据  POST (views.py) :

```
# 创建数据
@app_blue.route('/create_stu/', methods=['POST', 'GET'])
def create_stu():
    if request.method == 'GET':
        return render_template('addstu.html')
    else:
        # 接收参数
        s_name = request.form.get('s_name')
        s_age = request.form.get('s_age')

        # 创建信息 - 当做参数传进来 / # Student.query.all()  查询所有
        # 给student赋值
        stu = Student()
        stu.s_name = s_name
        stu.s_age = s_age
        stu.s_create_time = datetime.now()

        db.session.add(stu)  # 添加修改信息
        db.session.commit()  # 提交到数据库
        return '创建数据成功'
```

##### 创建添加学生页面(addstu.html) :

```

{% extends 'base.html' %}

{% block content %}
    <form action="" method="post">
        姓名: <input type="text" name="s_name">
        <br>
        年龄: <input type="text" name="s_age">
        <br>
        <input type="submit" value="提交">
    </form>
{% endblock %}
```

```
查 :
	模型.query.all() ---> list
	模型.query.filter(模型.字段==字段值) ---> basequery
	模型.query.filter(模型.字段==字段值).all() ---> list
	
	模型.query.filter_by(字段=字段值)
```

##### 查询学生信息   GET (views.py) :

```
# 查询学生信息
@app_blue.route('/selstu/', methods=['GET'])
def sel_stu():
    # 查所有 - 返回数据显示列表
    stus = Student.query.all()
    return render_template('stus.html', stus=stus)
```

##### 创建学生页面(stus.html) :

```

{% extends 'base.html' %}

{% block content %}

    <table>
        <tr>
            <th>姓名</th>
            <th>年龄</th>
        </tr>
        {% for stu in stus %}
            <tr>
                <td>{{ stu.s_name }}</td>
                <td>{{ stu.s_age }}</td>
            </tr>
        {% endfor %}
    </table>

{% endblock %}
```

##### 查询详情  GET (views.py):

```
# 查询详情
@app_blue.route('/detailstu/<int:id>/', methods=['GET'])
def detail_stu(id):

    # filter过滤
    stu = Student.query.filter(Student.id == id)
    # filter_by过滤
    stu = Student.query.filter_by(id=id)
    # get, 获取不到数据不报错
    # stu = Student.query.get(id)

    return render_template('stus.html', stus=stu)
```

天天生鲜 : 后台用flask做

PC端用django

##### 删除  DELETE  (views.py): 

```
删 :
	db.session.delete(对象)
	db.session.commit()
```

```
# 删除
@app_blue.route('/del_stu/<int:id>/', methods=['DELETE'])
def del_stu(id):
    stu = Student.query.get(id)
    # stu.delete()  -- django写法
    db.session.delete(stu)
    db.session.commit()
    return '删除成功'
```

##### 改摸一个数据  PATCH (views.py) :

```
改 :
	对象 = 模型.query.get(id)
	对象.字段 == 字段值
	
	db.session.add(对象)
	db.session.commit()
	
	模型.query.filter().update({":"})
	db.session.commit()
	
```

```
@app_blue.route('/update_stu/<int:id>/', methods=['PATCH'])
def update_stu(id):

    # form获取用户名 - 请求参数从form中获取得到
    s_name = request.form.get('s_name')
    # 第一种修改方式
    # stu = Student.query.get(id)
    # stu.s_name = s_name

    # 第二种修改方式
    Student.query.filter_by(id=id).update({'s_name': s_name})
    Student.query.filter(Student.id == id).update({'s_name': s_name})
    # db.session.add(stu)
    db.session.commit()
    return '修改数据成功'
```

