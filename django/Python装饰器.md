# Python装饰器作用：

用于拓展原来函数功能的一种函数，这个函数的特殊之处在于它的返回值也是一个函数，使用python装饰器的好处就是在不用更改原函数的代码前提下给函数增加新的功能。 

# 装饰器结构：

函数+实参高阶函数+返回值高阶函数+嵌套函数+语法糖 = 装饰器 

```
def fn(func): #函数
	def fna(*args): #实参高阶函数
		# 这里可以嵌套函数，加语法糖
		func(*args)
		# 这里也可以嵌套函数，加语法糖
	return fna #返回实参高阶函数
```

# 为什么要用装饰器：

一般而言，我们要想拓展原来函数代码，最直接的办法就是侵入代码里面修改，例如： 

```
import time
def func():
print("hello")
time.sleep(1)
print("world")
```

上面是最原始的的一个函数，然后我们试图记录下这个函数执行的总时间，那最简单的做法就是： 

```
#原始侵入，篡改原函数
import time
def func():
    startTime = time.time()

    print("hello")
    time.sleep(1)
    print("world")
    endTime = time.time()

    msecs = (endTime - startTime)*1000
    print("time is %d ms" %msecs)
```

但是如果你的Boss在公司里面和你说：“小牟，这段代码是我们公司的核心代码，你不能直接去改我们的核心代码。”那该怎么办呢，我们仿照装饰器先自己试着写一下： 

```
#避免直接侵入原函数修改，但是生效需要再次执行函数
import time

def deco(func):
    startTime = time.time()
    func()
    endTime = time.time()
    msecs = (endTime - startTime)*1000
    print("time is %d ms" %msecs)


def func():
    print("hello")
    time.sleep(1)
    print("world")

deco(func)
```

这里我们定义了一个函数deco，它的参数是一个函数，然后给这个函数嵌入了计时功能。然后你可以拍着胸脯对老板说，看吧，不用动你原来的代码，我照样拓展了它的函数功能。  然后你的老板又对你说：“小王，我们公司核心代码区域有一千万个func()函数，从func01()到func1kw(),按你的方案，想要拓展这一千万个函数功能，就是要执行一千万次deco()函数，这可不行呀，我心疼我的机器。”  好了，你终于受够你老板了，准备辞职了，然后你无意间听到了装饰器这个神器，突然发现能满足你闫博士的要求了。  我们先实现一个最简陋的装饰器，不使用任何语法糖和高级语法，看看装饰器最原始的面貌： 

```
#既不需要侵入，也不需要函数重复执行
import time

def deco(func):
    def wrapper():
        startTime = time.time()
        func()
        endTime = time.time()
        msecs = (endTime - startTime)*1000
        print("time is %d ms" %msecs)
    return wrapper


@deco
def func():
    print("hello")
    time.sleep(1)
    print("world")

func()
```

这里的deco函数就是最原始的装饰器，它的参数是一个函数，然后返回值也是一个函数。其中作为参数的这个函数func()就在返回函数wrapper()的内部执行。然后在函数func()前面加上@deco，func()函数就相当于被注入了计时功能，现在只要调用func()，它就已经变身为“新的功能更多”的函数了。  所以这里装饰器就像一个注入符号：有了它，拓展了原来函数的功能既不需要侵入函数内更改代码，也不需要重复执行原函数。 

```
#带有参数的装饰器
import time

def deco(func):
    def wrapper(a,b):
        startTime = time.time()
        func(a,b)
        endTime = time.time()
        msecs = (endTime - startTime)*1000
        print("time is %d ms" %msecs)
    return wrapper


@deco
def func(a,b):
    print("hello，here is a func for add :")
    time.sleep(1)
    print("result is %d" %(a+b))

func(3,4)
```

然后你满足了Boss的要求后，Boss又说：“小牟，我让你拓展的函数好多可是有参数的呀，有的参数还是个数不定的那种，你的装饰器搞的定不？”然后你嘿嘿一笑，深藏功与名！ 

```
#带有不定参数的装饰器
import time

def deco(func):
    def wrapper(*args, **kwargs):
        startTime = time.time()
        func(*args, **kwargs)
        endTime = time.time()
        msecs = (endTime - startTime)*1000
        print("time is %d ms" %msecs)
    return wrapper


@deco
def func(a,b):
    print("hello，here is a func for add :")
    time.sleep(1)
    print("result is %d" %(a+b))

@deco
def func2(a,b,c):
    print("hello，here is a func for add :")
    time.sleep(1)
    print("result is %d" %(a+b+c))

func(1,2)
func2(1,2,3)
```

最后，你的老板说：“可以的，小牟，我这里一个函数需要加入很多功能，一个装饰器怕是搞不定，装饰器能支持多个嘛”  最后你就把这段代码丢给了他： 

```
#多个装饰器

import time

def deco01(func):
    def wrapper(*args, **kwargs):
        print("this is deco01")
        startTime = time.time()
        func(*args, **kwargs)
        endTime = time.time()
        msecs = (endTime - startTime)*1000
        print("time is %d ms" %msecs)
        print("deco01 end here")
    return wrapper

def deco02(func):
    def wrapper(*args, **kwargs):
        print("this is deco02")
        func(*args, **kwargs)

        print("deco02 end here")
    return wrapper

@deco01
@deco02
def func(a,b):
    print("hello，here is a func for add :")
    time.sleep(1)
    print("result is %d" %(a+b))

func(3,4)

'''
this is deco01
this is deco02
hello，here is a func for add :
result is 7
deco02 end here
time is 1003 ms
deco01 end here
'''
```

多个装饰器执行的顺序就是从最后一个装饰器开始，执行到第一个装饰器，再执行函数本身。 

下面是一个例子：

```
def dec1(func):  
    print("1111")  
    def one():  
        print("2222")  
        func()  
        print("3333")  
    return one  

def dec2(func):  
    print("aaaa")  
    def two():  
        print("bbbb")  
        func()  
        print("cccc")  
    return two  

@dec1  
@dec2  
def test():  
    print("test test")  

test()  

'''
aaaa  
1111  
2222  
bbbb  
test test  
cccc  
3333
'''
```

