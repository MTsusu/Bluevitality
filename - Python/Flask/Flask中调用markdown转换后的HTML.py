from flask import Markup
import markdown

@app.route('/mark')
def mark():
    con = """
##Quict Start
###Adding Views

``` python
from flask import Flask
from flask.ext.admin import Admin, BaseView, expose
from .model import User, FavVideo, Article, db

class MyView(BaseView):
    @expose('/')
    def index(self):
        return self.render('index.html')
\```  
"""
    contents= Markup(markdown.markdown(con))
    return render_template('mark.html', content=contents)
    
    
#注：第19行的\用于转义```（它们是markdown的一部分）
