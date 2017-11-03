#!/usr/bin/python3
import sqlite3
import os
import sys
import cgi
import cgitb
from datetime import datetime

# global variables
dbname='/home/andrea/dhtsensor/dhttrend_db/dhttrend.db' #path and db name here

def get_lasttemp(room):
	conn=sqlite3.connect(dbname)
	curs=conn.cursor()
	curs.execute("SELECT temp FROM trend WHERE room=%i ORDER BY id DESC LIMIT 1" % room)
	t=curs.fetchone()
	t="{0}C".format(str(t[0]))
	conn.close()
	return t

def get_lasthumidity(room):
	conn=sqlite3.connect(dbname)
	curs=conn.cursor()
	curs.execute("SELECT humidity FROM trend WHERE room=%i ORDER BY id DESC LIMIT 1" % room)
	h=curs.fetchone()
	h="{0}%".format(str(h[0]))
	conn.close()
	return h

def get_readtime(room):
        conn=sqlite3.connect(dbname)
        curs=conn.cursor()
        curs.execute("SELECT datetime(timestamp, 'localtime') FROM trend WHERE room=%i ORDER BY id DESC LIMIT 1" % room)
        readtime=curs.fetchone()
        readtime="{0}".format(str(readtime[0]))
        conn.close()
        return readtime

def main():
	lasttemp = get_lasttemp(int(sys.argv[1]))
	lasthum = get_lasthumidity(int(sys.argv[1]))
	lastread = get_readtime(int(sys.argv[1]))
	readtime = datetime.strptime(lastread, "%Y-%m-%d %H:%M:%S")
	now = datetime.strptime(datetime.now().strftime("%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S")
	delta = now - readtime
	print "Last read is: \nTemp:",lasttemp,"\nHumidity:",lasthum,"\nrecorded",int(delta.total_seconds()/60),"minutes ago"

if __name__=="__main__":
    main()
