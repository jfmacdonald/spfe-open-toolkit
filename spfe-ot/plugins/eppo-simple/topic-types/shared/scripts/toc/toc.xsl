<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis"
 xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
 exclude-result-prefixes="#all">
	
	<xsl:variable name="config" as="element(config:spfe)">
		<xsl:sequence select="/config:spfe"/>
	</xsl:variable>
	
	<xsl:param name="topic-set-id"/>
	
	<xsl:param name="synthesis-files"/>
	<xsl:variable name="synthesis" select="sf:get-sources($synthesis-files)"/>
	
	<!-- FIXME: hack -->
	<xsl:variable name="media">online</xsl:variable>

	<xsl:param name="toc-file"/>

	<xsl:variable name="title-string">
		<xsl:value-of select="sf:string($config//config:strings, 'eppo-simple-topic-set-title')"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="sf:string($config//config:strings, 'eppo-simple-topic-set-release')"/>
<!--		<xsl:value-of select="$config/config:publication-info/config:title"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="$config/config:publication-info/config:release"/>
-->	</xsl:variable>

	<xsl:template name="main">

		<xsl:result-document href="file:///{$config/config:toc-directory}/{$topic-set-id}.toc.xml" method="xml" indent="yes" omit-xml-declaration="no">
			<toc 
				topic-set-id="{$topic-set-id}" 
				topic-set-type="{$config/config:topic-set[config:topic-set-id=$topic-set-id]/config:topic-set-type}" 
				deployment-relative-path="{$topic-set-id}" 
				title="{$title-string}">
				<xsl:choose>
					<!-- If there is a TOC file for this media, use it to create TOC -->
					<!-- Fixme: still need to add toc spport to config and make this work with it. -->
					<xsl:when test="$media = tokenize(document($toc-file)/toc/@media, '\s+')">
						
						<xsl:call-template name="sf:info">
							<xsl:with-param name="message" select="'Processing toc file ', $toc-file, 'for ', $media"/>
						</xsl:call-template>
						
						<xsl:variable name="toc-topics" select="document($toc-file)//topic/@name" as="xs:string*"/>
						<xsl:variable name="topic-set-topics" select="$synthesis//topic/name" as="xs:string*"/>
						
						<!-- Make sure the list of topics in the TOC matches the list of topics in the topic-set -->
						<xsl:if test="not(every $t in $toc-topics satisfies $t = $topic-set-topics)">
							<xsl:call-template name="sf:error">
								<xsl:with-param name="message">
									<xsl:text>Toc file </xsl:text>
									<xsl:value-of select="$toc-file"/>
									<xsl:text> includes topics not found in topic set. Non-matching topic names are: </xsl:text>
									<xsl:value-of select="string-join($toc-topics[not(.=$topic-set-topics)], ', ')"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="not(every $t in $topic-set-topics satisfies $t = $toc-topics)">
							<xsl:call-template name="sf:error">
								<xsl:with-param name="message">
									<xsl:text>Toc file </xsl:text>
									<xsl:value-of select="$toc-file"/>
									<xsl:text> does not include all topics found in topic set. Omitted topics are: </xsl:text>
									<xsl:value-of select="string-join($topic-set-topics[not(.=$toc-topics)], ', ')"/>
									</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						
						
						<xsl:for-each select="document($toc-file)//topic">
							
						<xsl:variable name="this-topic" select="$synthesis/ss:synthesis/ss:topic[name=current()/@name]"/>
							
						<xsl:choose>
								<xsl:when test="$this-topic">
									<node id="{$this-topic/name}"
										name="{$this-topic/title}">
									</node>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="sf:warning">
										<xsl:with-param name="message">
											<xsl:text>Topic listed in toc file not found: </xsl:text>
											<xsl:value-of select="@name"/>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					
					<!-- If not TOC file, create TOC based on topic types -->
					<xsl:otherwise>	
						<xsl:call-template name="sf:info">
							<xsl:with-param name="message" select="'No toc file, use topic-type-order for ', $media"/>
						</xsl:call-template>
						<xsl:if test="$synthesis/ss:synthesis/ss:topic[matches(@local-name, '^[iI][nN][dD][eE][xX]$')]">
							<xsl:attribute name="index">index</xsl:attribute>
						</xsl:if>
						<!-- Allow the presentation script to add entires before main TOC -->
						<xsl:call-template name="toc-prefix-entries"/>
						
						<!-- Get all the topics, but omit any named index -->
						<xsl:variable name="topics" select="$synthesis/ss:synthesis/ss:topic[not(matches(@local-name, '^[iI][nN][dD][eE][xX]$'))]"/>
	
						
						<!-- Make sure there is an entry on the topic type order list for every topic type. Exclude topic types starting with "spfe." -->
						<!-- FIXME: decide if still using virutal types. If not, remove code. -->
						<xsl:variable name="topic-types-found" select="distinct-values($synthesis/ss:synthesis/ss:topic[not(@virtual-type)]/@type union $synthesis/ss:synthesis/ss:topic[not(starts-with(@virtual-type, 'spfe.'))]/@virtual-type)"/>
						
						<xsl:variable name="topic-type-order-list" select="$config/config:topic-set[config:topic-set-id=$topic-set-id]/config:topic-types/config:topic-type-order/config:topic-type-xmlns/text()"/>
						<xsl:variable name="topic-type-alias-list" select="$config/config:topic-type/config:xmlns/text()"/>
