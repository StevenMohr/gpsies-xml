Spotlight on some interesting parts (Code pearls)
===================================================

GPSies schema
-----------------
The following code shows the "schema" of the responses of GPSies.org. As you can see, most of the elements are optional. They are available if the user made some entries to the specific topics.

.. literalinclude:: ../schema/gpsies.xsd
   :language: xml
   :linenos:


Database schema
------------------
The following schema shows the structure of the track documents as they are stored in our database. We adopted the GPSies.org schema for our needs and added some more types to it like a "real" date time format. As we also store the KML waypoints in this documents we created a waypoint type to store waypoints. We also added a type for POIs which are also stored in this document after they were loaded.

.. literalinclude:: ../gpsies-importer/gpsies_importer/database.xsd
   :language: xml
   :linenos:


Database XSLT
----------------
We use XSLT to transform the GPSies.org document to our own internal format. Because of some problems with our SPARQL client there are two versions of the XSLT stylesheets: One with namespaces:

.. literalinclude:: ../gpsies-importer/gpsies_importer/gpsies-internal.xsl
   :language: xslt
   :linenos:

and one without namespaces:

.. literalinclude:: ../gpsies-importer/gpsies_importer/gpsies-internal-no-ns.xsl
   :language: xslt
   :linenos: 

The only difference is that the second does not declare a gps namespace and does not set a standard namespace for the document.
The crawler has an option which allows to create both of them but the portal only works with the no namespaces version.

Querying the database
--------------------------

The model code for the Track model resides in gpsies-xml-gui/app/model/track.rb. However, the code is merely complex, yet we want to present the XQuery line that primarily selects a defined track which is one central aspect of the functionality.

.. literalinclude:: codepearls/ruby/track_select.rb
    :language: ruby
    :linenos:


What you can see here is the XQuery query line generation that is later sent to the basex database. XQuery is a language to select nodes in a XML structure, that match certain criteria.

This query selects all nodes that match certain criteria given in the where_clauses structure.

A main concept is recomposition of the database XML structure. One track in the database might hold very much track nodes. Querying, loading and transmitting these might take a lot of time. Therefor (starting in line 17) found tracks are being restructured. The original XML structure is loaded and only needed information parts are transfered into the result set.


.. _sparql:

SPARQL query
---------------

If there a no Point of Interests for a track saved in our BaseX-database, they are fetched from the SPARQL-endpoint at DBPedia:

This process basically consists of 4 parts:

*   Retrieve waypoints from XML-database
*   Filter and transform waypoints
*   Query DBPedia
*   Insert Point of Interests into XML-database
  

.. literalinclude:: codepearls/sparql/fetch_POIs.rb
   :language: ruby
   :linenos: 

First of all all waypoints corresponding to a track are loaded from our XML-Database: 

.. literalinclude:: codepearls/sparql/get_waypoints.rb
   :language: ruby
   :linenos:

The waypoints (still in XML-format) are then filtered (we use only every 20th point to increase perfomance and avoid too many geographic overlaps) and stored in a array of hashes. 


.. literalinclude:: codepearls/sparql/create_coord_array.rb
   :language: ruby
   :linenos:

The heart of our SPARQL-application is the querybuilder, which takes an array of coordinate-hashes and forms a valid SPARQL-query. This query retrieves all objects from DBPedia
with associated geodata that are located in the proximity (defined by the interval paramater) of one of the passed waypoints. The only type of RDF-resource that is excluded are
city-quarters.

.. literalinclude:: codepearls/sparql/querybuilder.rb
   :language: ruby
   :linenos:

The get_POIs-function sends multiple queries to the DBPedia SPARQL-Endpoint. Ten waypoints at a time are grouped together and included in one query using the aforementioned querybuilder.
The results of the requests (the Point of Interests) are then transformed into an XML-result including a link to the English Wikipedia page, a title as well as longitude and latitude
coordinates.

.. literalinclude:: codepearls/sparql/get_POIs.rb
   :language: ruby
   :linenos:

Finally the Point of Interests are saved in our XML-database, to improve the future performance of the track page.

.. literalinclude:: codepearls/sparql/insert_POIs.rb
   :language: ruby
   :linenos:


