#!/usr/bin/python3
import sqlite3
import os
import sys
import cgi
import cgitb

# global variables
dbname='/home/andrea/dhtsensor/dhttrend_db/dhttrend.db' #path and db name here

def get_lasttemp(room):
	conn=sqlite3.connect(dbname)
	curs=conn.cursor()
	curs.execute("SELECT temp FROM trend WHERE id=(select max(id) from trend) AND room=%i" % room)
	t=curs.fetchone()
	t="{0}C".format(str(t[0]))
	conn.close()
	return t

def get_lasthumidity(room):
	conn=sqlite3.connect(dbname)
	curs=conn.cursor()
	curs.execute("SELECT humidity FROM trend WHERE id=(select max(id) from trend) AND room=%i" % room)
	h=curs.fetchone()
	h="{0}%".format(str(h[0]))
	conn.close()
	return h

def main():
	lasttemp = get_lasttemp(int(sys.argv[1]))
	lasthum = get_lasthumidity(int(sys.argv[1]))
	print "Last temp is",lasttemp,"and last humidity is",lasthum

if __name__=="__main__":
    main()
