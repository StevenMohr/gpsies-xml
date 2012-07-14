Spotlight on some interesting parts (Code pearls)
===================================================

GPSies schema
-----------------
.. literalinclude:: ../schema/gpsies.xsd
   :language: xml
   :linenos:


Database schema
------------------
.. literalinclude:: ../gpsies-importer/gpsies_importer/database.xsd
   :language: xml
   :linenos:


Database XSLT
----------------
.. literalinclude:: ../gpsies-importer/gpsies_importer/gpsies-internal.xsl
   :language: xslt
   :linenos:


.. literalinclude:: ../gpsies-importer/gpsies_importer/gpsies-internal-no-ns.xsl
   :language: xslt
   :linenos: 


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


