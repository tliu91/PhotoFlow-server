import time
from flask import Flask, request, jsonify, make_response
app = Flask(__name__)

@app.route('/streams', methods=['GET'])
def streams():
  latitude = request.args.get('lat')
  longitude = request.args.get('long')
  timestamp = request.args.get('timestamp')
  return make_response(jsonify({ 'lat': latitude, 'long': longitude }), 404)

@app.errorhandler(404)
def not_found(error):
  return make_response(jsonify({ 'error': 'Not found' }), 404)

if __name__ == "__main__":
  app.run(debug = True)
