import unittest
from gpsies_importer.tests.extract.KMLExtractTest import KMLExtractTestCase
from gpsies_importer.tests.extract.TrackExtractTest import TrackExtractTestCase

def test_all():
    suite = unittest.TestSuite()
    suite.addTest(KMLExtractTestCase('test_analyze'))
    suite.addTest(KMLExtractTestCase('test_analyze_long'))
    suite.addTest(TrackExtractTestCase('test_analyze'))
    suite.addTest(TrackExtractTestCase('test_convert_gpisies2isodate'))
    return suite