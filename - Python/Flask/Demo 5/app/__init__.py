# -*- coding: utf-8 -*-
import os
import os.path as op
import sys

import flask_admin
from flask import Flask
from flask import url_for
from flask_admin import helpers as admin_helpers
from flask_admin.contrib import fileadmin
from flask_bootstrap import Bootstrap
from flask_login import LoginManager
from flask_mail import Mail
from flask_moment import Moment
from flask_pagedown import PageDown
from flask_security import SQLAlchemyUserDatastore
from flask_security import Security

from app.users.models import Role, db
from app.users.models import User
from app.users.modelview import UserAdmin, CustomView, MyModelView
from config import config

defaultencoding = 'utf-8'
if sys.getdefaultencoding() != defaultencoding:
    reload(sys)
    sys.setdefaultencoding(defaultencoding)

bootstrap = Bootstrap()
mail = Mail()
moment = Moment()
pagedown = PageDown()

login_manager = LoginManager()
login_manager.session_protection = 'strong'
login_manager.login_view = 'auth.login'
path = op.join(op.dirname(__file__), 'upload_files')


def create_app(config_name):
    app = Flask(__name__, template_folder='users/templates', static_folder='upload_files')
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)

    bootstrap.init_app(app)
    mail.init_app(app)
    moment.init_app(app)
    db.init_app(app)
    login_manager.init_app(app)
    pagedown.init_app(app)

    # Setup Flask-Security
    user_datastore = SQLAlchemyUserDatastore(db, User, Role)
    security = Security(app, user_datastore)

    # from .app import app as main_blueprint
    # from .auth import auth as auth_blueprint
    # from .user import user as user_blueprint
    #
    # app.register_blueprint(main_blueprint)
    # app.register_blueprint(auth_blueprint, url_prefix='/auth')
    # app.register_blueprint(user_blueprint, url_prefix='/user')


    # Create admin
    admin = flask_admin.Admin(
        app,
        'Example: 黎光',
        base_template='my_master.html',
        template_mode='bootstrap3',
    )

    # Add model views
    admin.add_view(MyModelView(Role, db.session))
    admin.add_view(MyModelView(User, db.session))

    if not os.path.exists(path):
        try:
            os.mkdir(path)
        except OSError:
            pass

    admin.add_view(fileadmin.FileAdmin(path, '/upload_files/', name='Files'))

    # define a context processor for merging flask-admin's template context into the
    # flask-security views.
    @security.context_processor
    def security_context_processor():
        return dict(
            admin_base_template=admin.base_template,
            admin_view=admin.index_view,
            h=admin_helpers,
            get_url=url_for
        )

    return app

# @app.route('/')
# def hello_world():
#     return '<a href="/admin/">Click me to get to Admin!</a>'
