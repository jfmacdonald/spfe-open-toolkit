<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:gr="http://spfeopentoolkit.org/ns/eppo-simple/objects/graphics"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all" version="2.0">

    <!-- Make sure that the graphic href is an absolute URI so that we know where to copy it from -->
    <xsl:template match="graphic">
        <!-- FIXME: is this regex smart enough? -->
        <!-- FIXME: Stop this from reloading the source file -->
 
        <!-- Need to do matches before replace here because replace returns the original string if no match. -->
        <xsl:variable name="graphic-record-file" select="if (matches(@href, '(.+)\.[a-zA-Z0-9]+$')) then replace(@href,'(.+)\.[a-zA-Z0-9]+$','$1.xml') else ''"/>

        <!-- check that $graphic-record-file has content or this will return base URI of source file -->
        <xsl:variable name="graphic-record-file-uri"
            select="if ($graphic-record-file ne '') then resolve-uri($graphic-record-file, base-uri(.)) else 'NONE'"/>
        <xsl:choose>
            <!-- The graphic is specified by uri - an identifier, not a location -->
            <xsl:when test="@uri=$config/config:graphic-record/config:uri">
                <!-- FIXME: Test for named graphic. To be implemented. -->
            </xsl:when>       
            
            <!-- There is a graphic record file the matches the name of the graphic specified in an href -->
            
            <xsl:when test="doc-available($graphic-record-file-uri)">
                <xsl:variable name="graphic-record" select="document($graphic-record-file-uri)"/>
                <xsl:apply-templates select="$graphic-record">
                    <xsl:with-param name="graphic-record-file-uri" select="$graphic-record-file-uri" tunnel="yes"/>
                </xsl:apply-templates>       
            </xsl:when>
            
            <!-- The graphic is specified in an href -->
            <xsl:when test="@href">
                <xsl:call-template name="sf:warning">
                    <xsl:with-param name="message">
                        <xsl:text>No graphic record found for fig </xsl:text>
                        <xsl:choose>
                            <xsl:when test="@uri">
                                <xsl:value-of select="@uri"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>.</xsl:text>
                    </xsl:with-param>
                    <xsl:with-param name="in">
                        <xsl:value-of select="ancestor::*/head/id"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:for-each select="@*[not(name()='href')]">
                    <xsl:copy/>
                </xsl:for-each>
                <gr:graphic-record>
                    <gr:formats>
                        <gr:format>
                            <gr:type>
                                <xsl:value-of select="replace(@href, '.+\.([^/\.\\]+)$', '$1')"/>
                            </gr:type>
                            <gr:href>
                                <xsl:value-of select="resolve-uri(@href, base-uri(.))"/>
                            </gr:href>
                        </gr:format>
                    </gr:formats>
                </gr:graphic-record>
                <xsl:apply-templates/>                
            </xsl:when>            
            <xsl:otherwise>
                <!-- FIXME: What is the case here? -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    

</xsl:stylesheet>
