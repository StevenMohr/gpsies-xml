'''
Created on 16.06.2012

@author: steven
'''
from lxml import etree
from datetime import datetime
import pkg_resources

class TrackExtract(object):
    '''
    TrackExtract is called on every <track> element in GPSies' result set.
    '''
    
    xsl = """<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/"><foo><xsl:value-of select="track/title/text()" /></foo> </xsl:template></xsl:stylesheet>"""

    def __init__(self, track_string_xml = None, track_element_xml = None):
        '''
        Constructor
        '''
        self._raw_xml_string = track_string_xml
        self._raw_xml_element = track_element_xml
        
    def analyze(self):
        if self._raw_xml_string is not None:
            root = etree.fromstring(self._raw_xml_string)
        else:
            root = self._raw_xml_element
        xslt_root = etree.parse(open(pkg_resources.resource_filename("gpsies_importer",'gpsies-internal.xsl')))    
        #xslt_root = etree.XML(self.xsl)
        transform = etree.XSLT(xslt_root)
        result_tree = transform(root)
        result = result_tree.getroot()
        for child in result:
            if child.tag == '{https://github.com/StevenMohr/gpsies-xml/schema/database.xsd}createdDate':
                child.text = convert_gpsies2isodate(child.text)
        return result
    
    def analyze_str(self):      
        return str(self.analyze())
    
def convert_gpsies2isodate(gpsies_date):
    return datetime.strptime(gpsies_date, '%Y-%m-%d %H:%M:%S.%f').isoformat()