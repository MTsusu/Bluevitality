# -*- coding: utf-8 -*-
import os

from examples.auth.app import security, admin
from flask import render_template
from flask import url_for
from flask_debugtoolbar import DebugToolbarExtension
from flask_script import Shell
from flask_migrate import Migrate, MigrateCommand
from flask_script import Manager

from app import create_app
from app import db

from flask_admin import helpers as admin_helpers

app = create_app(os.getenv('FLASK_CONFIG') or 'default')
toolbar = DebugToolbarExtension()
manager = Manager(app)
migrate = Migrate(app, db)
toolbar.init_app(app)


def make_shell_context():
    return dict(app=app, db=db)


@app.route('/')
def hello_world():
    return render_template('index.html')


manager.add_command("shell", Shell(make_context=make_shell_context))
manager.add_command('db', MigrateCommand)
if __name__ == '__main__':
    manager.run()
