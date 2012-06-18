'''
Created on 11.06.2012

@author: Steven Mohr
'''

import argparse
from urllib2 import *
from threading import Thread
from lxml import etree
from extract.TrackExtract import TrackExtract
from gpsies_importer.extract.KMLExtract import KMLExtract
from gpsies_importer.basex_api import BaseXClient 
from Crypto.Cipher import DES

URL_PATTERN = u"http://www.gpsies.org/api.do?key={api_key}&country=DE&limit=100&resultPage={page}&trackTypes=jogging&filetype=kml"
PORT = 1984

class GPiesQuery(object):
    def query(self, db_server_name, db_server_user, db_server_password, api_key, **kwargs):
        session = BaseXClient.Session(db_server_name, PORT, db_server_user, db_server_password)
        for page in range(2, 1000):
            connection = urlopen(URL_PATTERN.format(api_key=api_key, page=page), timeout=10)
            answer = connection.read()
            root = etree.fromstring(answer)
            analyze_all_tracks(root, session)
            connection.close()
        session.close()

class FileQuery(object):
    def query(self, db_server_name, db_server_user, db_server_password, file, **kwargs):
        try:
            session = BaseXClient.Session(db_server_name, PORT, db_server_user, db_server_password)
            file = open(file)
            
            # Sanitization of input file if more than one GPSies query is saved in file.
            tmp_file = os.tmpfile()
            first_xml = True
            first_gps = True
            for line in file:
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
            analyze_all_tracks(root, session)  
        except IOError as e:
            print e
            
def analyze_all_tracks(root_element, session):
    tracks = root_element.xpath("//track")
    print tracks
    session.execute("open database2")

    for i, track in enumerate(tracks):
        print i
        analyze_track(track, session)
      
def analyze_track(track, session):
    try:
        dLink = None
        downloadLinks = track.xpath("//downloadLink/text()")
        
        trackXML = TrackExtract(track_element_xml = track ).analyze() 
        id = trackXML.xpath("//uid/text()")[0]
        for link in downloadLinks:
            if id in link:
                dLink = link
                break
        print dLink  
        connection = urlopen(dLink, timeout=10)
        answer = connection.read()
        connection.close()
        waypoints = KMLExtract(answer).analyze()
        trackXML.getroot().append(waypoints)
        result = etree.tostring(trackXML.getroot())
        session.add('database2/tracks', result)
        print result
    except IOError as e:
        print e

def main():
    parser = argparse.ArgumentParser(description='Queries gpsies.org for tracks and saves them.')
    basex_group = parser.add_argument_group(description="Arguments for BaseX db access")
    basex_group.add_argument("db_server_name", help="Address of BaseX server")
    basex_group.add_argument("db_server_user", help="User name for BaseX server")
    basex_group.add_argument("db_server_password", help="Password for BaseX server")
    net_group = parser.add_argument_group(description="Arguments for network access")
    net_group.add_argument('api_key', help="Key to access GPSies.org")
    
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
    
