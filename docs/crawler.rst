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
