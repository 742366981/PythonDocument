# 使用centos部署django项目

### 安装MariaDB

安装命令

```
yum -y install mariadb mariadb-server
```

安装完成MariaDB，首先启动MariaDB

```
systemctl start mariadb
```

设置开机启动

```
systemctl enable mariadb
```

### 设置密码

命令: mysql_secure_installation

```
Enter current password for root:<–初次运行直接回车

设置密码

Set root password? [Y/n] <– 是否设置root用户密码，输入y并回车或直接回车

New password: <– 设置root用户的密码
Re-enter new password: <– 再输入一次你设置的密码

其他配置（直接回车默认Y）

Remove anonymous users? [Y/n] <– 是否删除匿名用户，回车

Disallow root login remotely? [Y/n] <–是否禁止root远程登录,输入n回车,

Remove test database and access to it? [Y/n] <– 是否删除test数据库，回车

Reload privilege tables now? [Y/n] <– 是否重新加载权限表，回车
```

### 登录MariaDB

```
# 访问数据库
mysql -u root -p
```



### 开启远程连接

在mysql数据库中的user表中可以看到默认是只能本地连接的，所有可以添加一个新的用户，该用户可以远程访问

#### 1. 创建用户

```
# 先使用数据库
use mysql;

# 针对ip
create user 'root'@'输入公网ip' identified by '输入密码';

#全部
 create user 'root'@'%' identified by '输入密码';
```

#### 2. 授权

```
# 给用户最大权限
grant all privileges on *.* to 'root'@'%' identified by '输入密码';

# 给部分权限(test 数据库)

grant all privileges on test.* to 'root'@'%' identified by '输入密码' with grant option;

# 刷新权限表
flush privileges;

# 查看
show grants for 'root'@'localhost';
```

#### 3.删除用户

```
#删除所有
drop user 'root'@'%';
#针对ip
drop user 'root'@'输入公网ip';
```

### 安装python3.6

在centos中，系统默认只提供python2.7的版本，但是项目我们使用的python3.6的版本。所有我们自己安装python3.6。

Linux安装Python3.6.5步骤：  

1. 安装C语言编译和构建工具 

   ```
   yum install gcc
   ```

2. 从官方网站下载Python源代码 

   ```
   wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz  
   ```

3. 解压缩和解归档 

   ```
   gunzip Python-3.6.5.tgz
   (xz -d Python-3.6.5.xz)
   tar -xvf Python-3.6.5.tar  
   ```

4. 进入Python源代码目录，执行配置并生成Makefile（构建文件）

   ```
   cd  Python-3.6.5
   ./configure --prefix=/usr/local/python3 --enable-optimizations
   ```

5. 安装构建过程可能需要使用的依赖库 

   ```
   yum -y install zlib-devel bzip2-devel openssl-devel 
   ncurses-devel sqlite-devel readline-devel tk-devel 
   gdbm-devel db4-devel libpcap-devel xz-devel
   ```

6. 构建和安装

   ```
   make && make install 
   ```

7. 创建软链接（快捷方式） 

   ```
   ln -s /usr/local/python3/bin/python3.6 /usr/bin/python3
   ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
   ln -s /usr/local/python3/bin/2to3-3.6 /usr/bin/2to3
   ```

8. 检查是否安装成功 

   ```
   python3 --version
   ```

9. 更新pip包管理工具

   ```
   python3 -m pip install -U pip
   ```

### 安装环境

#### 1. 创建python虚拟环境

```
python3 -m venv venv
#第一个venv是虚拟环境命令，不能改，第二个venv是给虚拟环境取的名字，可以任意修改
```

#### 2. 激活虚拟环境

```
cd venv
source bin/activate
```

#### 3. 安装环境需要的包

```
pip install -r re_install.txt

其中re_install.txt文件中记录的是需要安装包的名称以及对应的版本
```

注意：进入虚拟环境后无论是python还是pip都不要在后面加数字！

### 部署

该部署采用的是cenots7系统来部署

Django的项目中，在工程目录下settings.py文件中有一个DEBUG=True参数，如果DEBUG=False则会出现js,css，img无法加载的情况出现。

原因如下：

Django框架仅在开发模式下提供静态文件服务。当我开启DEBUG模式时，Django内置的服务器是提供静态文件的服务的，所以css等文件访问都没有问题，但是关闭DEBUG模式后，Django便不提供静态文件服务了。想一想这是符合Django的哲学的：这部分事情标准服务器都很擅长，就让服务器去做吧！

#### 1. 测试环境中部署方式

