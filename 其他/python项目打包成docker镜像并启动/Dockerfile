#基于的基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/company-bycx/cenos7-py37:latest

#拷贝本地的项目到容器中,后面可以通过进入容器中看的
ADD /local_dir /docker_dir

#设置docker_dir文件夹是工作目录
WORKDIR /docker_dir

#安装支持(requirements.txt是容器中的文件,前面通过ADD命令已拷贝)
RUN pip3 install -r /docker_dir/requirements.txt -i https://pypi.douban.com/simple/

#当容器启动时，使用python3执行指定路径的py脚本
CMD ["python3", "/docker_dir/start_server.py"]

#构建镜像: docker build -t py_app:1 . (py_app为创建的镜像名称,.表示以当前目录的内容生成)