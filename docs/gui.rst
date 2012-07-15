Graphical User Interface
========================

Installing the GUI 
------------------

First of all, please don't mess with Windows, it's recommended to install the environment on Linux. We don't fully support Windows.

We run the graphical user interfacse with ruby on rails. You may do the following things do install the dependency package enforcement system (we use ruby's bundler):

Code::

    # Install a very recent version or ruby.
    # Double check that you don't have ruby versions < 1.9.x installed.
    sudo apt-get install ruby1.9.1 ruby1.9.1-dev
    
    # this should install "gem" as well, if so, continue below
    # IF NOT, see if you can pull gem by: sudo apt-get install rubygems

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

Using the GUI
-------------

By now, you should have ruby, the bundler and all our dependencies, including Rails itself set up. If that's really the case, you can start up the rails server by typing 

Code::

    rails server

If all goes well, the server will fire up by printing out some status lines. Now, open up your browser and hit the URL http://localhost:3000/ - and start praying. If something goes wrong, there's probably something wrong with the database connection. Make sure you have the ../config/basex.rb file properly set up to be able to connect to your database.

We tried to focus on ease of use. Once you open up the main page you'll be able to search for tracks. Hit "Berlin" in there and see what comes out of the database. Once you get the listing of available tracks (if there are any), click on "Details" to see the track details, including a list of points of interests, a map and some tweets that were sent from that area.


Code Aspects
------------

The graphical user interface is fully implemented in `Ruby on Rails <http://www.rubyonrails.org>`_. In the following chapter we're focussing on some coding aspects, mainly regarding the XML parts of the implementation.

However, the rails framework needs to be discussed in some words: Ruby on Rails (we're relying on the very recent version v3.2) is a modern web framework that enforces the Model-View-Controller (MVC) design pattern. This simplifies the seperation of content and logics.

As the name suggests, Ruby on Rails uses ruby as backing programming language, but also domain specific languages like ERB (a mix between HTML and ruby) for rendering the Views and SCSS for easier stylesheets management are used in the technology stack.

All the XML work is done inside the Ruby on Rails models code, as the MVC pattern suggests all database work to be done in the model code.

The whole GUI code (i.e. the RoR application itself) can be found in the gpsies-xml-gui/ path.

Ruby on Rails reflects the seperation of concerns (models, views, controllers) in the respective subdirectories under app/ in the root directory of the RoR project.

One interesting aspect of MVC is, that all segments of the functionality are logically seperated, in fact, we only use one logical entitiy, i.e. the model of a "Track". Therefor we only need a TrackController which can be found under app/controllers/track_controller.rb. However, each track has some subconcepts, such as Points of Interests. These conceptual ideas are represented in the app/models/ directory.

We have a :ref:`code pearls <codepearls>` section in this documentation. You can find :ref:`some model code <codepearls_basex_query>` (with focus on the XQuery concept) there.

Query Forms and presentation of found tracks
++++++++++++++++++++++++++++++++++++++++++++

The rendering of HTML forms (for querying) and HTML tables (for listing found tracks) is one of the mere unfascinating parts of the application. The TrackController's index and show methods invoke the respective views under app/views/track/[index|show].html.erb. These files simply render HTML5 with passed tracks-data. See all \*.html.erb files below app/views/ to gain deeper understanding of how the rendering engine in our application works.

Query Processing: BaseX communication
+++++++++++++++++++++++++++++++++++++

All basex database communication (i.e. querying for tracks) is done in the app/models/track.rb as this is the concern of the Track model code.

If a user queries for a track, he or she will put a keyword into the query form on the application's main website http://localhost:3000/. This keyword is passed to the controller which in fact passes it to the model code. The model code communicates with the database to find matching tracks. Those are given back to the controller who passes them to the renderer ("view").

Generally, we need two implementations of a query functionality. First, we need to be able to query for a keyword (just for users being able to  "search for tracks"), second, we need to be able to query for the ID, that uniquely identifies each track. This is necessary to be able to select a single track (i.e. to open up the details page).

These two methods are defined as class methods in the app/models/track.rb file inside the Track model concept. We added recomposition (for performance improvements) and pagination/result limitation support (for usability issues) to those query methods.

PoI-Enrichment via dbpedia and SparQL
+++++++++++++++++++++++++++++++++++++

Each track detail site is enriched by Point of Interests retrieved from DBPedia. As direct querying to DBPedia can take quite some time (especially for long tracks), these POIs are stored 
in the BaseX-database. They are also paginated (in groups of 5) to further increase performance.

Only if there are no Point of Interests found in our database, the SPARQL-Endpoint at DBPedia is queried. See :ref:`sparql` for detailed information about this process. 

PoI-Enrichment via Twitter
++++++++++++++++++++++++++

TODO Tobias? Issue #50
