<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/topic-types/graphic-record"
    xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
    exclude-result-prefixes="#all" version="2.0">
    
    <xsl:template match="gr:href">
        <xsl:param name="graphic-record-file-uri" tunnel="yes"/>
        <gr:href>
            <xsl:value-of select="resolve-uri(., $graphic-record-file-uri)"/>
        </gr:href>
    </xsl:template>

    <xsl:template match="gr:*">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:copy/>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    



</xsl:stylesheet>