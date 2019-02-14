from flask import Flask
from flask.ext.mail import Mail, Message
import os

app = Flask(__name__)
app.config.update(
    DEBUG = True,MAIL_SERVER='smtp.live.com',MAIL_PROT=25,MAIL_USE_TLS = True,MAIL_USE_SSL = False,MAIL_USERNAME = 'example@hotmail.com',
    MAIL_PASSWORD = '**********',MAIL_DEBUG = True
)

mail = Mail(app)        #顺便从app.config中获取配置并执行一些实例化...

@app.route('/')
def index():
    # sender 发送方哈，recipients 邮件接收方列表
    msg = Message("Hi!This is a test ",sender='example@example.com', recipients=['example@example.com'])
    msg.body = "This is a first email"                      # msg.body 邮件正文 
    with app.open_resource("F:\2281393651481.jpg") as fp:   # msg.attach 邮件附件添加
        msg.attach("image.jpg", "image/jpg", fp.read())     # msg.attach("文件名", "类型", 读取文件）

    mail.send(msg)
    print "Mail sent"
    return "Sent"

if __name__ == "__main__":
    app.run()
