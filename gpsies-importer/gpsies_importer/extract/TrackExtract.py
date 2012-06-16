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

    def __init__(self, track_xml):
        '''
        Constructor
        '''
        self._raw_xml = track_xml
        
    def analyze(self):
        root = etree.fromstring(self._raw_xml)
        xslt_root = etree.XML(self.xsl)
        transform = etree.XSLT(xslt_root)
        result_tree = transform(root)
        return str(result_tree)