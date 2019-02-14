"""
新建管理实体
ogin_manager = LoginManager()
 
绑定当前应用
login_manager.setup_app(app)
 
同步用户信息
@login_manager.user_loader
def load_user(userid):
    return User.get(userid)       #如果userId不存在返回None，不要抛异常，返回None后该用户信息会自动从session中删除 (这里写ORM的..)
 
使用
@app.route("/settings")
@login_required
def settings():
    pass

登出
@app.route("/logout")
@login_required
def logout():
    logout_user()                  #...
    return redirect(somewhere)
 
用户model必须实现的接口如下
 is_authenticated()
 is_active()
 is_anonymous()
 get_id()       #返回的需要是一个unicode
 
注：
1：可以通过 current_user 获取当前登陆用户信息（login提供的全局变量）
2：有些地方（比如修改密码）方法上需要加上fresh_login_required而不是login_required
   两者的区别在于前者必须是用户手动登陆，后者还包含了cookie自动登陆的情况
"""

..............
