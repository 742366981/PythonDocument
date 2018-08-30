##### manage.py 结构顺序  -- 顺序不对不会报错,但程序运行会报错 :

```

from flask import Flask
from flask_script import Manager
from flask_session import Session

import redis

from app.views import app_blue

from app.models import db

app = Flask(__name__)
# 注册蓝图
app.register_blueprint(app_blue, url_prefix='/app')

# session的配置
# 指定session服务
app.config['SESSION_TYPE'] = 'redis'
# 指定session IP与端口
app.config['SESSION_REDIS'] = redis.Redis(host='127.0.0.1', port=6379)

# 配置数据库
app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:123456@localhost:3306/flask3"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


# 第一种初始化 app对象
se = Session()
se.init_app(app)
# 第二种初始化 app传进去
# Session(app=app)

db.init_app(app)  # 将对象与app进行绑定

manager = Manager(app)


if __name__ == '__main__':
    manager.run()

# 以上为启动文件

```

##### 初始化 :

```
__init__ : 对对象初始化 -- 先有对象才初始化

__new__ : 先创建对象 先new再init

__del__ : 析构
```

##### 使用使用SQL : 

```
# 使用SQL
@app_blue.route('/sel_stu_by_sql/', methods=['GET'])
def sel_stu_by_sql():
    # 查询SQL
    sql = 'select * from student;'
    # 执行SQL
    db.session.execute(sql)
    return '查询sql语句'
```

##### 批量创建 : 

```
# 批量创建
@app_blue.route('/create_many_stu/', methods=['POST'])
def create_many_stu():
    # 定义列表
    stu_list = []
    # 循环
    for i in range(10):
        # 实例化Student的对象
        stu = Student()
        # 给对象的属性赋值
        stu.s_name = '大可爱%s' % i
        stu.s_age = random.randrange(20)
        stu.s_create_time = datetime.now()
        stu_list.append(stu)

    #     db.session.add(stu)
    # db.session.commit()

    # 添加需要创建的数据
    db.session.add_all(stu_list)
    # 提交事务到数据库
    db.session.commit()

    return '批量创建成功'
```

##### 创建初始化对象, save_update()方法 : 

##### models.py :

```
 # 初始化
    def __init__(self, name, age):
        self.s_name = name
        self.s_age = age
        self.s_create_time = datetime.now()

    # 定义safe_update方法
    def save_update(self):
        db.session.add(self)
        db.session.commit()
```

##### views.py :

```
# 创建初始化对象
@app_blue.route('/create_init__stu/', methods=['POST'])
def create_init__stu():
    for i in range(3):
        # 获取对象信息
        stu = Student('喵咪%s' % i, i)
        stu.save_update()
    return '批量创建成功'

```

##### 操作符 :

```
获取查询集 : 
    filter(类名.属性名.运算符('')
    filter(类名.属性 数学运算符 值)
    
运算符 :
	contains： 包含
    startswith：以什么开始
    endswith：以什么结束
    in_：在范围内
    like：模糊
    __gt__: 大于
    __ge__：大于等于
    __lt__：小于
    __le__：小于等于
	
筛选 :
	offset()

    limit()

    order_by()

    get()

    first()

    paginate()

逻辑运算 : 

	与
	and_
	filter(and_(条件),条件…)

    或
        or_
        filter(or_(条件),条件…)

    非
        not_
        filter(not_(条件),条件…)

```

##### 查询语句 :

```
SELECT student.id AS student_id, student.s_name AS student_s_name, student.s_age AS student_s_age, student.s_create_time AS student_s_create_time 
FROM student 
WHERE (student.s_name LIKE concat(concat('%%', %(s_name_1)s), '%%'))
```

##### 查询  views.py :

