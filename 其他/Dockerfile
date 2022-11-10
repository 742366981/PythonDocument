FROM python:3.8.1

WORKDIR /platform-information

ADD ./requirements.txt /platform-information

RUN python3 -m pip install -U pip -i https://pypi.douban.com/simple

RUN pip3 install -r requirements.txt -i https://pypi.douban.com/simple