Linux安装Python3.6.5步骤：  

1. 安装C语言编译和构建工具 

   yum install gcc  

2. 从官方网站下载Python源代码 

   wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz  

3. 解压缩和解归档 

   gunzip Python-3.6.5.tgz

   (xz -d Python-3.6.5.xz)

   tar -xvf Python-3.6.5.tar  

4. 进入Python源代码目录，执行配置并生成Makefile（构建文件）

   cd  Python-3.6.5

   ./configure --prefix=/usr/local/python3 --enable-optimizations 

5. 安装构建过程可能需要使用的依赖库 

   yum -y install zlib-devel bzip2-devel openssl-devel 

   ncurses-devel sqlite-devel readline-devel tk-devel 

   gdbm-devel db4-devel libpcap-devel xz-devel

6. 构建和安装

   make && make install 

7. 创建软链接（快捷方式） 

   ln -s /usr/local/python3/bin/python3.6 /usr/bin/python3

   ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3

   ln -s /usr/local/python3/bin/2to3-3.6 /usr/bin/2to3

8. 检查是否安装成功 

   python3 --version

9. 更新pip包管理工具

   python3 -m pip install -U pip