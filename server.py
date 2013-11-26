import time
import datetime
import twitter
import forecast
from flask import Flask, request, jsonify, make_response
app = Flask(__name__)
app.config.from_object('config')

@app.route('/streams', methods=['GET'])
def streams():
	latitude = request.args.get('lat')
	longitude = request.args.get('long')
	timestamp = request.args.get('timestamp')
	return make_response(jsonify({ 'lat': latitude, 'long': longitude }), 404)

# Here's a test url:
# http://localhost:5000/search?lat=42.3595760&lon=-71.1020130&rad=2&q=MIT
@app.route('/search', methods=['GET'])
def tweet_search():
	api = twitter.Twitter(app.config['TWITTER_API_KEY'], app.config['TWITTER_API_SECRET'])

	query= request.args.get('q')
	lat = request.args.get('lat')
	lon = request.args.get('lon')
	radius = request.args.get('rad')

	results = api.find_tweets(query, lat, lon, radius)
	return make_response(jsonify(results), 404)

# Test urls:
# http://localhost:5000/forecast?lat=42.3595760&lon=-71.1020130
# http://localhost:5000/forecast?lat=42.3595760&lon=-71.1020130&time=1385024400
@app.route('/forecast', methods=['GET'])
def forecast_search():
	forecaster = forecast.ForecastIO(app.config['FORECASTIO_API_KEY'])

	lat = request.args.get('lat')
	lon = request.args.get('lon')
	time = request.args.get('time')

	results = forecaster.get_current_forecast(lat, lon, time)

	return make_response(jsonify(results), 404)

@app.errorhandler(404)
def not_found(error):
  	return make_response(jsonify({ 'error': 'Not found' }), 404)


if __name__ == "__main__":
	app.run(debug = True)
