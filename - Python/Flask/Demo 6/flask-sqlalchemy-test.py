from flask import Flask, session, g, render_template, url_for, redirect, request

from database_extention import db 

from database import User, Blog

import os


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/test.db'
db.init_app( app )
db.create_all(app =app)


@app.route('/')
def show_home():
	if 'username' not in session:
		return render_template( 'homepage.html' )
	username = session['username']
	if username == None:
		return render_template( 'homepage.html' )
	return render_template( 'homepage.html', username = username )

@app.route('/login', methods = ['GET', 'POST'])
def login():
	if request.method == 'POST':
		username = request.form['username']
		password = request.form['password']

		user = User.query.filter_by( name=username ).first()
		if user == None:
			return render_template('showrecord.html', error = 'user doesnot exist!')

		if password == user.password:
			session['username'] = user.name
			return render_template('showrecord.html', username = user.name )
		else:
			return render_template('showrecord.html', error = 'password mismatch' )

@app.route('/logout')
def logout():
	session.pop('username', None)
	#db.drop_all()
	return render_template('homepage.html', username = None )

@app.route('/signin', methods=['GET', 'POST'])
def sign_in():
	if request.method == 'POST':
		username = request.form['username']
		password = request.form['password']
		email = request.form['email']

		user = User(username, password, email )
		db.session.add(user)
		db.session.commit()


	return redirect( url_for( 'show_home' ) )


@app.route('/showrecord')
def show_record():
	users = User.query.all()
	records = [ dict( username=user.name, email=user.email ) for user in users ]
	


	return render_template('showrecord.html', records = records )

@app.route('/addblog', methods=['POST', 'GET'])
def add_blog():
	if request.method == 'POST':
		title = request.form['title']
		text = request.form['text']
		username = session['username']

		user = User.query.filter_by( name=username ).first()

		blog = Blog( title = title, text=text, author = user )
		db.session.add( blog )
		db.session.commit()
		return redirect(url_for('show_blog'))

	elif request.method == 'GET':
		username = session['username']

		return render_template('addblog.html', username= username)

	return redirect( url_for( 'show_blog' ) )

@app.route('/showblog')
def show_blog():
	#blogs = Blog.query.all()
	if 'username' not in session:
		return render_template('showblog.html')
	username = session['username']
	user = User.query.filter_by( name = username ).first()
	blogs = user.blogs
	records = [ dict( id = blog.id, title = blog.title, text=blog.text, username = blog.author.name ) for blog in blogs ]

	return render_template('showblog.html', username=username, records = records )


@app.route('/showblog/<int:blog_id>')
def show_blog_id( blog_id ):
	blogId = int(blog_id)
	blog = Blog.query.get(blogId)
	records = []
	records.append( dict( id=blog_id, title = blog.title, text = blog.text ) )

	return render_template('showblog.html', records = records)

@app.route('/delblog/<int:blog_id>')
def del_blog_id( blog_id ):
	blogId = int( blog_id )
	blog = Blog.query.get( blogId )
	db.session.delete(blog)
	db.session.commit()
	return redirect( url_for( 'show_blog' ) )
	

app.secret_key = 'bracken blog'

if __name__ == "__main__":
	port = int( os.environ.get('PORT', 5000 ) )
	app.run(host='0.0.0.0',port=port,debug=True)

