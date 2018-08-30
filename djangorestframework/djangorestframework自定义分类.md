### **第一种分页PageNumberPagination** 

views.py

```
class MyPageNumberPagination(PageNumberPagination):
    # 每页显示多少个
    page_size = 3
    # 默认每页显示3个，可以通过url传入?page=2&size=4,改变默认每页显示的个数
    page_size_query_param = "size"
    # 最大页数不超过10
    max_page_size = 10
    # 获取页码数的
    page_query_param = "page"


class MovieView(APIView):
    def get(self, request, *args, **kwargs):
        # 获取所有数据
        movies = Movie.objects.all()
        # 创建分页对象，这里是自定义的MyPageNumberPagination
        page = MyPageNumberPagination()
        # 获取分页的数据
        movies_page = page.paginate_queryset(queryset=movies, request=request, view=self)
        # 对数据进行序列化
        ser = MovieSerializer(instance=movies_page, many=True)
        # return Response(ser.data)  # 不含上一页下一页
        return page.get_paginated_response(ser.data)
```

urls.py

```
urlpatterns = [
  url(r'^movies/', views.MovieView.as_view()),
]
```

### **第二种分页LimitOffsetPagination** 

views.py

```
class MyLimitOffsetPagination(LimitOffsetPagination):
    # 默认显示的个数
    default_limit = 2
    # 当前的位置
    offset_query_param = "offset"
    # 通过limit改变默认显示的个数
    limit_query_param = "limit"
    # 一页最多显示的个数
    max_limit = 30


class MovieView(APIView):
    def get(self, request, *args, **kwargs):
        # 获取所有数据
        movies = Movie.objects.all()
        # 创建分页对象
        page = MyLimitOffsetPagination()
        # 获取分页的数据
        movies_page = page.paginate_queryset(queryset=movies, request=request, view=self)
        # 对数据进行序列化
        ser = MovieSerializer(instance=movies_page, many=True)
        # return Response(ser.data)  # 不含上一页下一页
        return page.get_paginated_response(ser.data)
```

urls.py

```
urlpatterns = [
  url(r'^movies/', views.MovieView.as_view()),
]
```

### **第三种分页CursorPagination** 

这种是加密分页方式，只能通过点“上一页”和下一页访问数据 

views.py

```
class MyCursorPagination(CursorPagination):
    cursor_query_param = "cursor"
    page_size = 2   #每页显示2个数据
    ordering = 'id'  #排序
    page_size_query_param = None
    max_page_size = None


class MovieView(APIView):
    def get(self, request, *args, **kwargs):
        # 获取所有数据
        movies = Movie.objects.all()
        # 创建分页对象
        page = MyCursorPagination()
        # 获取分页的数据
        movies_page = page.paginate_queryset(queryset=movies, request=request, view=self)
        # 对数据进行序列化
        ser = MovieSerializer(instance=movies_page, many=True)
        # return Response(ser.data)  # 不含上一页下一页
        return page.get_paginated_response(ser.data)
```

urls.py

```
urlpatterns = [
  url(r'^movies/', views.MovieView.as_view()),
]
```

### 