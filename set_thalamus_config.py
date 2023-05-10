#!/usr/bin/env python3
from time import sleep
from proteus import config, Model
import os

user = 'admin'
password = os.environ.get("ADMIN_PASSWORD", 'opendx28')
dbname = os.environ.get("DB_NAME", 'ghs1')
hostname = 'localhost'
port = '8000'
health_server = 'http://'+user+':'+password+'@'+hostname+':'+port+'/'+dbname+'/'
n_retries = 5
sleep(10)
while n_retries > 0:
    try:
        health_server_2 = 'http://' + user + ':*@' + hostname + ':' + port + '/' + dbname + '/'
        print("Trying to connect to " + health_server_2)
        conf = config.set_xmlrpc(health_server)
        print(f"Success! {health_server_2}")
        break
    except:
        conf = None
        n_retries -= 1
        sleep(2)
        print("Retrying...")

if conf:
    FederationNodeConfig = Model.get('gnuhealth.federation.config')
    fnc = FederationNodeConfig.find([('id', '=', 1)])
    fnc[0].host = "thalamus"
    fnc[0].port = 8080
    fnc[0].ssl = False
    fnc[0].save()
