#!/usr/bin/env python2.7

import web
import sqlite3


urls = (
    '/(.*)', 'hello'
)
app = web.application(urls, globals())

class hello:
    def GET(self, data):
        data = web.input()
        mytable = data.tab

        # Generate a GET request with the following format http://{IP}:{port}/?tab=dht&r=1&t=20&h=45
        if (mytable =="dht"):
            room = data.r
            temp = data.t
            humi = data.h

            dbconnection = None

            try:
                dbconnection = sqlite3.connect('/home/andrea/dhtsensor/dhttrend_db/dhttrend.db')
                cursor = dbconnection.cursor()
                # insert data into db
                cursor.execute("INSERT INTO trend (room, temp, humidity) VALUES (" + room + ", " + temp + ", " + humi + ");")

                return 'recorded: Room ' + room + ' - Temperature ' + temp + '*C - Humidity ' + humi +'%'

            except sqlite3.Error, e:
                return "Error %s:" % e.args[0]

            finally:
                if dbconnection:
                    dbconnection.commit()
                    dbconnection.close()

if __name__ == "__main__":
app.run()
