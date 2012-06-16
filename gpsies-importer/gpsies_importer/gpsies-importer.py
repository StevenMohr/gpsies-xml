'''
Created on 11.06.2012

@author: Steven Mohr
'''
from urllib2 import *
from threading import Thread
from lxml import etree
from extract.TrackExtract import TrackExtract
from gpsies_importer.extract.KMLExtract import KMLExtract
from gpsies_importer.basex_api import BaseXClient 

URL_PATTERN = u"http://www.gpsies.org/api.do?key={api_key}&country=DE&limit=100&resultPage={page}&trackTypes=jogging&filetype=kml"

def parse_answer(answer):
    print answer

def main():
    threads = list()
    api_key = sys.argv[1]
    for page in range(500, 1000):
        connection = urlopen(URL_PATTERN.format(api_key=api_key, page=page), timeout=10)
        answer = connection.read()
        
        print answer
        #answer.join()
        #if answer is not None:
        #    thread = Thread(target = parse_answer, args=(answer))
        #    threads.append(thread)
        #    thread.start()
        connection.close()
    #print "Waiting for threads to join ..."    
    #for thread in threads:
    #    thread.join()
      
def analyze_track(track, session):
    try:
        downloadLink = track.xpath("//downloadLink/text()") 
        id = track.xpath("//fileId/text()")[0]
        trackXML = TrackExtract(track_element_xml = track ).analyze()   
        connection = urlopen(downloadLink[0], timeout=10)
        answer = connection.read()
        connection.close()
        waypoints = KMLExtract(answer).analyze()
        trackXML.getroot().append(waypoints)
        session.add('tracks/' + id, etree.tostring(trackXML.getroot()))
    except Error, e:
        print e
    
        
def mainFromFile():
    session = BaseXClient.Session('192.168.1.2',1984,'admin','admin')
    session.execute("open database2")
    file = open("data3.xml")
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
    tracks = root.xpath("//track")
    print len(tracks)
    try:
        for i, track in enumerate(tracks):
            if i%100 == 0:
                print i
                session.close()
                session = BaseXClient.Session('192.168.1.2',1984,'admin','admin')
                session.execute("open database2")
            analyze_track(track, session)
        session.execute("close")
        session.close()
    except Error, e:
        print e
    
if __name__ == "__main__":
    mainFromFile()
