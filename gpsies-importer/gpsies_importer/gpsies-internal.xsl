<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" />
    <xsl:template match="/">
    	<track>
                    <uid><xsl:value-of select="track/fileId"/></uid>
                    <title><xsl:value-of select="track/title"/></title>
                    <description><xsl:value-of select="track/description"/></description>
                    <createdDate><xsl:value-of select="datetime(xsd:date(substring(track/datetime,1,10)), xsd:time(substring(track/createdDate, 12, 8))"/></createdDate>
                    <trackLength><xsl:value-of select="track/trackLengthM"/></trackLength>
                    <altitudeMinHeight><xsl:value-of select="track/altitudeMinHeightM"/></altitudeMinHeight>
                    <altitudeMaxHeight><xsl:value-of select="track/altitudeMaxHeightM"/></altitudeMaxHeight>
                    <totalAscent><xsl:value-of select="track/totalAscentM"/></totalAscent>
                    <totalDescent><xsl:value-of select="track/totalDescentM"/></totalDescent>
                   </track>
    </xsl:template>
</xsl:stylesheet>