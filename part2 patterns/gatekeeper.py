from flask import Flask, request
import requests


"""This Python script sets up a Flask web server to handle HTTP POST requests on the '/query_analysis' endpoint.
It reads the 'proxy_addr' file to determine the base URL of a proxy server. The server expects a 'type_of_proxy'
parameter in the query string, which should be one of ['direct_hit', 'random', 'customized'].
It then constructs a URL for the MySQL Proxy based on the provided type and forwards the incoming request to that proxy.
The server returns the response received from the proxy, along with appropriate HTTP status codes.
The application runs on host '0.0.0.0' and port '80'."""


app = Flask(__name__)

# Proxy Server Configuration
with open("proxy_addr", "r") as file:
    proxy_server_base_url = file.read().strip()


@app.route('/query_analysis', methods=['POST'])
def query_analysis():

    # Get the query parameter 'proxy_type' from the request URL
    type_of_proxy = request.args.get('type_of_proxy', default='direct_hit')

    # Validate the proxy_type parameter
    if type_of_proxy not in ['direct_hit', 'random', 'customized']:
        return "Invalid proxy_type parameter", 400

    # Forward request to the specified MySQL Proxy endpoint
    url_proxy = f"http://{proxy_server_base_url}/{type_of_proxy}"
    response = requests.post(url_proxy, data=request.data)

    if response.status_code == 200:
        return response.text, 200
    else:
        return "Error processing request", 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)