```
# 查询
@app_blue.route('/sel_stu_by_filter/', methods=['GET'])
def sel_stu_by_filter():
    # 查询学生名字中包含'可爱'的学生
    stus = Student.query.filter(Student.s_name.contains('可爱'))
    # 查询id是 (5, 6, 7, 8, 9)的学生
    stus = Student.query.filter(Student.id.in_([5, 6, 7, 8, 9]))
    # 查询年龄小于13的学生
    # < 数学运算符
    # __lt__ 运算符
    stus = Student.query.filter(Student.s_age < 13)
    stus = Student.query.filter(Student.s_age.__lt__(13))
    # 查询学生姓名以0结束的学生
    stus = Student.query.filter(Student.s_name.endswith('0'))
    stus = Student.query.filter(Student.s_name.like('%0%'))

    # 模糊查询学生姓名, 学生姓名第二位叫'溪'的学生 用like
    # _ 表示占一个位
    stus = Student.query.filter(Student.s_name.like('%_溪%'))
    # 查询结果按照id降序
    stus = Student.query.order_by('id')
    stus = Student.query.order_by('id asc')
    stus = Student.query.order_by('-id')
    stus = Student.query.order_by('id desc')

    # 查询结果按照id升序, 取5个
    stus = Student.query.order_by('id').limit('5')
    
     # 查询姓名包含可爱, 并且年龄12的学生
    stus = Student.query.filter(Student.s_name.contains('可爱'),
                                Student.s_age == 12)
    stus = Student.query.filter(and_(Student.s_name.contains('可爱'),
                                Student.s_age == 12))
    # 查询姓名包含可爱, 或者年龄12的学生
    stus = Student.query.filter(or_(Student.s_name.contains('可爱'),
                                     Student.s_age == 12))
    # 查询姓名不包含可爱, 并且年龄不等于12的学生
    # not_只能一个条件
    stus = Student.query.filter(not_(Student.s_name.contains('可爱')),
                                    not_(Student.s_age == 12))

    print(stus)
    return '查询成功'
```

面试 : 是否用过django权限 :  没用过 - 业务逻辑有局限性 - 不满足业务需求 - 不适合公司业务 - 贵公司使用过这个吗?

元组修改值 - 打印元组的结果 - 题有问题的 - 元组不可修改

##### 分页 stus = Student.query.all()返回一个列表进行切片:

```
# 查询学生信息
@app_blue.route('/selstu/', methods=['GET'])
def sel_stu():
    # 查所有 - 返回数据显示列表
    # stus = Student.query.all()

    # 方法一 : 手动实现分页, 使用offset和limit方法
    # 拿到页面的每一页
    page = int(request.args.get('page', 1))
    # stus = Student.query.offset((page-1)*5).limit(5)

    # 方法二 : 使用切片[:]
    # s_page = (page - 1)*5
    # e_page = page * 5
    # stus = Student.query.all()[s_page, e_page]

    # 方法三 :
    # 获取每一页的信息
    paginate = Student.query.paginate(page, 10, error_out=False)
    # items 当前页面中的记录
    stus = paginate.items
    return render_template('stus.html', stus=stus, paginate=paginate)

```

##### 学生页面  stus.html :

```


{% extends 'base.html' %}

{% block content %}

    <table>
        <tr>
            <th>ID</th>
            <th>姓名</th>
            <th>年龄</th>
            <th>班级</th>
            <th>操作</th>
        </tr>
        {% for stu in stus %}
            <tr>
                <td>{{ stu.id }}</td>
                <td>{{ stu.s_name }}</td>
                <td>{{ stu.s_age }}</td>
                <td>{{ stu.grade.g_name }}</td>
                <td>
                    <a href="/app/stu_add_grade/{{ stu.id }}">添加班级</a>
                </td>
            </tr>
        {% endfor %}

    </table>
        总页数: {{ paginate.pages }}
        <!--上一页-->
        {% if paginate.has_prev %}
            <a href="/app/selstu/?page={{ paginate.prev_num }}">上一页</a>
        {% endif %}
        <!--页码-->
        {% for i in paginate.iter_pages() %}
            <a href="/app/selstu/?page={{ i }}">{{ i }}</a>
        {% endfor %}
        <!--下一页-->
        {% if paginate.has_next %}
                <a href="/app/selstu/?page={{ paginate.next_num }}">下一页</a>
        {% endif %}
        当前页数: {{ paginate.page }}

{% endblock %}
```

