<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	exclude-result-prefixes="#all">
	
	<!-- topic -->
	<xsl:template match="es:think-plan-do-topic">
		<xsl:choose>
			<xsl:when test="$media='online'"> 
				<page status="{es:head/es:history/es:revision[last()]/es:status}" name="{ancestor::ss:topic/@local-name}">
					<xsl:call-template name="show-header"/>
					<xsl:apply-templates /> 
					<xsl:call-template name="show-footer"/>		
				</page>
			</xsl:when>
			<xsl:when test="$media='paper'">
				<chapter status="{es:head/es:tracking/es:status}" name="{es:name}">
					<xsl:apply-templates/>
				</chapter>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Unknown media specified: ', $media"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:head"/>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:title">
		<title>
			<xsl:apply-templates/>
		</title>
		<!-- page toc -->
		<ul>
			<li><xref target="#Think">Think</xref></li>
			<li><xref target="#Plan">Plan</xref></li>
			<li><xref target="#Do">Do</xref></li>
		</ul>
		
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question">
		<xsl:if test="$config/config:build-command='draft' or sf:has-content(es:planning-question-title/following-sibling::*) ">
			<qa>
				<anchor name="{sf:title-to-anchor(es:planning-question-title)}"/>
				<xsl:apply-templates/>
			</qa>
		</xsl:if>	
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question/es:planning-question-title">	
		<title>
			<xsl:apply-templates/>
		</title>
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:understanding">	
		<anchor name="Think"/>
		<title>Think</title>
			<xsl:apply-templates/>
		
	</xsl:template>
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning">	
		<anchor name="Plan"/>
		<title>Plan</title>
			<xsl:apply-templates/>
		
	</xsl:template>
	
<!--	<xsl:template match="es:planning-question">
		<xsl:apply-templates/>
	</xsl:template>-->
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:planning/es:planning-question/es:planning-question-body">
			<xsl:apply-templates/>
	</xsl:template>
	
	
	<xsl:template match="es:think-plan-do-topic/es:body/es:doing">	
		<anchor name="Do"/>
		<title>Do</title>
			<xsl:apply-templates/>
		
	</xsl:template>	
</xsl:stylesheet>