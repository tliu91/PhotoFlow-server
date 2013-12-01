import json
import urllib
import urllib2

class GeocodeError(Exception):
	def __init__(self, value):
		self.value = value
	def __str__(self):
		return repr(self.value)

class Geocoder:

	def lookup(self, address=None, latlng=None, sensor='true'):
		params = {}

		if address and latlng:
			raise GeocodeError('Only one of address and latlng can be provided')

		if address:
			params['address'] = address

		if latlng:
			params['latlng'] = latlng

		params['sensor'] = sensor

		query = "&".join("%s=%s" % (k, urllib.quote(params[k])) for k in params.keys())
		url = "http://maps.googleapis.com/maps/api/geocode/json?" + query

		print url

		try:
			response = urllib2.urlopen(url)
		except urllib2.URLError, e:
			raise GeocodeError('URL error %s', e)
		else:
			result = json.loads(response.read())


		return result











