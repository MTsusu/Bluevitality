#### 简介
```txt
Python项目中必须包含有 requirements.txt 文件，其用于记录所有依赖包及其精确的版本号，以便新环境的部署。

Demo:
pip freeze > requirements.txt     #根据当前项目自动生成 requirements.txt
pip install -r requirements.txt   #从requirements.txt安装依赖
```

#### requirements.txt 格式 ()
```bash
pypinyin==0.12.0                    # 指定版本（常用）
django-querycount>=0.5.0            # 大于某版本
django-debug-toolbar>=1.3.1,<=1.3.3 # 指定版本范围
ipython                             # 默认（存在不替换，不存在安装最新版）  
```

#### 第三方工具生成
```python
# pip freeze 会附带上一些不需要的包，以及某些包依赖的包~
# pipreqs 自动分析项目中引用的包。对Django项目自动构建的时候忽略了Mysql包，版本也很奇怪；而且联网搜索的时候遇到404就报错跳出了
# pigar 功能同上，会显示包被项目文件引用的地方（搜索下就能解决的问题啊= =感觉是伪需求），404的问题也存在
# pip-tools 通过第三方文件生成requirements.txt，讲道理为什么不直接写呢，要通过第三方包来做一层转换
```

