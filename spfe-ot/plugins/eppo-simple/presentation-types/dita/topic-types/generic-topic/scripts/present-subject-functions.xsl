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
	xmlns:pe="http://spfeopentoolkit.org/ns/eppo-simple/present/eppo"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config" 
	xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
	exclude-result-prefixes="#all">

	<xsl:param name="link-catalog-files"/>
	<xsl:variable name="link-catalogs" >
		<xsl:variable name="temp-link-catalogs" select="sf:get-sources($link-catalog-files, 'Loading link catalog file:')"/>
		<xsl:if test="count(distinct-values($temp-link-catalogs/lc:link-catalog/@topic-set-id)) lt count($temp-link-catalogs/lc:link-catalog)">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">
					<xsl:text>Duplicate link catalogs detected.&#x000A; There appears to be more than one link catalog in scope for the same topics set. Topic set IDs encountered include:&#x000A;</xsl:text>
					<xsl:for-each select="$temp-link-catalogs/lc:link-catalog">
						<xsl:value-of select="@topic-set-id,'&#x000A;'"/>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="$temp-link-catalogs"/>
	</xsl:variable>
	<xsl:param name="objects-files"/>
	<xsl:variable name="objects" select="sf:get-sources($link-catalog-files, 'Loading link catalog file:')"/>
	
	<xsl:function name="esf:target-exists" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:value-of select="if ($link-catalogs//lc:target[@type=$type][lc:key=$target] or esf:multi-key-match($target, $type)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:target-exists" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		<xsl:value-of select="if ($link-catalogs//lc:target[@type=$type]
														   [lc:namespace=$namespace]
			                                               [lc:key=$target] or esf:multi-key-match($target, $type, $namespace)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:target-exists-not-self" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="self"/>
		<xsl:value-of select="if ($link-catalogs//lc:target[parent::lc:page/@full-name ne $self][@type=$type][lc:key=$target] or esf:multi-key-match($target, $type)) then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="esf:multi-key-match" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>

		<xsl:variable name="in-scope-key-sets-of-this-type">
			<xsl:for-each select="$link-catalogs//lc:target[@type=$type][lc:key-set]">
				<target>
					<xsl:copy-of select="lc:key-set"/>
				</target>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="matching-keysets" as="xs:boolean*">
			<xsl:for-each select="$in-scope-key-sets-of-this-type/lc:target">	
				<xsl:value-of select="lf:try-key-set($target, lc:key-set)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$matching-keysets=true()"/>
	</xsl:function>

	<xsl:function name="esf:multi-key-match" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		
		<xsl:variable name="in-scope-key-sets-of-this-type">
			<xsl:for-each select="$link-catalogs//lc:target[@type=$type][lc:namespace=$namespace][lc:key-set]">
				<target>
					<xsl:copy-of select="lc:key-set"/>
				</target>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="matching-keysets" as="xs:boolean*">
			<xsl:for-each select="$in-scope-key-sets-of-this-type/lc:target">	
				<xsl:value-of select="lf:try-key-set($target, lc:key-set)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$matching-keysets=true()"/>
	</xsl:function>
	
	<xsl:function name="lf:try-key-set" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="key-sets"/>
		<xsl:value-of select="lf:try-key-set($target, $key-sets, 1)"/>
	</xsl:function>

	<xsl:function name="lf:try-key-set" as="xs:boolean">
		<xsl:param name="target"/>
		<xsl:param name="key-sets"/>
		<xsl:param name="index"/>
		<xsl:choose>
			<xsl:when test="count($key-sets) eq 0">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:when test="$index gt count($key-sets)">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="not(lf:contains-any($target, $key-sets[$index]/lc:key))">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="lf:try-key-set($target, $key-sets, $index + 1)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	 
	<!-- recursive contains-any function -->
	<xsl:function name="lf:contains-any" as="xs:boolean">
	 	<xsl:param name="string"/>
	 	<xsl:param name="list" as="xs:string*"/>
	 	<xsl:value-of select="lf:contains-any($string, $list, 1)"/>
 	</xsl:function>
	
	<xsl:function name="lf:contains-any" as="xs:boolean">
	 	<xsl:param name="string"/>
	 	<xsl:param name="list"/>
	 	<xsl:param name="index"/>
	 	<xsl:choose>
	 		<xsl:when test="$index gt count($list)">
	 			<xsl:value-of select="false()"/>
	 		</xsl:when>
	 		<xsl:when test="$string = tokenize($list[$index], ' ')">
	 			<xsl:value-of select="true()"/>
	 		</xsl:when>
	 		<xsl:otherwise>
	 			<xsl:value-of select="lf:contains-any($string, $list, $index+1)"/>
	 		</xsl:otherwise>
	 	</xsl:choose>
	 </xsl:function>	
	
	<!-- output-link template -->
	<xsl:template name="output-link">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		<xsl:param name="class">default</xsl:param>
		<xsl:param name="content"/>
		<xsl:param name="current-page-name" as="xs:string"/>
		<xsl:param name="see-also" as="xs:boolean" select="false()"/>
		

		<!-- check that we are not linking to the current page
		<xsl:variable name="current-page" select="if (. instance of node() and ancestor::ss:topic/@full-name) then ancestor::ss:topic/@full-name else 'no-current-page'"/> -->
		
		<xsl:variable name="target-page" as="node()*"> 		
			<!-- single key lookup -->
			<xsl:sequence select="$link-catalogs/lc:link-catalog/lc:page[lc:target/@type=$type]
				                                                        [if($namespace) then lc:target/lc:namespace=$namespace else true()]
				                                                        [@full-name ne $current-page-name]
				                                                        [lc:target/lc:key=$target]"/>	
			
			<!-- multi-key lookup -->
			<xsl:sequence select="$link-catalogs/lc:link-catalog/lc:page[lc:target/@type=$type]
				                                                        [if($namespace) then lc:target/lc:namespace=$namespace else true()]
				                                                        [@full-name ne $current-page-name]/lc:target[lf:try-key-set($target, lc:key-set)]/.."/>	
		</xsl:variable>
		
		<!-- FIXME: Update this for namespaces? -->
		<xsl:if test="count($target-page[1]/lc:target[@type=$type][lc:key=$target]) gt 1">
			<xsl:call-template name="sf:warning">
				<xsl:with-param name="message" select="'Detected a target page that contains more than one target of the same name and type. The name is:', string($target), '. The type is:', string($type), '. The topic is', string(ancestor::ss:topic/@full-name), '.'"/>

			</xsl:call-template>
		</xsl:if>
		
		<xsl:choose>
			<!-- No target pages identified, so no link. This takes care of links back to the current page -->
			<xsl:when test="count($target-page) eq 0">
				<xsl:choose>
					<xsl:when test="$content">
						<xsl:sequence select="$content"/>
					</xsl:when>
					<!-- Is this ever the right thing to do. Can cause side effects depending on where called from. -->
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Choose the target page with the highest link priority -->
				<!-- Arbitrarilly picks the first in sequence if more than one page with same priority -->
				<xsl:variable name="highest-priority-page" select="$target-page[number(@link-priority) eq min($target-page/@link-priority)][1]"/>	
				<!-- FIXME: This test has never been tested. Need a test case for it. -->
				<xsl:if test="count($target-page[number(@link-priority) eq min($target-page/@link-priority)]) > 1">
					<xsl:call-template name="sf:warning">
						<xsl:with-param name="message">
							<xsl:text>More than one target page with the same link priority.&#x000A;</xsl:text>
							<xsl:text>Target pages include:&#x000A;</xsl:text>
							<xsl:value-of select="string-join($target-page[number(@link-priority) eq min($target-page/@link-priority)]/@full-name, ',&#x000A;')"/>
							<xsl:value-of select="'&#x000A;The target is: ', $target"/>
							<xsl:value-of select="'&#x000A;The type is: ', $type"/>
							<xsl:value-of select="'&#x000A;The priority is: ', min($target-page/@link-priority)"/>
						</xsl:with-param>
					</xsl:call-template>					
				</xsl:if>

				<xsl:call-template name="make-xref">
					<xsl:with-param name="target-page" select="$highest-priority-page"/>
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="type" select="$type"/>
					<xsl:with-param name="namespace" select="$namespace"/>
					<xsl:with-param name="current-page-name" select="$current-page-name"/>
					<xsl:with-param name="class" select="$class"/>
					<xsl:with-param name="see-also" as="xs:boolean" select="$see-also"/>
					<xsl:with-param name="content">
						<xsl:choose>
							<xsl:when test="$content">
								<xsl:sequence select="$content"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<!--make-xref template-->
	<xsl:template name="make-xref">
		<xsl:param name="target-page"/>
		<xsl:param name="target"/>
		<xsl:param name="type"/>
		<xsl:param name="namespace"/>
		<xsl:param name="current-page-name" as="xs:string"/>
		<xsl:param name="class">default</xsl:param>
		<xsl:param name="content"/>
		<xsl:param name="see-also" as="xs:boolean" select="false()"/>
		
		<xsl:variable name="target-topic-set" select="$target-page/parent::lc:link-catalog/@topic-set-id"/>

		<xsl:variable name="target-directory" select="$target-page/parent::lc:link-catalog/@output-directory"/>
		
		<xsl:variable name="target-directory-path" >
			<xsl:for-each select="tokenize($target-directory, '/')">
				<xsl:if test="position()!=last()">
					<xsl:text>../</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$target-directory"/>
		</xsl:variable>
		
		<xsl:variable name="target-file"  select="string($target-page/@file)"/>		
		
		<xsl:variable name="target-anchor" select="if ($target-page[1]/lc:target[lc:key=$target][lc:namespace=$namespace][@type=$type][1]/@anchor) then concat('#', $target-page[1]/lc:target[lc:key=$target][@type=$type][1]/@anchor) else ''"/>

		
		<xref keyref="{$target-topic-set}.{$target-page[1]/@local-name}" type="topic" scope="local">
			<xsl:sequence select="$content"/>
		</xref>
	</xsl:template>
	

	<xsl:template name="output-structure-referenceerence">
		<xsl:param name="target"/>
		<xsl:param name="type"/>
				
		<xsl:variable name="target-page" select="$link-catalogs/lc:link-catalog/lc:page[lc:target/@type=$type][lc:target/lc:key=$target]"/>
				
		<xsl:choose>
			<xsl:when test="(count($target-page/lc:page/@file) > 1) or (count($link-catalogs/lc:link-catalog/lc:page[@full-name=$target-page/@full-name]) > 1)">
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">More than one destination found for the cross reference <xsl:value-of select="$target"/>. Unable to proceed.</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="make-structure-reference">
					<xsl:with-param name="target-page" select="$target-page"/>
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="type" select="$type"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

		<!--make-structure-reference template-->
	<!-- FIXME: needs to be updated for namespaces, if it gets used at all -->
	<xsl:template name="make-structure-reference">
		<xsl:param name="target-page"/>
		<xsl:param name="target"/>
		<xsl:param name="type"/>

		<xsl:variable name="target-topic-set">
			<xsl:value-of select="$link-catalogs/lc:link-catalog[lc:page/@full-name=$target-page/@full-name]/@topic-set-id"/>
		</xsl:variable>
		
		<xsl:variable name="target-directory" select="$link-catalogs/lc:link-catalog/lc:page[@full-name=$target-page/@full-name]/parent::lc:link-catalog/@output-directory"/>

		
		<xsl:variable name="target-directory-path" >
			<xsl:for-each select="tokenize($target-directory, '/')">
				<xsl:if test="position()!=last()">
					<xsl:text>../</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="$target-directory"/>
		</xsl:variable>
	
		<xsl:variable name="target-file"  select="string($target-page/@file)"/>		
		
		<xsl:variable name="target-anchor" select="if ($target-page[1]/lc:target[lc:key=$target][@type=$type]/@anchor) then concat('#', $target-page[1]/lc:target[lc:key=$target][@type=$type]/@anchor) else ''"/>

		<xsl:choose>
			<!-- this book -->
			<xsl:when test="$topic-set-id eq $target-topic-set">
				<xref 
					type="{$type}"
					target="{$target}"/>
			</xsl:when>
			
			<!-- outside this book -->
			<xsl:otherwise>
				<b>
					<xsl:value-of select="$target-page/@title"/>
				</b>
				<xsl:text> in </xsl:text>
				<i>
					<xsl:value-of select="$link-catalogs/lc:link-catalog[@topic-set-id=$target-topic-set]/@title"/>
				</i> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- FIXME: Verify this is no longer needed.
		<!-\- link-xpath template -\->
	<xsl:template name="link-xpath">
		<xsl:param name="target" as="xs:string"/>
		<xsl:param name="link-text" as="xs:string"/>
		
		<!-\-Determine whether or not the target exists. -\->
		<xsl:choose>
			<xsl:when test="not(esf:target-exists($target, 'xpath'))">
				<!-\- if it does not exist, output warning and continue, outputting plain text -\->
				<xsl:call-template name="sf:warning">
					<xsl:with-param name="message" select="'Unknown xpath ', $target"/>
				</xsl:call-template>
				<!-\- output plain text -\->
				<xsl:value-of select="$link-text"/>
			</xsl:when>
			
			<xsl:otherwise>		
				<!-\- it does exist so output a link -\->
				<xsl:call-template name="output-link">
					<xsl:with-param name="target" select="$target"/>
					<xsl:with-param name="type">xpath</xsl:with-param>
					<xsl:with-param name="current-page-name" select="ancestor-or-self::ss:topic/@full-name"/>
				</xsl:call-template>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->
	
	<xsl:function name="esf:process-placeholders" as="node()*">
	<!-- Processes a string to determine if it contains placeholder markup in 
	     the form of a string contained between "{" and "}". Recognizes "{{}"
	     as an escape sequence for a literal "{". Nesting of placeholders is
	     not supported. The use of a literal "{" or "}" inside the placeholder 
	     string is not supported. Does not attempt to detect or report these
	     conditions, however.
	     
	     $string is the string to process.
	     $literal-name is the element name to wrap around a the literal parts
	     of $string.
	     $placeholder-name is the element name to wrap around the placeholder
	     parts of $string.
	 -->
		<xsl:param name="string"/><!-- the string to process -->
		<xsl:param name="literal-name"/><!-- the element name to wrap around literal parts of $string -->
		<xsl:param name="placeholder-name"/><!-- the element name to wrap around placeholder parts of $string -->
		<xsl:analyze-string select="$string" regex="\{{([^}}]*)\}}">
			<xsl:matching-substring>
				<xsl:choose>
					<!-- if empty, ignore -->
					<xsl:when test="regex-group(1)=''"/>
					<!-- recognize {{} as escape sequence for { -->
					<xsl:when test="regex-group(1)='{'">
						<xsl:choose>
							<xsl:when test="$literal-name ne ''">
								<xsl:element name="pe:{$literal-name}"><xsl:value-of select="regex-group(1)"/></xsl:element>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="regex-group(1)"/></xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="pe:{$placeholder-name}"><xsl:value-of select="regex-group(1)"/></xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:if test="not(normalize-space(.)='')">
						<xsl:choose>
							<xsl:when test="$literal-name ne''">
								<xsl:element name="pe:{$literal-name}"><xsl:value-of select="."/></xsl:element>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
						</xsl:choose>
				</xsl:if>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:function>
</xsl:stylesheet>
