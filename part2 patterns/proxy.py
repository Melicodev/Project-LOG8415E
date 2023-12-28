import sys
import json
import random
import pymysql
import pymysql.cursors
from pythonping import ping
from sshtunnel import SSHTunnelForwarder
import Flask

app = Flask(__name__)

def send_query(ip_of_worker, ip_of_manager, request):
    '''
    Sends the request to the node/worker chosen.
    ip_of_worker : the ip of the worker
    ip_of_manager : ip of the manager of the cluster
    request : the request to send
    '''
    sshtunnel = SSHTunnelForwarder(
        ip_of_worker, 
        ssh_username="ubuntu",
        ssh_password="key.pem",
        remote_bind_address=(ip_of_manager, 3306))
    
    sshtunnel.start
    connection = pymysql.connect(host=ip_of_manager,
                        user='root',
                        password='root',
                        database='sakila',
                        #charset='utf8mb4',
                        port=3306, 
                        autocommit=True)
    with connection:
        if (request=='example'):
            with connection.cursor() as cursor:
                # Example
                print("Example :'SELECT * FROM film_actor;' : ")
                sql = 'SELECT * FROM film_actor;'
                cursor.execute(sql)
                result = cursor.fetchall()
            for line in result:
                print(line)
        else:
            with connection.cursor() as cursor:
                # Custom query
                cursor.execute(request)
                result = cursor.fetchall()
                for line in result:
                    print(line)

    
def is_write_request(request):
    '''
    Determines of the query needs write access.
    request: the requested instruction
    '''
    is_write = False
    instructions = request.split(";")
    for instruction in instructions:
        keyword = instruction.strip().lower().split()
        if len(keyword)>0 and keyword[0] in ["rename", "delete", "insert", "update", "create", "alter", "drop"]:
            is_write = True
    return is_write


@app.route('/direct_hit', methods=['POST'])
def direct_hit(ip_of_manager, request):
    '''
    Directly forward incoming requests to MySQL master node.
    '''
    query = request.data.decode('utf-8')
    # Use direct_hit function for write instructions
    return send_query(ip_of_manager, ip_of_manager, query)

    

@app.route('/random', methods=['POST'])
def random(ip_of_workers, ip_of_manager, request):
    '''
    Randomly choose a slave node on MySQL cluster and forward the request to it.
    '''
    worker = ip_of_workers[random.randint(0,2)]
    print('Selected : ' + str(worker))
    query = request.data.decode('utf-8')

    if is_write_request(query):
        # Use direct_hit function for write instructions
        send_query(worker, ip_of_manager, request)
    
    
@app.route('/customized', methods=['POST'])
def customized(ips, ip_of_manager, request):
    '''
    Measure the ping time of all the servers and forward the message to one with less response time.
    return the ip of the server with the lowest ping
    '''
    query = request.data.decode('utf-8')
    if is_write_request(query):
        # Use direct_hit function for write instructions
        return send_query(ips, ip_of_manager, request)
    
    best = None
    time = float('inf')
    for ip in ips:
        ping_result = ping(ip, count=1, timeout=2)
        if ping_result.packet_loss != 1 and ping_result.rtt_avg_ms < time:
            best = ip
            time = ping_result.rtt_avg_ms
    if (best != None):
        print(best)
        send_query(best, ip_of_manager, request)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
   