##### urls.py中的修改

在测试环境中一般都直接使用python manage.py runserver的方式去运行项目。其中就涉及到DEBUG=False的修改，静态目录的修改等，具体修改如下：

```
修改settings.py配置文件中的DEBUG=False模式，修改ALLOEWD_HOST=['*']

修改工程目录下的urls.py

from django.views.static import serve

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^axf/', include('axf.urls', namespace='axf')),

	# 增加以下的url路由
    url(r'^static/(?P<path>.*)$', serve, {"document_root": settings.STATICFILES_DIRS[0]}),
	
	url(r'^media/(?P<path>.*)$', serve, {"document_root": settings.MEDIA_ROOT}),


    url(r'^$', views.home)
]
```

##### 中间件的修改

如果中间件是过滤哪些地址不需要登录验证的话，可以设置如下的static和media过滤地址的参数：

```
# 验证用户的登录状态
paths = ['/user/login/', '/user/register/',
         '/axf/market/', '/axf/marketparams/(\d+)/(\d+)/(\d+)/',
        '/static/[0-9a-zA-Z/\.]', '/media/[0-9a-zA-Z/\.]']

for path in paths:
    if re.match(path, request.path):
        return None
```

##### 运行项目

```
python manage.py runserver 0.0.0.0:80
```

#### 2. 正式环境中部署方式

正式环境中部署为nginx+uwsgi来部署django项目

##### 2.1 安装nginx

a）添加nginx存储库

```
yum install epel-release
```

b) 安装nginx

```
yum install nginx
```

c) 运行nginx

Nginx不会自行启动。要运行Nginx

```
systemctl start nginx
```

nginx的运行命令：

```
 systemctl status nginx 查看nginx的状态
 systemctl start/stop/enable/disable nginx 启动/关闭/设置开机启动/禁止开机启动
```

d）系统启动时启用Nginx

```
systemctl enable nginx
```

e）如果您正在运行防火墙，请运行以下命令以允许HTTP和HTTPS通信：

```
sudo firewall-cmd --permanent --zone=public --add-service=http 

sudo firewall-cmd --permanent --zone=public --add-service=https

sudo firewall-cmd --reload
```

#### 3.配置uwsgi

##### 3.1 安装uwsgi

```
pip3 install uwsgi
```

#### 4. 配置项目代码，配置项目nginx，配置uwsgi.ini等

本案例的配置文件，都习惯将每一个项目的配置文件，日志文件，虚拟环境放在一起，这样开发方便，运维也方便维护。

在home目录创建conf、logs、venv、src这四个文件夹

其中：

conf是配置文件，用于存放项目的nginx.conf文件，uwsgi.ini文件

logs是日志文件，用于存放nginx的启动成功和失败文件，以及uwsgi的运行日志文件

venv是用于存放虚拟环境

src是项目文件，该目录下上传的是目录代码

#### 4.1 配置nginx.conf文件

**首先**：编写自己项目的nginx.conf文件如下：

每一个项目对应有一个自己定义的nginx的配置文件，比如爱鲜蜂项目，我定义为axfnginx.conf文件

```
server {
     listen       80;
     server_name 输入公网ip localhost;

     access_log /home/logs/access.log;
     error_log /home/logs/error.log;

     location / {
         include uwsgi_params;
         uwsgi_pass 127.0.0.1:8890;
     }
     location /static/ {
         alias /home/src/axf/static/;
         expires 30d;
     }

 }
```

**其次**：修改总的nginx的配置文件，让总的nginx文件包含我们自定义的项目的axfnginx.conf文件

总的nginx配置文件在：/etc/nginx/nginx.conf中



以上步骤操作完成以后，需要重启nginx：

```
systemctl restart nginx
```

如果自定义的axfnginx.conf文件没有错误的话，查看nginx的运行状态会有如下的结果：

#### 4.2 配置uwsgi文件

在conf文件夹下除了包含自定义的axfnginx.conf文件，还有我们定义的uwsgi.ini文件

```
[uwsgi]


# 守护进程
master = true

# 进程个数
processes = 4

# 虚拟环境
pythonhome = /home/venv/axfenv

# 项目地址
chdir = /home/src/axf

# 指定python版本
pythonpath = /usr/local/python3/bin/python3.6

# 指定uwsgi文件
module = axf.wsgi

# 和nginx通信地址:端口
socket = 127.0.0.1:8890

# 日志文件地址
logto = /home/logs/uwsgi.log
```

运行项目:

```
uwsgi --ini uwsgi.ini
```