<!--						<xsl:message select="'$topic-type-order-list:', string-join($topic-type-order-list, ' ')"/>
						<xsl:message select="'$topic-type-alias-list:', string-join($topic-type-alias-list, ' ')"/>	
						<xsl:message select="'$topic-types-found', $topic-types-found"/>-->
						
						<xsl:if test="count($topic-types-found[not(.=$topic-type-alias-list)])">
							<xsl:call-template name="sf:error">
								<xsl:with-param name="message" select="'Topic type(s) missing from spfe.topic-type-order-list property: ', string-join($topic-types-found[not(.=$config/config:topic-type-order/config:topic-type)], ', ')"/>
							</xsl:call-template>
						</xsl:if>
						

						
						
						<!-- make sure there is a topic type alias for every topic in the topic type order list -->
						<!-- FIXME: This check could be moved to the config script -->
						<xsl:if test="not(every $x in $topic-type-order-list satisfies $x = $topic-type-alias-list)">
							<xsl:call-template name="sf:error">
								<xsl:with-param name="message" select="'Topic type(s) missing from topic type alias list:', string-join($config/config:topic-set[config:topic-set-id=$topic-set-id]/config:topic-types/config:topic-type-order/config:topic-type-xmlns[not(.=$config/config:topic-type/config:xmlns)], ', ')"/>
							</xsl:call-template>
						</xsl:if>
	
						<xsl:for-each select="$topic-type-order-list">
							<xsl:variable name="this-topic-type" select="."/>
							<xsl:variable name="included-topics" 
								select="($topics[@type=$this-topic-type] 
								union $topics[@virtual-type=$this-topic-type]) 
								except $topics[@virtual-type!=$this-topic-type]"/>
							
						
							<xsl:variable name="topics-of-this-type">
								<topics-of-type type="{$this-topic-type}">
									<xsl:for-each select="$included-topics">
										<xsl:sequence select="."/>
									</xsl:for-each>
								</topics-of-type>
							</xsl:variable>
						
							<xsl:choose>
								<!-- if only one topic of this type, promote to top level -->
								<xsl:when test="count($included-topics) = 1">
									<xsl:apply-templates select="$topics-of-this-type" mode="toc"/>
								</xsl:when>
								<!-- if more than one topic, create group -->
								<xsl:when test="$included-topics">
									<node topic-type="{$this-topic-type}"  name="{$config/config:topic-type[config:xmlns=$this-topic-type]/config:aliases/config:plural}">
										<xsl:apply-templates select="$topics-of-this-type" mode="toc"/>
									</node>

								</xsl:when>
								<xsl:otherwise>
								<!-- if no topics, no heading -->
									<xsl:if test="not($synthesis/ss:synthesis/ss:topic[matches(@local-name, '^[iI][nN][dD][eE][xX]$')][@type=$this-topic-type])">
										<xsl:call-template name="sf:warning">
											<xsl:with-param name="message" select="'No topics found for topic type ', $this-topic-type, ' in the topic type order list. This might be because all the topics of that type are grouped with other topics, or because there are no topics of that type. No type grouping will be created in the TOC.'"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<!-- allow the presenation script to add entries after the main toc -->
						<xsl:call-template name="toc-suffix-entries"/>
	
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="additional-toc-entries"/> 
			</toc>	
		</xsl:result-document>	
	</xsl:template>
	
	<!-- fallback entries for prefix and suffix entries -->
	<xsl:template name="toc-prefix-entries"/>
	<xsl:template name="toc-suffix-entries"/>

	
	
	<!-- This template can be overridden in the importing stylesheet to 
	add additional entries to a TOC after the normal entries. -->
	<xsl:template name="additional-toc-entries"/>
	
	<!-- Default topics-of-type template - may be overridden for specific types -->
	<xsl:template match="topics-of-type" mode="toc">
		<xsl:call-template name="sf:info">
			<xsl:with-param name="message" select="'Applying default TOC template to topics of type', string(@type)"/>
		</xsl:call-template>
		<xsl:for-each select="ss:topic">
			<xsl:sort select="@title"/>
			<node id="{@local-name}" name="{@title}"/>
		</xsl:for-each>
	</xsl:template>
	

	<!-- don't create a TOC category for title-pages -->
	<xsl:template match="topics-of-type[@virtual-type='spfe.title-page']"/>

		
	
<!-- 	<xsl:template match="topic" mode="toc" priority="-1">
		<node id="{name}" name="{title}"/>
	</xsl:template>
 -->
</xsl:stylesheet>
