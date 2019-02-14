#Example 1
def cookies_login():
    name = request.args.get("username", False)          #获取get请求参数 ?username=xxx 的值
    password = request.args.get("password", False)      #获取get请求参数 ?password=xxx 的值

    if not password == "password" or not name:
        abort(401)                                      #需要交给 @app.errorhandler(401) 处理

    resp = make_response("You are now authorized")      #定制 response
    resp.set_cookie("username", name)                   #定制的内容
    return resp                                         #返回


#Example 2
def session_login():
    name = request.args.get("username", False)
    password = request.args.get("password", False)
    
    if not password == "password" or not name:
        abort(401)

    resp = make_response("You are now authorized")      #定制 response
    session['username'] = name                          #让会话携带特定的KEY与VALUE
    session['login-time'] = datetime.now()              #...
    return resp


#Example 3
def dynamic_js():
    from sagenb.notebook.js import javascript
    # the javascript() function is cached, so there shouldn't be a big slowdown calling it
    data,datahash = javascript()
    if request.environ.get('HTTP_IF_NONE_MATCH', None) == datahash:
        response = make_response('',304)
    else:
        response = make_response(data)
        response.headers['Content-Type'] = 'text/javascript; charset=utf-8'
        response.headers['Etag']=datahash
    return response
