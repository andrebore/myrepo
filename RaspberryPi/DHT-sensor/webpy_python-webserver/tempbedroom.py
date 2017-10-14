#!/usr/bin/python3
import sqlite3
import os
import sys
import cgi
import cgitb

# global variables
dbname='/home/andrea/dhtsensor/dhttrend_db/dhttrend.db' #path and db name here

# print the HTTP header
def printHTTPheader():
    print "Content-type: text/html\n\n"

# print the HTML head section
# arguments are the page title and the table for the chart
def printHTMLHead(title, table):
    print "<head>"
    print "    <title>"
    print title
    print "    </title>"

    print_graph_script(table)

    print "</head>"


# get data from the database
# if an interval is passed,
# return a list of records from the database
def get_data(interval):

    conn=sqlite3.connect(dbname)
    curs=conn.cursor()

    if interval == None:
        curs.execute("SELECT datetime(timestamp, 'localtime'),temp,humidity FROM trend WHERE room=5")
    else:
        curs.execute("SELECT datetime(timestamp, 'localtime'),temp,humidity FROM trend WHERE timestamp>datetime('now','-%s hours') AND timestamp<=datetime('now') AND room=5" % interval)

    rows=curs.fetchall()

    conn.close()
    return rows


# convert rows from database into a javascript table
def create_table(rows):
    chart_table=""

    for row in rows[:-1]:
        rowstr="['{0}', {1}, {2}],\n".format(str(row[0]),str(row[1]),str(row[2]))
        chart_table+=rowstr

    row=rows[-1]
    rowstr="['{0}', {1}, {2}]\n".format(str(row[0]),str(row[1]),str(row[2]))
    chart_table+=rowstr

    return chart_table


# print the javascript to generate the chart
# pass the table generated from the database info
def print_graph_script(table):

    # google chart snippet
    chart_code="""
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Time', 'Temperature', 'Humidity'],
%s
        ]);
        var options = {
          title: 'Temperature and Humidity',
          vAxis: {viewWindow:{min: 10}, gridlines: {count: 20}}
        };
        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>"""

    print chart_code % (table)




# print the div that contains the graph
def show_graph():
    print '<div id="chart_div" style="width: 900px; height: 500px;"></div>'

# connect to the db and show some stats
# argument option is the number of hours
def show_stats(option):

    conn=sqlite3.connect(dbname)
    curs=conn.cursor()

    if option is None:
        option = str(24)

    curs.execute("SELECT datetime(timestamp, 'localtime'),max(temp) FROM trend WHERE timestamp>datetime('now','-%s hour') AND timestamp<=datetime('now') AND room=5" % option)
    tempmax=curs.fetchone()
    tempmax="{0}&nbsp&nbsp&nbsp{1}C".format(str(tempmax[0]),str(tempmax[1]))

    curs.execute("SELECT datetime(timestamp, 'localtime'),min(temp) FROM trend WHERE timestamp>datetime('now','-%s hour') AND timestamp<=datetime('now') AND room=5" % option)
    tempmin=curs.fetchone()
    tempmin="{0}&nbsp&nbsp&nbsp{1}C".format(str(tempmin[0]),str(tempmin[1]))

    curs.execute("SELECT ROUND(avg(temp),1) FROM trend WHERE timestamp>datetime('now','-%s hour') AND timestamp<=datetime('now') AND room=5" % option)
    tempavg=curs.fetchone()
    tempavg="{0}C".format(str(tempavg[0]))

    curs.execute("SELECT datetime(timestamp, 'localtime'),max(humidity) FROM trend WHERE timestamp>datetime('now','-%s hour') AND timestamp<=datetime('now') AND room=5" % option)
    humiditymax=curs.fetchone()
    humiditymax="{0}&nbsp&nbsp&nbsp{1}%".format(str(humiditymax[0]),str(humiditymax[1]))

    curs.execute("SELECT datetime(timestamp, 'localtime'),min(humidity) FROM trend WHERE timestamp>datetime('now','-%s hour') AND timestamp<=datetime('now') AND room=5" % option)
    humiditymin=curs.fetchone()
    humiditymin="{0}&nbsp&nbsp&nbsp{1}%".format(str(humiditymin[0]),str(humiditymin[1]))

    curs.execute("SELECT ROUND(avg(humidity),1) FROM trend WHERE timestamp>datetime('now','-%s hour') AND timestamp<=datetime('now') AND room=5" % option)
    humidityavg=curs.fetchone()
    humidityavg="{0}%".format(str(humidityavg[0]))


    print "<hr>"


    print "<h2>Minumum value&nbsp</h2>"
    print tempmin
    print "<p></p>"
    print humiditymin
    print "<h2>Maximum value</h2>"
    print tempmax
    print "<p></p>"
    print humiditymax
    print "<h2>Average value</h2>"
    print tempavg
    print "<p></p>"
    print humidityavg
    print "<hr>"

    print "<h2>In the last hour:</h2>"
    print "<table>"
    print "<tr><td><strong>Date/Time</strong></td><td><strong>Temperature</strong><td><strong>Humidity</strong></td></td></tr>"

    rows=curs.execute("SELECT datetime(timestamp, 'localtime'),temp,humidity FROM trend WHERE timestamp>datetime('now','-1 hour') AND timestamp<=datetime('now') AND room=5")
    for row in rows:
        tempstr="<tr><td>{0}&emsp;&emsp;</td><td>{1} C</td><td>{2} %</td></tr>".format(str(row[0]),str(row[1]),str(row[2]))
        print tempstr
    print "</table>"

    print "<hr>"

    conn.close()