##### Django 与 Flask 的区别 :

```
1.jinja2和DjangoTemplates模板引擎相比, jinja2优点语法更简单
比如 : loop.index 和 forloop.counter
	  loop.revindex 和 forloop.revcounter
	  jinja2中没有ifequal

2.框架区别 :
	Django : 缺点 : 大而全, 但是耦合性高, Auth, Permission, Admin基本没用
			优点 : 开发快, MVC模式定义好了
	Flask : 优点 : 微框架 , 很小巧(七行代码), 需要哪些功能, 自己装
			需要熟悉MVC模式, 
			
3.模型

Django中创建数据 :
	
	一对多 :
	
	创建字段 : 模型1: u 字段为 FOREIGN_KEY
			模型1.u = u对象
			模型1.u_id = u对象.id
	模型1查找模型2的数据 :
		模型2对象 = 模型1对象.u
		模型1对象 = 模型2.模型1_set.all()
		
	一对一 :
	
	模型1查找模型2的数据 :
		模型2对象 = 模型1对象.u
		模型1对象 = 模型2.模型1.all()
		
	Flask :
	
		一对多 :
		
		模型1 : u字段为FOREIGN KEY , 关联到模型2
		模型2 : yy字段, 定义relationship字段, backref='uu'
		
		模型1查找模型2 :
			模型2对象 = 模型1对象.uu
			模型1对象 = 模型2对象.yy
		
```

##### 关联关系, 数据模型, 一对多 :

```

from datetime import datetime

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()  # 获取对象


# 定义学生模型 - 为多
class Student(db.Model):
    # 通过db定义字段
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)  # int类型id,手动定义主键,自增
    s_name = db.Column(db.String(10), nullable=False)
    s_age = db.Column(db.Integer, nullable=True)
    s_create_time = db.Column(db.DateTime)
    # 学生关联到班级上去
    g_id = db.Column(db.Integer, db.ForeignKey('grade.id'), nullable=True)

    __tablename__ = 'student'  # 数据库对应表名称

    # 初始化
    def __init__(self, name, age):
        self.s_name = name
        self.s_age = age
        self.s_create_time = datetime.now()

    # 定义safe_update方法
    def save_update(self):
        db.session.add(self)
        db.session.commit()


# 定义班级模型 - 为一
class Grade(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    g_name = db.Column(db.String(10), nullable=False)
    g_create_time = db.Column(db.DateTime, default=datetime.now)
    # 关联关系
    stu = db.relationship('Student', backref='grade', lazy=True)
 
```

##### 添加班级 :

```
# 添加班级
@app_blue.route('/create_grade/', methods=['POST'])
def create_grade():

    g = ['Python', 'JAVA', 'C', 'C++']
    for i in g:
        grade = Grade()
        grade.g_name = i

        db.session.add(grade)
    db.session.commit()
    return '添加班级成功'
```

##### 学生列表中添加班级 :

```
# 学生列表中添加班级
@app_blue.route('/stu_add_grade/<int:id>', methods=['GET', 'POST'])
def stu_add_grade(id):
    # get请求返回页面
    if request.method == 'GET':
        grades = Grade.query.all()
        return render_template('addgrade.html', grades=grades)

    if request.method == 'POST':
        # 获取班级信息
        g_id = request.form.get('g_id')
        # 获取学生信息
        stu = Student.query.get(id)
        stu.g_id = int(g_id)
        stu.save_update()
        return redirect(url_for('first.sel_stu'))
```

##### 添加班级页面  addgrade.html:

```

{% extends 'base.html' %}

{% block content %}

<form action="" method="post">
    {% for grade in grades %}
    <select name="g_id">
        <option value="{{ grade.id }}">{{ grade.g_name }}</option>
    {% endfor %}
    </select>
    <input type="submit" value="提交">
</form>

{% endblock %}
```



