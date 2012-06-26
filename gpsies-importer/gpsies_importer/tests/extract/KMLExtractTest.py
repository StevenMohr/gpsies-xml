# coding=utf8
'''
Created on 16.06.2012

@author: Steven Mohr
'''

import unittest
from gpsies_importer.extract.KMLExtract import KMLExtract 
from lxml import etree
import pkg_resources 

class KMLExtractTestCase(unittest.TestCase):
    test_kml = """<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><Placemark><name>Zürich</name><description>Zürich</description> <Point><coordinates>8.55,47.3666667,0</coordinates></Point></Placemark></Document></kml>"""

    def test_analyze(self):
        analyze = KMLExtract(self.test_kml)
        result = analyze.analyze()
        self.assertGreater(len(result), 0, 'Result tree is empty!')
        self.assertEqual(etree.tostring(result), '<ns0:waypoints xmlns:ns0="https://github.com/StevenMohr/gpsies-xml/schema/database.xsd"><ns0:waypoint longitude="8.55" latitude="47.3666667"/></ns0:waypoints>', 'waypoint sub-tree incorrect')
        
    def test_analyze_long(self):
        analyze = KMLExtract(open(pkg_resources.resource_filename("gpsies_importer.tests.extract","54KmTeltowkanal.kml")).read())
        result = analyze.analyze()
        assert len(result) > 0  

if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()