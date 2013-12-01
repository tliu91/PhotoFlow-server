import flickrapi
import json

class Flickr:
	def __init__(self, app_key, app_secret):
		self.app_key = app_key
		self.app_secret = app_secret
		self.client = self.authenticate()

	def authenticate(self):
		client = flickrapi.FlickrAPI(self.app_key, self.app_secret, format='json')

		(token, frob) = client.get_token_part_one(perms='write')
		if not token: raw_input("Press ENTER after you authorized this program")
		client.get_token_part_two((token, frob))
		return client

	def find_photos(self, lat, long, time):
		raw = self.client.photos_search(lat=lat, lon=long, nojsoncallback=1)
		results_obj = json.loads(raw)
		return {'photos': self.contruct_photos_list(results_obj)}

	def contruct_photos_list(self, results_obj):
		return [self.construct_photo_url(photo) for photo in results_obj['photos']['photo']]

	def construct_photo_url(self, photo):
		farm = photo['farm']
		server = photo['server']
		pid = photo['id']
		secret = photo['secret']
		return "http://farm%s.staticflickr.com/%s/%s_%s.jpg" % (farm, server, pid, secret)
