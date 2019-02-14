# Customized admin interface
from flask import request
from flask import url_for
from flask_admin.contrib import sqla
from flask_login import current_user
from flask_admin.contrib.sqla import ModelView
from werkzeug.exceptions import abort
from werkzeug.utils import redirect


class CustomView(ModelView):
    list_template = 'list.html'
    create_template = 'create.html'
    edit_template = 'edit.html'


class UserAdmin(CustomView):
    column_searchable_list = ('name',)
    column_filters = ('name', 'email')


# Create customized model view class
class MyModelView(sqla.ModelView):
    def is_accessible(self):
        if not current_user.is_active or not current_user.is_authenticated:
            return False

        if current_user.has_role('superuser'):
            return True

        return False

    def _handle_view(self, name, **kwargs):
        """
        Override builtin _handle_view in order to redirect users when a view is not accessible.
        """
        if not self.is_accessible():
            if current_user.is_authenticated:
                # permission denied
                abort(403)
            else:
                # login
                return redirect(url_for('security.login', next=request.url))