def print_time_selector(option):

    print """<form action="templiving.py" method="POST">
        Show the temperature logs for
        <select name="timeinterval">"""


    if option is not None:

        if option == "6":
            print "<option value=\"6\" selected=\"selected\">the last 6 hours</option>"
        else:
            print "<option value=\"6\">the last 6 hours</option>"

        if option == "12":
            print "<option value=\"12\" selected=\"selected\">the last 12 hours</option>"
        else:
            print "<option value=\"12\">the last 12 hours</option>"

        if option == "24":
            print "<option value=\"24\" selected=\"selected\">the last 24 hours</option>"
        else:
            print "<option value=\"24\">the last 24 hours</option>"

        if option == "168":
            print "<option value=\"168\" selected=\"selected\">the last week</option>"
        else:
            print "<option value=\"168\">the last week</option>"

    else:
        print """<option value="6">the last 6 hours</option>
            <option value="12">the last 12 hours</option>
            <option value="24">the last 24 hours</option>
            <option value="168">the last week</option>"""

    print """        </select>
        <input type="submit" value="Display">
    </form>"""


# check that the option is valid
# and not an SQL injection
def validate_input(option_str):
    # check that the option string represents a number
    if option_str.isalnum():
        # check that the option is within a specific range
        if int(option_str) > 0 and int(option_str) <= 168:
            return option_str
        else:
            return None
    else:
        return None


#return the option passed to the script
def get_option():
    form=cgi.FieldStorage()
    if "timeinterval" in form:
        option = form["timeinterval"].value
        return validate_input (option)
    else:
        return None

# main function
# This is where the program starts
def main():

    cgitb.enable()

    # get options that may have been passed to this script
    option=get_option()

    if option is None:
        option = str(24)

    # get data from the database
    records=get_data(option)

    # print the HTTP header
    printHTTPheader()

    if len(records) != 0:
        # convert the data into a table
        table=create_table(records)
    else:
        print "No data found"
        return

    # start printing the page
    print "<html>"
    # print the head section including the table
    # used by the javascript for the chart
    printHTMLHead("Bedroom temperature and humidity trend", table)

    # print the page body
    print "<body>"
    print "<h1>Bedroom temperature and humidity trend</h1>"
    print "<hr>"
    print_time_selector(option)
    show_graph()
    show_stats(option)
    print "</body>"
    print "</html>"

    sys.stdout.flush()

if __name__=="__main__":
    main()
