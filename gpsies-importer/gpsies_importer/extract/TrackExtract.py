'''
Created on 16.06.2012

@author: steven
'''
from lxml import etree

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
        xslt_root = etree.parse(open('gpsies-internal.xsl'))    
        #xslt_root = etree.XML(self.xsl)
        transform = etree.XSLT(xslt_root)
        result_tree = transform(root)
        return result_tree
    
    def analyze_str(self):      
        return str(self.analyze())