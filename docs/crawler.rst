GPSies Importer
================

Our GPSies Importer is a Python program that queries GPSies for tracks, downloads the corresponding waypoint data (KML files) and saves track information and waypoints to a BaseX database.

The importer has its own installer (a standard Python setup.py script) which takes care of the needed dependencies and install the gpsies-import script.

Install the importer
---------------------
Installation is quite easy, just type::

  python setup.py install   

This will install lxml (if needed) and add the script to your path.

To check if everything is installed correctly, use ::

  python setup.py test

to run some tests that will fail if your installation is incorrect.


Using the importer
----------------------
In order to get a first overview about the different options on using the importer just use the help function::
  
  gpsies-import --help

which will show you this help page::

    usage: gpsies-import [-h] [-d DATABASE] [-p START_PAGE] [-n NUM_PAGES]
                       [--file FILE]
                       db_server_name db_server_user db_server_password api_key

    Queries gpsies.org for tracks and saves them.

    optional arguments:
    -h, --help            show this help message and exit

    Arguments for BaseX db access

    db_server_name        Address of BaseX server
    db_server_user        User name for BaseX server
    db_server_password    Password for BaseX server
    -d DATABASE, --database-name DATABASE
                          Name of database to use

    Arguments for network access

    api_key               Key to access GPSies.org
    -p START_PAGE, --page START_PAGE
                          The query is splitted in pages of 100 items. Which
                          page should be the first to use?
    -n NUM_PAGES, --num NUM_PAGES
                          Number of pages to use

    Arguments for reading from file
    --file FILE, -f FILE  Read GPSies.org response from file instead of quering
                          web service.

Examples
++++++++++

Let's assume that your BaseX server is installed using the default configuration (port: 1984, user name: admin, password: admin) on localhost with a database named 'database3'. In order to crawl GPSies.org for 100,000 tracks (with is the default amount of tracks) you will use the import like this::

  gpsies-import localhost admin admin -d database3



