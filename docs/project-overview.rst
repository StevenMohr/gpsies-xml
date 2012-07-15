Project overview
=================

The project consists of two main parts: First of all an import script that queries tracks and its corresponding waypoints
from GPSies and saves them in a BaseX database. The second part is a web app that allows to query these tracks and enriches
them with Points of Interest (POI) from dbPedia and tweets about these POIs.

.. image:: /_static/tech-overview.png
   :scale: 50%


General setup
===============
This guide will show you how to prepare your Ubuntu 12.04 server for the installation of our project.
Although we are describing which packages you need for the single components you can just copy the bash line below and
you will be fine. ::

  sudo apt-get install build-essentials python-dev python-setuptools python-virtualenv libxslt-dev libxml2-dev ruby1.9.1 ruby1.9.1-dev git-core basex python-sphinx


Checkout the master branch of our project
--------------------------------------------
Just run::

  git clone https://github.com/StevenMohr/gpsies-xml.git

and you're done

Create an isolated Python environment
-----------------------------------------
In order to create an isolatd Python environment to install the crawler run::
  virtualenv --system-site-packages xml-env
  source xml-env/bin/activate

The last command activates this environment so that all python calls will be processed by the Python interpreter in this directory. You have to rerun this command everytime you want to use the crawler or generate the documentation.

Setup BaseX
---------------
We use BaseX as our XML database and so you need to configure it before can use the project.
Start the server with::
  
  basexserver -s

And connect to the server using::
  
  basexclient

with admin as user name and password. All you have to do to prepare BaseX for the project is to create a database::
  
  create database database2

After the database was created you can leave the BaseX client with::
  
  exit

Next steps
-------------
Now you can proceed with the steps to install the crawler and the portal (GUI, graphical user interface) in the corresponding chapters.

How to generate this document?
-----------------------------------
In order to generate this document you have to make sure that you activated the isolated Python environment::
  
  source xml-env/bin/activate

If you haven't installed the crawler yet, you will get some warnings while generating the documentation.
Switch to the docs folder in your checkout of our project and run::

  make html

in order to get a HTML version of the documentation or run::
  
  make

to get an overview about all available targets.
