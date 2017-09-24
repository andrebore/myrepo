#!/usr/bin/env python2.7

import web
import sqlite3


urls = (
    '/(.*)', 'hello'
)
app = web.application(urls, globals())

class hello:
    def GET(self, data):
        mytable = data.tab
        data = web.input()

        # Generate a GET request with the following format http://{IP}:{port}/?tab=dht&r=1&t=20&h=45
        if (mytable =="temp"):
            room = data.r
            temp = data.t
            humi = data.h

            dbconnection = None

            try:
                dbconnection = sqlite3.connect('/home/andrea/dhtdb/dhtdb.db')
                cursor = dbconnection.cursor()
                # insert data into db
                cursor.execute("INSERT INTO Temperature (Room, Temp, Humidity) VALUES (" + room + ", " + temp + ", " + humi + ");")

                return 'recorded: Room ' + room + ' - Temperature ' + temp + '*C - Humidity ' + humi +'%'

            except sqlite3.Error, e:
                return "Error %s:" % e.args[0]

            finally:
                if dbconnection:
                    dbconnection.commit()
                    dbconnection.close()
