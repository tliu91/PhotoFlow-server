from twython import Twython

class Twitter:
	ACCESS_TOKEN = ''

	def __init__(self, app_key, app_secret):
		self.app_key = app_key
		self.app_secret = app_secret

		self.client = self.authenticate()


	def authenticate(self):
		twitter = Twython(self.app_key, self.app_secret, oauth_version=2)

		# Store the access token so we don't have to keep requesting Twitter for it
		if (Twitter.ACCESS_TOKEN == ''):
			Twitter.ACCESS_TOKEN = twitter.obtain_access_token()

		api = Twython(self.app_key, access_token=Twitter.ACCESS_TOKEN)

		return api


	def find_tweets(self, query, lat, lon, radius):
		geocode = lat + ',' + lon + ',' + radius + 'mi'
		count = 100
		results = self.client.search(q=query, geocode=geocode, count=count)

		return results
