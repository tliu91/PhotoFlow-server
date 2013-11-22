import time
import twitter
from flask import Flask, request, jsonify, make_response
app = Flask(__name__)

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
	api = twitter.Twitter()

	query= request.args.get('q')
	lat = request.args.get('lat')
	lon = request.args.get('lon')
	radius = request.args.get('rad')
	
	results = api.find_tweets(query, lat, lon, radius)
	return make_response(jsonify(results), 404)
	
@app.errorhandler(404)
def not_found(error):
  	return make_response(jsonify({ 'error': 'Not found' }), 404)


if __name__ == "__main__":
	app.run(debug = True)
