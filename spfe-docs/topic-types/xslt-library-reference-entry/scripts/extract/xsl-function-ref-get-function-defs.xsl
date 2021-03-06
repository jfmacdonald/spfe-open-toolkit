<?xml version="1.0" encoding="UTF-8"?>
    <!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
    <!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns="http://spfeopentoolkit.org/spfe-docs/extraction/xslt-function-definitions"
    exclude-result-prefixes="#all"
    version="2.0"
    >
   
  <!--  <xsl:output indent="yes" xpath-default-namespace="http://spfeopentoolkit.org/spfe-docs/extraction/xslt-function-definitions"/>
-->    
    <xsl:variable name="config" as="element(config:config)">
        <xsl:sequence select="/config:config"/>
    </xsl:variable>
    
    <xsl:param name="topic-set-id"/>
    
    <xsl:param name="sources-to-extract-content-from"/>
    <xsl:variable name="xslt-file-set" select="sf:get-sources($sources-to-extract-content-from)"/>
    
    <xsl:template name="main" >
        <!-- Create the root "extracted-content element" -->
        <xsl:result-document href="file:///{concat($config/config:content-set-build, '/topic-sets/', $topic-set-id, '/extract/out/function-and-template-definitions.xml')}" method="xml" indent="no" omit-xml-declaration="no">
            <function-and-template-definitions>
                <xsl:apply-templates select="$xslt-file-set"/>
            </function-and-template-definitions>
        </xsl:result-document>
    </xsl:template>
        
    <xsl:template match="xsl:*">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*/text()"/>
    
    <xsl:template match="xsl:function[namespace-uri-for-prefix(substring-before(@name, ':'), .) = 'http://spfeopentoolkit.org/spfe-ot/1.0/functions']">
        <function-definition>
            <name>
                <xsl:value-of select="substring-after(@name, ':')"/>
            </name>
            <local-prefix>
                <xsl:value-of select="substring-before(@name, ':')"/>
            </local-prefix>
            <return-type>
                <xsl:value-of select="if (@as) then @as else 'item()*'"/>
            </return-type>
            <source-file>
                <xsl:value-of select="base-uri()"/>
            </source-file>
            <namespace-uri>
                <xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
            </namespace-uri>
            <parameters>
                <xsl:for-each select="xsl:param">
                    <parameter>
                        <name><xsl:value-of select="@name"/></name>
                        <type><xsl:value-of select="if (@as) then @as else 'item()*'"/></type>
                    </parameter>
                </xsl:for-each>
            </parameters>
            <definition>
                <xsl:sequence select="." exclude-result-prefixes="#all"/>
            </definition>
        </function-definition>
    </xsl:template>
    
    <!-- Find named templates that are in the http://spfeopentoolkit.org/spfe-ot/1.0/functions namespace -->
    <xsl:template match="xsl:template[namespace-uri-for-prefix(substring-before(@name, ':'), .) = 'http://spfeopentoolkit.org/spfe-ot/1.0/functions']">
        <template-definition>
            <name>
                <xsl:value-of select="substring-after(@name, ':')"/>
            </name>
            <local-prefix>
                <xsl:value-of select="substring-before(@name, ':')"/>
            </local-prefix>
            <source-file>
                <xsl:value-of select="base-uri()"/>
            </source-file>
            <namespace-uri>
                <xsl:value-of select="namespace-uri-for-prefix(substring-before(@name, ':'), .)"/>
            </namespace-uri>
            <parameters>
                <xsl:for-each select="xsl:param">
                    <parameter>
                        <name><xsl:value-of select="@name"/></name>
                        <type><xsl:value-of select="if (@as) then @as else 'item()*'"/></type>
                    </parameter>
                </xsl:for-each>
            </parameters>
            <definition>
                <xsl:sequence select="." exclude-result-prefixes="#all" />
            </definition>
        </template-definition>
    </xsl:template>    
   

    

</xsl:stylesheet>