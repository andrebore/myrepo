#!/usr/bin/env python
import sqlite3

conn=sqlite3.connect('/home/andrea/dhtsensor/dhttrend_db/dhttrend.db')
curs=conn.cursor()
curs.execute("SELECT * FROM trend WHERE Timestamp>datetime('now','-30 minutes')")
rows=curs.fetchall()
for row in rows:
  print(row)
