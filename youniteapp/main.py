import cgi
import datetime
import random

from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

class Message(db.Model):
    cause = db.StringProperty(multiline=False, required=True, default="World Peace")
    audio = db.TextProperty(required=False, default="0")
    sound = db.StringProperty(multiline=False, required=True, default="Mandolin")
    location = db.GeoPtProperty(required=True, indexed=True, default=db.GeoPt(37.424106,-122.166076))
    name = db.StringProperty(multiline=False, required=True, default="Anonymous")
    timestamp = db.DateTimeProperty(auto_now_add=True)

class MainPage(webapp.RequestHandler):
    def get(self):
		self.response.out.write('<html><body>')
		messages = db.GqlQuery("SELECT * FROM Message ORDER BY timestamp DESC LIMIT 10")

		for message in messages:
			self.response.out.write('<b>%s</b> wished:' % message.name)
			self.response.out.write('<H3>%s</H3>' % cgi.escape(message.audio))
			difference = message.timestamp - datetime.datetime.now()
			weeks, days = divmod(difference.days, 7)

			minutes, seconds = divmod(difference.seconds, 60)
			hours, minutes = divmod(minutes, 60)
			self.response.out.write('%s hours ago<br>' % hours)
	        
			# Temp data entry form and the footer of the page
		self.response.out.write("""
			<form action="/add" method="post">
			        <div>Name: <input type="text" name="name"></input></div>
	                <div>Message: <input type="text" name="audio"></input></div>
	                <div><input type="submit" value="Add"></div>
			</form>
	        </body>
	    	</html>""")
class GetAllMessages(webapp.RequestHandler):
	def get(self):
		messages = db.GqlQuery("SELECT * FROM Message ORDER BY timestamp DESC")
		for message in messages:
			self.response.out.write('<Message>\n')
			self.response.out.write('<Name>%s</Name>\n' % message.name )
			self.response.out.write('<Cause>%s</Cause>\n' % message.cause )
			self.response.out.write('<Location>%f,%f</Location>\n' % (message.location.lat, message.location.lon) )
			self.response.out.write('</Message>\n')
	
class GetMessage(webapp.RequestHandler):
	def get(self):
		messages = db.GqlQuery("SELECT * FROM Message ORDER BY timestamp DESC")
		for message in messages:
			r = random.random()
			if r > 0.7:
				self.response.out.write('<Audio>%s</Audio>\n' % message.audio )
				self.response.out.write('<Name>%s</Name>\n' % message.name )
				self.response.out.write('<Cause>%s</Cause>\n' % message.cause )
				self.response.out.write('<Location>%f,%f</Location>\n' % (message.location.lat, message.location.lon) )
				self.response.out.write('<Id>%s</Id>\n' % self.request.get('id') )
				break

		
class AddMessage(webapp.RequestHandler):
	def post(self):
		message = Message()
		message.cause = self.request.get('cause')
		message.audio = self.request.get('audio')
		message.name = self.request.get('name')
		message.sound = """some sound params"""
		message.location = db.GeoPt(float(self.request.get('lat')),float(self.request.get('lon')))
		message.put()
		self.redirect('/')


application = webapp.WSGIApplication(
									 [('/', MainPage),
            						  ('/add', AddMessage),
									  ('/get', GetMessage),
									  ('/everything', GetAllMessages)],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()