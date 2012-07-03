XML GUI
===============

Installation 
------------



Prerequisites
+++++++++++++

First of all, please don't mess with Windows, please install the environment on Windows. We don't fully support Windows.

We run the graphical user interfacse with ruby on rails. You may do the following things do install the dependency package enforcement system (we use ruby's bundler):

Code::

    # Install a very recent version or ruby.
    # Double check that you don't have ruby versions < 1.9.x installed.
    sudo apt-get install ruby1.9.1 ruby1.9.1-dev
    
    # this should install "gem" as well, if so, continue below, IF NOT, see if you can pull gem by: sudo apt-get install rubygems

    # Install 
    gem install bundler

Now you've basically set up the dependency enforcement system. Please continue by installing the ruby on rails dependencies themselves:

Code::

    # change to the gui directory (if you're not already in there)
    cd gpsies-xml-gui

    # install the dependencies for the ruby on rails gui:
    bundle install

This will install all the dependencies that are defined in our Gemfile. You MIGHT have some build issues here. This is your system and not ruby's fault. See the last line of the stderr output or the config log, these errors are often easy to fix by installing the failing libraries \*-dev package. For example, we had issues with the v8 javascript library and json, we fixed them by typing (won't hurt to have them installed either way):

Code::

    sudo apt-get install libv8-dev ruby-json

Running the GUI
+++++++++++++++

By now, you should have ruby, the bundler and all our dependencies, including Rails itself set up. If that's really the case, you can start up the rails server by typing 

Code::

    rails server

If all goes well, the server will fire up by printing out some status lines. Now, open up your browser and hit the URL http://localhost:3000/ - and start praying. If something goes wrong, there's probably something wrong with the database connection. Make sure you have the ../config/basex.rb file properly set up to be able to connect to your database.


Using the GUI
+++++++++++++

We tried to focus on ease of use. Once you open up the main page you'll be able to search for tracks. Hit "Berlin" in there and see what comes out of the database. Once you get the listing of available tracks (if there are any), click on "Details" to see the track details, including a list of points of interests, a map and some tweets that were sent from that area.
