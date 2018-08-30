### 1. 请求request

服务端在接收到客户端的请求后，会自动创建Request对象

由Flask框架创建，Requesy对象不可修改

属性：

```
url：完整的请求地址

base_url：去掉GET参数的url

host_url：只有主机和端口号的url

path：路由中的路径

method：请求方法

remote_addr：请求的客户端的地址

args：GET请求参数

form：POST请求参数

files：文件上传

headers：请求头

cookies：请求中的cookie
```

#### 1.1 args-->GET请求参数包装

a）args是get请求参数的包装，args是一个ImmutableMultiDict对象，类字典结构对象

b）数据存储也是key-value

#### 1.2 form-->POST请求参数包装

a）form是post请求参数的包装，args是一个ImmutableMultiDict对象，类字典结构对象

b）数据存储也是key-value

重点：ImmutableMultiDict是类似字典的数据结构，但是与字典的区别是，可以存在相同的键。

在ImmutableMultiDict中获取数据的方式，dict['key']或者dict.get('key')或者dict.getlist('key')

[![图](https://github.com/coco369/knowledge/raw/master/flask/images/flask_request_form.png)](https://github.com/coco369/knowledge/blob/master/flask/images/flask_request_form.png)

### 2. 响应Response

Response是由开发者自己创建的

创建方法：

```
from flask import make_response

make_response创建一个响应，是一个真正的Response对象
```

状态码：

格式：make_reponse(data，code)，其中data是返回的数据内容，code是状态码

```
a）直接将内容当做make_response的第一个参数，第二个参数直接写返回的状态码

b）直接在render后加返回的状态码
```

例子1：

定义一个获取GET请求的request的方法，并将返回成功的请求的状态码修改为200

```
@blue.route('/getrequest/', methods=['GET'])
def get_request():

    print(request)

    return '获取request', 200
```

例子2：

返回response响应，并添加返回结果的状态码200

```
@blue.route('/getresponse/')
def get_response():
    response = make_response('<h2>我是响应</h2>', 500)
    return response
```

或者：

```
@blue.route('/getresponse/', methods=['GET'])
def get_user_response():
    login_html = render_template('login.html')
    res = make_response(login_html, 200)
    return res
```

### 3. 重定向/反向解析

```
url_for('蓝图定义的名称.方法名')
```

例子1:

定义跳转方法，跳转到get_response的方法上

```
@blue.route('/getredirect/')
def get_redirect():

    return redirect('getresponse')
```

例子2：

使用url_for反向解析

```
from flask import redirect, url_for

@blue.route('/getredirect/')
def get_redirect():

    return redirect(url_for('first.get_response'))
```

### 4. 终止/异常捕获

自动抛出异常：abort(状态码)

捕获异常处理：errorhandler(状态码)，定义的函数中要包含一个参数，用于接收异常信息

#### 4.1 定义终止程序

```
@blue.route('/make_abort/')
def get_abort():
    abort(400)
    return '终止'
```

#### 4.2 捕获定义的异常

```
@blue.errorhandler(400)
def handler(exception):

    return '捕获到异常信息:%s' % exception
```