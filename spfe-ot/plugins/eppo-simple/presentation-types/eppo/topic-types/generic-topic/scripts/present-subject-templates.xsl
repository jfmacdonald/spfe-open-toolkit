<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:esf="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/functions"
	xmlns:lf="local-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
	xmlns:lc="http://spfeopentoolkit.org/spfe-ot/plugins/eppo-simple/link-catalog"
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/presentation/eppo"	
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config" 
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">


	<!-- DOCUMENT GROUP -->
	<xsl:template match="term">
		<xsl:variable name="term" select="normalize-space(.)"/>

		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($term, 'term')">
				<xsl:call-template name="output-link">
					<xsl:with-param name="target" select="$term"/>
					<xsl:with-param name="type">term</xsl:with-param>
					<xsl:with-param name="class">gloss</xsl:with-param>
					<xsl:with-param name="content" select="normalize-space(string-join(.,''))"/>
					<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:subject-not-resolved">
					<xsl:with-param name="message" select="'Term  &quot;', $term, '&quot;'"/> 
					<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="topic-id">
		<xsl:variable name="topic" select="@id-ref"/>
		
		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($topic, 'topic')">
						<pe:italic>
							<xsl:call-template name="output-link">
								<xsl:with-param name="target" select="$topic"/>
								<xsl:with-param name="type">topic</xsl:with-param>
								<xsl:with-param name="content" as="xs:string">
									<xsl:value-of select="$link-catalogs//lc:target[@type='topic'][lc:key=$topic]/parent::lc:page/@title"/>
								</xsl:with-param>
								<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
							</xsl:call-template>
						</pe:italic>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Topic not found: ', $topic"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="topic-set-id">
		<xsl:variable name="topic-set" select="@id-ref"/>
		<xsl:choose>
			<!-- make sure that the target exists -->
			<xsl:when test="esf:target-exists($topic-set, 'topic-set')">
				<xsl:call-template name="output-link">
					<xsl:with-param name="target" select="$topic-set"/>
					<xsl:with-param name="type">topic-set</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:value-of select="$link-catalogs//lc:target[@type='topic-set'][lc:key=$topic-set]/parent::lc:page/@title"/>
					</xsl:with-param>
					<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'Topic set not found: ', $topic-set"/> 
				</xsl:call-template>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="text-object-ref">
		<xsl:variable name="id-ref" select="@id-ref"/>
		<xsl:choose>
			<xsl:when test="$text-objects/ss:synthesis/ss:text-object[@local-name eq $id-ref]">
				<xsl:apply-templates select="$text-objects/ss:synthesis/ss:text-object[@local-name eq $id-ref]/*"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message" select="'No text object found for text object reference: ', $id-ref"/>
					<xsl:with-param name="in" select="base-uri(document(''))"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="link-external">
	<!-- FIXME: support other protocols -->
		<pe:xlink href="http://{if (starts-with(@href, 'http://')) then substring-after(@href, 'http://') else @href}">
			<xsl:apply-templates/>
		</pe:xlink>	
	</xsl:template>

	<xsl:template match="url">
	<!-- FIXME: support other protocols -->
		<pe:xlink href="{if (starts-with(., 'http://')) then . else concat('http://',.)}">
		 <xsl:apply-templates/>
		</pe:xlink>	
	</xsl:template>

	<xsl:template match="subject">
		<xsl:variable name="content" select="normalize-space(.)"/>
			<xsl:choose>
				<xsl:when test="esf:target-exists(@key, @type)">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="@key"/>
						<xsl:with-param name="type" select="@type"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:subject-not-resolved">
						<xsl:with-param name="message" select="concat(@type, ' name &quot;', @key, '&quot;')"/>
						<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/> 
					</xsl:call-template>
					<xsl:value-of select="$content"/>								
				</xsl:otherwise>
			</xsl:choose>		
	</xsl:template>
	
	

	<xsl:template match="p/name ">
		<!-- FIXME: handle namespace of the name? -->
		<xsl:if test="not(@key)">
			<xsl:call-template name="sf:warning">
				<xsl:with-param name="message" 
					select="'&quot;name&quot; subject element found with no &quot;key&quot; attribute:', . "/>
				
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="content" select="normalize-space(.)"/>
		<pe:name type="{@type}">
			<xsl:choose>
				<xsl:when test="esf:target-exists(@key, @type)">
					<xsl:call-template name="output-link">
						<xsl:with-param name="target" select="@key"/>
						<xsl:with-param name="type" select="@type"/>
						<xsl:with-param name="content" select="$content"/>
						<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="sf:subject-not-resolved">
						<xsl:with-param name="message" select="concat(@type, ' name &quot;', (if (@key) then @key else .), '&quot;')"/> 
						<xsl:with-param name="in" select="ancestor::ss:topic/@full-name"/> 
					</xsl:call-template>
					<xsl:value-of select="$content"/>								
				</xsl:otherwise>
			</xsl:choose>
		</pe:name>	
	</xsl:template>
	
	<!-- FIXME: Need to do something more definite here. Need to give a clear contract to the format layer. -->
	<xsl:template match="decoration">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="selection-sequence">
		<pe:gui-label hint="{name()}">
			<xsl:apply-templates/>
		</pe:gui-label>
	</xsl:template>

	<!-- TEXT STRUCTURE GROUP -->
	<!-- Should be more error checking here to check for captions -->
	
	<xsl:template match="table-id">
		<xsl:variable name="table-id" select="@id-ref"/>
		<xsl:if test="not(ancestor::topic//table[@id=$table-id]/title)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message" select="'No table/title element found for referenced table:', $table-id, '. A title is required for all referenced tables.'"/>
			</xsl:call-template>
		</xsl:if>
		<pe:cross-ref target="{@id-ref}" type="table"/>
	</xsl:template>
	
	<xsl:template match="fig-id">
		<xsl:variable name="fig-id" select="@id-ref"/>
		<xsl:variable name="uri" select="@uri"/>
		<xsl:if test="not(ancestor::ss:topic//fig[@id=$fig-id or @uri=$uri]/title)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message" select="'No fig/title element found for referenced fig:', if($uri) then $uri else $fig-id, '. A title is required for all referenced figs.'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$uri">
				<pe:cross-ref target="{generate-id(ancestor::ss:topic//fig[@uri=$uri]/@uri)}" type="fig"/>
			</xsl:when>
			<xsl:otherwise>
				<pe:cross-ref target="{@id-ref}" type="fig"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="code-sample-id">
		<pe:cross-ref target="{@id-ref}" type="code-sample"/>
	</xsl:template>

	<xsl:template match="procedure-id">
		<pe:cross-ref target="{@id-ref}" type="procedure"/>
	</xsl:template>

	<xsl:template match="step-id">
		<pe:cross-ref target="{@id-ref}" type="step"/>
	</xsl:template>
	
	<xsl:template match="index-entry">
		<xsl:call-template name="create-reference-link">
			<xsl:with-param name="type" select="@type"/>
			<xsl:with-param name="content">
				<xsl:apply-templates/>				
			</xsl:with-param>
		</xsl:call-template> 
	</xsl:template>

</xsl:stylesheet>
