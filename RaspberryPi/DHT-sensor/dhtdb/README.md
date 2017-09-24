Before populating the DB, install sqlite3:
  sudo apt-get install sqlite3

Install the Python module to interact with the DB from the webserver:
  sudo pip install sqlite or sudo pip install pysqlite

Create the db:
sqlite3 /path/to/db.db

Create table: SQLITE>.read createtable.sql
Check table:.table (you shoud see two tables - rooms and trend)
Exit from the SQLITE prompt with CTRL-D
