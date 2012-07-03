# coding=utf8
'''
Created on 16.06.2012

@author: steven
'''
import unittest
from gpsies_importer.extract.TrackExtract import TrackExtract, convert_gpsies2isodate


class TrackExtractTestCase(unittest.TestCase):

    def test_analyze(self):
        test_data = """<track>
            <title>Panoramaweg Baden Baden</title>
            <fileId>zsabowayjvnikrqi</fileId>
            <createdDate>2006-12-05 15:26:05.0</createdDate>
            <description>Der erste Streckenabschnitt führt durch maechtige Buchenwaelder..</description>
            <startPointLat>48.7736479</startPointLat>
            <startPointLon>8.22421099</startPointLon>
            <endPointLat>48.7628189</endPointLat>
            <endPointLon>8.26425997</endPointLon>
            <startPointCountry>DE</startPointCountry>
            <endPointCountry>DE</endPointCountry>
            <trackLengthM>6357.6450136697395</trackLengthM>
            <countTrackpoints>114</countTrackpoints>
            <externalLink>http://www.swr.de/aktiv/wandern/touren/beitrag8.html</externalLink>
            <altitudeMinHeightM>150</altitudeMinHeightM>
            <altitudeMaxHeightM>338</altitudeMaxHeightM>
            <altitudeDifferenceM>188</altitudeDifferenceM>
            <totalAscentM>402</totalAscentM>
            <totalDescentM>251</totalDescentM>
            </track> """
        track_extract = TrackExtract(track_string_xml = test_data)
        result_xml = track_extract.analyze(False)
        assert len(result_xml) > 0
        
    def test_convert_gpisies2isodate(self):
        test_string = "2006-12-05 15:26:05.0"
        expected_result= "2006-12-05T15:26:05"
        assert convert_gpsies2isodate(test_string) == expected_result

if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()