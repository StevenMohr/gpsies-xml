# coding=utf8
'''
Created on 16.06.2012

@author: Steven Mohr
'''

import unittest
from gpsies_importer.extract.KMLExtract import KMLExtract 
from lxml import etree

class KMLExtractTest(unittest.TestCase):
    test_kml = """<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><Placemark><name>Zürich</name><description>Zürich</description> <Point><coordinates>8.55,47.3666667,0</coordinates></Point></Placemark></Document></kml>"""

    def testAnalyze(self):
        analyze = KMLExtract(self.test_kml)
        result = analyze.analyze()
        assert len(result) > 0
        assert etree.tostring(result) == '<waypoints><waypoint latitude="8.55" longitude="47.3666667"/></waypoints>'
        
    def testAnalyzeLong(self):
        analyze = KMLExtract(open("54KmTeltowkanal.kml").read())
        result = analyze.analyze()
        assert len(result) > 0  
    
    def testCleanData(self):
        pass

if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()