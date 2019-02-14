from database_extention import db 

class User(db.Model):
    id = db.Column( db.Integer, primary_key=True)
    name = db.Column( db.String( 50 ), unique = True )
    email = db.Column( db.String( 120 ), unique = True )
    password = db.Column( db.String( 120 ) )
    blogs = db.relationship('Blog', backref = 'users', lazy = 'dynamic')

    def __init__( self, name, password, email ):
        self.name = name
        self.email = email
        self.password = password

    __tablename__ = 'users'

    def __repr( self ):
        return '<User %r>' % (self.name)

class Blog(db.Model):
    id = db.Column( db.Integer, primary_key=True)
    title = db.Column( db.String( 100 ) )
    text = db.Column( db.String( 1024 ) )

    author = db.relationship("User", backref=db.backref('blog', order_by=id))
    author_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    def __init__( self, title, text, author ):
        self.title = title
        self.text = text
        #author = db.relation(User, innerjoin=True, lazy="joined")
        self.author = author

    __tablename__ = 'blogs'

    def __repr__( self ):
        return '<Blog %r author_id %d>' % (self.title, self.author_id)


        