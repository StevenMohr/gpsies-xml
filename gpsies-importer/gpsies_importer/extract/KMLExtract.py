'''
Created on 16.06.2012

@author: steven
'''
from lxml.etree import Element, SubElement
from lxml import etree
from gpsies_importer.geo import geo

class KMLExtract(object):
    '''
    classdocs
    '''


    def __init__(self, kml_data):
        '''
        Constructor
        '''
        self._raw_data = kml_data
        
    def analyze(self):
        root = Element("waypoints")
        data = etree.fromstring(self._raw_data)
        r = data.xpath('//kml:coordinates', namespaces={'kml':'http://www.opengis.net/kml/2.2'})
        waypoints = list()
        
        for element in r:
            text = element.text
            parts = [x.split(',') for x in text.split("\n")]
            old_geo = None
            for part in parts:
                waypoint = (part[0], part[1])
                new_geo = geo.xyz(float(part[0]), float(part[1]))
                if old_geo is None or geo.distance(new_geo, old_geo) > 25:
                    waypoints.append(waypoint)
                    old_geo = new_geo
        
        for point in waypoints:
            waypoint = SubElement(root, "waypoint")
            waypoint.attrib['latitude'] = point[0]
            waypoint.attrib['longitude'] = point[1]
           
        return root
            