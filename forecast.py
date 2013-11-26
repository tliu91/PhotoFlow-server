import forecastio
import datetime

class ForecastIO:
	def __init__(self, app_key):
		self.app_key = app_key

	# TODO: We should cache these responses so we avoid having to make a ton of API calls
	def get_current_forecast(self, lat, lon, time):
		if time is not None:
			time = self.timestamp_to_datetime(time)

		forecast = forecastio.load_forecast(self.app_key, lat, lon, time)
		current = forecast.currently()

		results = { 'lat' : lat,
					'lon' : lon,
					'time': current.time,
					'summary': current.summary,
					'precipProb': current.precipProbability }

		print current.time

		return results

	def timestamp_to_datetime(self, time):
		if time is not None:
			time = int(time)
			return datetime.datetime.fromtimestamp(time)





