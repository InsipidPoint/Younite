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

class FakeMessage(db.Model):
    cause = db.StringProperty(multiline=False, required=True, default="World Peace")
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
		messages = db.GqlQuery("SELECT * FROM FakeMessage ORDER BY timestamp DESC")
		for message in messages:
			self.response.out.write('<Message>\n')
			self.response.out.write('<Name>%s</Name>\n' % message.name )
			self.response.out.write('<Cause>%s</Cause>\n' % message.cause )
			self.response.out.write('<Location>%f,%f</Location>\n' % (message.location.lat, message.location.lon) )
			self.response.out.write('</Message>\n')
	
class GetMessage(webapp.RequestHandler):
	def get(self):
		messages = db.GqlQuery("SELECT * FROM Message")
		r = random.random()*messages.count()
		index = 0
		for message in messages:
			index = index + 1
			if index > r:
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

class AddFakeMessage(webapp.RequestHandler):
	def get(self):
		lat = [37.78,41.48,40.98,35.43,39.13,33.93,35.28,34.27,37.60,39.28,33.62,34.20,33.30,32.62,33.13,37.38,39.78,35.68,33.97,37.98,41.78,34.87,34.90,32.82,34.08,33.67,41.33,36.00,36.68,36.77,33.87,34.58,33.92,37.65,32.83,32.57,34.10,38.90,34.73,36.33,37.70,33.82,33.78,33.93,37.63,33.88,39.10,38.57,38.67,37.28,32.87,37.63,37.42,35.05,41.73,36.58,41.32,34.23,38.22,34.77,32.70,34.10,37.73,34.05,34.20,33.83,35.05,37.47,35.67,37.83,34.12,39.58,34.95,35.67,36.12,40.15,40.50,33.95,38.52,38.70,36.67,37.52,33.42,33.02,32.82,32.73,32.57,32.57,32.82,37.75,37.62,37.37,37.33,35.23,33.38,34.03,33.25,34.75,33.67,34.43,34.90,34.02,38.52,40.03,41.78,37.90,35.33,40.63,33.63,33.80,38.27,39.32,33.70,34.28,39.13,34.22,35.20,35.20,36.32]
		lon = [-122.32,-120.53,-124.10,-119.05,-121.45,-116.95,-116.62,-116.68,-118.60,-120.70,-114.72,-118.37,-117.35,-116.47,-117.28,-120.57,-121.85,-117.68,-117.63,-122.05,-124.23,-116.78,-117.88,-115.68,-118.03,-117.73,-124.28,-121.32,-121.77,-119.72,-117.97,-117.38,-118.33,-122.12,-115.57,-117.12,-117.78,-120.00,-118.22,-119.95,-121.82,-118.15,-118.05,-118.40,-118.92,-117.27,-121.57,-121.30,-121.40,-120.52,-117.15,-120.95,-122.05,-118.15,-122.53,-121.85,-122.32,-118.07,-122.28,-114.62,-117.20,-117.23,-122.22,-117.62,-119.20,-116.50,-118.13,-122.12,-120.63,-122.83,-119.12,-124.22,-121.12,-121.28,-121.47,-122.25,-122.30,-117.45,-121.50,-121.60,-121.60,-122.25,-117.62,-118.58,-117.13,-117.17,-116.98,-116.98,-116.97,-122.68,-122.38,-121.92,-121.82,-120.65,-117.58,-120.40,-119.45,-118.73,-117.88,-119.83,-120.45,-118.45,-122.82,-124.07,-122.47,-121.25,-117.10,-120.95,-116.17,-118.33,-121.93,-120.13,-117.83,-116.15,-123.20,-118.48,-120.95,-120.95,-119.40]
		latboston = [42.47,42.58,42.37,41.78,41.67,42.57,41.67,42.72,41.40,41.25,41.68,42.18,41.65,42.26,42.15,42.17,42.20,42.27]
		lonboston = [-71.28,-70.92,-71.03,-70.50,-69.97,-71.60,-70.28,-71.12,-70.62,-70.07,-70.97,-71.18,-70.52,-73.18,-70.93,-72.72,-72.53,-71.87]
		deltaa = 1.0
		deltab = 1.0
		c1 = 5;
		c2 = 5;
		for i in range(0,len(lat)):
			if(random.random() > 0.1):
				for i in range(1, c1):
					r1 = deltaa - 2*random.random()*deltaa
					r2 = deltab - 2*random.random()*deltab
				
					message = FakeMessage()
					message.cause = """World Peace"""
					message.name = """Anonymous"""
					message.location = db.GeoPt(latboston[i]+r1,lonboston[i]+r2)
					message.put()
			else:		
				for i in range(1,c2):
					r1 = deltaa - 2*random.random()*deltaa
					r2 = deltab - 2*random.random()*deltab
			
					message = FakeMessage()
					message.cause = """Haiti"""
					message.name = """Anonymous"""
					message.location = db.GeoPt(latboston[i]+r1,lonboston[i]+r2)
					message.put()
		
		self.redirect('/')
	

application = webapp.WSGIApplication(
									 [('/', MainPage),
            						  ('/add', AddMessage),
									  ('/addfake', AddFakeMessage),
									  ('/get', GetMessage),
									  ('/everything', GetAllMessages)],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()