'''
Created on 11.06.2012

@author: Steven Mohr
'''

import argparse
import os
import pkg_resources
from urllib2 import urlopen
from lxml import etree
from extract.TrackExtract import TrackExtract
from gpsies_importer.extract.KMLExtract import KMLExtract
from gpsies_importer.basex_api import BaseXClient

URL_PATTERN = u"http://www.gpsies.org/api.do?key={api_key}&country=DE&limit=100&resultPage={page}&trackTypes=jogging&filetype=kml"

class GPiesQuery(object):
    def query(self, db_server_name, db_server_user, db_server_password, api_key, database, use_namespaces, start_page, num_pages,port, **kwargs):
        session = BaseXClient.Session(db_server_name, port, db_server_user, db_server_password)
        session.execute("open " + database)
        try:
            track_analyzer = TrackAnalyzer(session)
            for page in range(start_page, start_page + num_pages):
                connection = urlopen(URL_PATTERN.format(api_key=api_key, page=page), timeout=10)
                answer = connection.read()
                root = etree.fromstring(answer)
                track_analyzer.analyze_all_tracks(root, use_namespaces)
                connection.close()
        finally:
            session.close()

class FileQuery(object):
    def query(self, db_server_name, db_server_user, db_server_password, database, file, port, use_namespaces, **kwargs):
        try:
            session = BaseXClient.Session(db_server_name, port, db_server_user, db_server_password)
            session.execute("open " + database)
            track_analyzer = TrackAnalyzer(session)
            file_object = open(file)
            
            # Sanitization of input file if more than one GPSies query is saved in file.
            tmp_file = os.tmpfile()
            first_xml = True
            first_gps = True
            for line in file_object:
                if line.startswith("<?xml"):
                    if first_xml:
                        tmp_file.write(line)
                        first_xml = False
                        continue
                elif line.startswith("</gps"):
                    pass
                elif line.startswith("<gps"):
                    if first_gps:
                        tmp_file.write(line)
                        first_gps = False
                else:
                    tmp_file.write(line)
            tmp_file.write("</gpsies>")
            tmp_file.flush()
            tmp_file.seek(os.SEEK_SET, 0)
            root = etree.parse(tmp_file)
            track_analyzer.analyze_all_tracks(root, use_namespaces)  
        except IOError as e:
            print e

class TrackAnalyzer(object):
    def __init__(self, session):
        xsd_file = etree.parse(open(pkg_resources.resource_filename("gpsies_importer", "database.xsd")))
        self._xsd_schema = etree.XMLSchema(xsd_file)
        self._session = session
                    
    def analyze_all_tracks(self, root_element, namespaces):
        tracks = root_element.xpath("//track")
        print tracks

        for i, track in enumerate(tracks):
            print i
            self._analyze_track(track, namespaces)
      
    def _analyze_track(self, track, namespaces):
        ns_dict = {'gps' : 'https://github.com/StevenMohr/gpsies-xml/schema/database.xsd'}
        try:
            dLink = None
            downloadLinks = track.xpath("//downloadLink/text()")
            
            trackXML = TrackExtract(track_element_xml = track ).analyze(namespaces)
            if namespaces: 
                id = trackXML.xpath("//gps:uid/text()", namespaces = ns_dict)[0]
            else:
                id = trackXML.xpath("//uid/text()")[0]
            for link in downloadLinks:
                if id in link:
                    dLink = link
                    break
            connection = urlopen(dLink, timeout=10)
            answer = connection.read()
            connection.close()
            waypoints = KMLExtract(answer).analyze(namespaces)
            trackXML.append(waypoints)
            # self._xsd_schema.assertValid(trackXML) Uncomment to get description of validation errors
            if (not namespaces) or (self._xsd_schema.validate(trackXML)): # Only validate if namespaces is true
                result = etree.tostring(trackXML)
                self._session.add('database2/tracks', result)
            else:
                print "Validation failed: " + etree.tostring(trackXML)
        except IOError as e:
            print e

def main():
    parser = argparse.ArgumentParser(description='Queries gpsies.org for tracks and saves them.')
    
    parser.add_argument("--no-namespaces", help="Do not use own namespace for XML",
                        action="store_false", dest="use_namespaces", default=True)
    
    basex_group = parser.add_argument_group(description="Arguments for BaseX db access")
    basex_group.add_argument("db_server_name", help="Address of BaseX server")
    basex_group.add_argument("db_server_user", help="User name for BaseX server")
    basex_group.add_argument("db_server_password", help="Password for BaseX server")
    basex_group.add_argument("--port", help="Port of BaseXServer", dest="port", type=int, default=1984) 
    basex_group.add_argument("-d", "--database-name", dest="database", help="Name of database to use", default="database2")
    
    net_group = parser.add_argument_group(description="Arguments for network access")
    net_group.add_argument('api_key', help="Key to access GPSies.org")
    net_group.add_argument('-p', '--page', type=int, dest="start_page", default="1", help="The query is splitted in pages of 100 items. Which page should be the first to use?")
    net_group.add_argument('-n', '--num', type=int, dest="num_pages", default=1000, help="Number of pages to use")
    
    file_group = parser.add_argument_group(description="Arguments for reading from file")
    file_group.add_argument('--file', '-f', help="Read GPSies.org response from file instead of quering web service.")
    
    args = parser.parse_args()
    query_parser = None
    if args.file is not None:
        query_parser = FileQuery()
    else:
        query_parser = GPiesQuery()
    
    query_parser.query(**vars(args))    
        
if __name__ == "__main__":
    main()
    
