<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2012 All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
	exclude-result-prefixes="#all">

	<xsl:param name="message-types">info debug warning</xsl:param>
	<xsl:param name="terminate-on-error">yes</xsl:param>
	<xsl:variable name="verbosity" select="tokenize($message-types, ' ')"/>

	<xsl:function name="sf:title-to-anchor">
		<xsl:param name="title"/>
		<!--	<xsl:value-of select='translate( normalize-space($title), " :&apos;[]/\", "-\-\-\-\-\-\-")'/>
-->
		<xsl:value-of select="translate(encode-for-uri( normalize-space($title)), '%', '')"/>
	</xsl:function>

	<xsl:function name="sf:get-sources">
		<xsl:param name="file-list"/>
		<xsl:sequence select="sf:get-sources($file-list, '')"/>
	</xsl:function>

	<xsl:function name="sf:get-sources">
		<xsl:param name="file-list"/>
		<xsl:param name="load-message"/>
		<!--  FIXME: This test is firing in spfe-docs even though it is building correctly???
		<xsl:if test="normalize-space($file-list)=''">
		<xsl:call-template name="sf:error">
			<xsl:with-param name="message">
				<xsl:text>Empty file list passed to sf:get-sources function. This may be because a configuration file is pointing to a file that does not exist on the system. Check your configuration.</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
-->
		<xsl:for-each select="tokenize(translate($file-list, '\', '/'), ';')">
			<xsl:variable name="one-file" select="sf:local-to-url(.)"/>
			<xsl:if test="normalize-space($load-message)">
				<xsl:call-template name="sf:info">
					<xsl:with-param name="message" select="$load-message, $one-file "/>
				</xsl:call-template>
			</xsl:if>
			<xsl:sequence select="document($one-file)"/>
		</xsl:for-each>
	</xsl:function>
	
	<xsl:function name="sf:local-to-url">
		<xsl:param name="local-path"/>
		<xsl:choose>
			<xsl:when test="starts-with($local-path,'file:/')">
				<xsl:value-of select="$local-path"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('file:///', normalize-space($local-path))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="sf:url-to-local">
		<xsl:param name="url"/>
		<xsl:variable name="new-url">
			<xsl:choose>
				<!-- Windows style -->
				<xsl:when test="matches($url, '^file:/[a-zA-Z]:/')">
					<xsl:value-of select="substring-after($url,'file:/')"/>
				</xsl:when>
				<!-- Windows system path -->
				<xsl:when test="matches($url, '^[a-zA-Z]:/')">
					<xsl:value-of select="$url"/>
				</xsl:when>
				<!-- UNIX style -->
				<xsl:when test="matches($url, '^file:/')">
					<xsl:value-of select="substring-after($url,'file:')"/>
				</xsl:when>
				<!-- unsupported protocol -->
				<xsl:when test="matches($url, '^[a-zA-Z]+:/')">
					<xsl:message terminate="yes">
						<xsl:text>ERROR: A URL with an unsupported protocol was specified. The URL is: </xsl:text>
						<xsl:value-of select="$url"/>
					</xsl:message>
				</xsl:when>
				
				<!-- already local -->
				<xsl:otherwise>
					<xsl:value-of select="$url"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="replace($new-url, '%20', ' ')"/>
	</xsl:function>

	<!-- In the following functions, we us string-join to concatenate the messages and convert to strings. 
	     This allows the messages to be specified in a number of ways and to potentially include multiple sequences.-->

	<xsl:template name="sf:info">
		<xsl:param name="message"/>
		<xsl:if test="$verbosity='info'">
			<xsl:message select="'Info: ', string-join($message, '')"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sf:debug">
		<xsl:param name="message"/>
		<xsl:param name="in">Not specified.</xsl:param>
		<xsl:if test="$verbosity='debug'">
			<xsl:message>#######################################################</xsl:message>
			<xsl:message select="'DEBUG: ', string-join($message, '')"/>
			<xsl:message select="'In: ', string-join($in, '')"/>
			<xsl:message>#######################################################</xsl:message>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sf:warning">
		<xsl:param name="message"/>
		<xsl:param name="in">Not specified.</xsl:param>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~</xsl:message>
			<xsl:message>
				<xsl:text>Warning: </xsl:text>
				<xsl:sequence select="string-join($message, '')"/>
			</xsl:message>
			<xsl:message select="'In: ', string-join($in, '')"/>
			<xsl:message>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~</xsl:message>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sf:unresolved">
		<xsl:param name="message"/>
		<xsl:param name="in">Not specified.</xsl:param>
		<xsl:if test="$verbosity='warning'">
			<xsl:message>------------------------------------------------------</xsl:message>
			<xsl:message>
				<xsl:text>Unresolved: </xsl:text>
				<xsl:sequence select="string-join($message, '')"/>
			</xsl:message>
			<xsl:message select="'In: ', string-join($in, '')"/>
			<xsl:message>------------------------------------------------------</xsl:message>
		</xsl:if>
	</xsl:template>

	<xsl:template name="sf:error">
		<xsl:param name="message"/>
		<xsl:param name="in">Not specified.</xsl:param>
		<xsl:message>**********************************************************</xsl:message>
		<xsl:message select="'ERROR: ', string-join($message,'')"/>
		<xsl:message select="'In: ', string-join($in, '')"/>
		<xsl:message>**********************************************************</xsl:message>
		<xsl:message terminate="{$terminate-on-error}"/>
	</xsl:template>


	<xsl:function name="sf:path-depth" as="xs:integer">
		<!-- Calculates the depth of an XPath by counting the number of 
		elements in the path. It uses tokenize to count but throws away 
		the empty string item that would be created by a leading or trailing 
		slash. Thus foo/bar, /foo/bar, and /foo/bar/, are all counted as
		having a path depth of 2. Will count a concluding attribute on a 
		path as part of the depth. Presumably works for file paths as well,
		as long as they are in UNIX form. -->
		<xsl:param name="path"/>
		<xsl:value-of select="count(tokenize($path, '/')[. ne ''])"/>
	</xsl:function>

	<xsl:function name="sf:get-file-name-from-path">
		<xsl:param name="path"/>
		<xsl:variable name="tokens" select="tokenize($path, '/')"/>
		<xsl:value-of select="subsequence($tokens, count($tokens))"/>
	</xsl:function>

	<!-- FIXME: Strings should probably get coerced into their own namespace prior to lookup -->
	<xsl:function name="sf:string">
		<xsl:param name="strings" as="element()*"/>
		<xsl:param name="id"/>
		<xsl:if test="not($strings/*:string[@id=$id])">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message">String lookup failed for string ID <xsl:value-of
						select="$id"/>. No matching string found.</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:sequence select="$strings/*:string[@id=$id]/node()"/>
	</xsl:function>

	<!-- returns the index of the longest of a set of strings -->
	<xsl:function name="sf:index-of-longest-string" as="xs:integer">
		<xsl:param name="strings" as="xs:string*"/>
		<xsl:value-of select="sf:index-of-longest-string($strings,2,string-length($strings[1]),1)"/>
	</xsl:function>
	
	<xsl:function name="sf:index-of-longest-string" as="xs:integer">
		<xsl:param name="strings" as="xs:string*"/>
		<xsl:param name="current" as="xs:integer"/>
		<xsl:param name="length-of-longest" as="xs:integer"/>
		<xsl:param name="index-of-longest" as="xs:integer"/>
		<xsl:message select="'sf:longest-string',$strings,'|', $current,'|', $length-of-longest, '|', $index-of-longest"/>
		<xsl:choose>
			<xsl:when test="$current le count($strings)">
				<xsl:variable name="length-of-current" select="string-length($strings[$current])"/>
				<xsl:value-of select="sf:index-of-longest-string(
					$strings, 
					$current + 1, 
					max(($length-of-current,$length-of-longest)),
					if ($length-of-current>$length-of-longest) then $current else $index-of-longest)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$index-of-longest"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- returns the index of the shortest of a set of strings -->
	<xsl:function name="sf:index-of-shortest-string" as="xs:integer">
		<xsl:param name="strings" as="xs:string*"/>
		<xsl:value-of select="sf:index-of-shortest-string($strings,2,string-length($strings[1]),1)"/>
	</xsl:function>
	
	<xsl:function name="sf:index-of-shortest-string" as="xs:integer">
		<xsl:param name="strings" as="xs:string*"/>
		<xsl:param name="current" as="xs:integer"/>
		<xsl:param name="length-of-shortest" as="xs:integer"/>
		<xsl:param name="index-of-shortest" as="xs:integer"/>
		<xsl:choose>
			<xsl:when test="$current le count($strings)">
				<xsl:variable name="length-of-current" select="string-length($strings[$current])"/>
				<xsl:value-of select="sf:index-of-shortest-string(
					$strings, 
					$current + 1, 
					min(($length-of-current,$length-of-shortest)),
					if ($length-of-current lt $length-of-shortest) then $current else $index-of-shortest)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$index-of-shortest"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="sf:conditions-met" as="xs:boolean">
		<xsl:param name="conditions"/>
		<xsl:param name="condition-tokens"/>
		<xsl:variable name="tokens-list" select="tokenize($condition-tokens, '\s+')"/>
		<xsl:variable name="conditions-list" select="tokenize($conditions, '\s+')"/>
		<xsl:choose>
			<xsl:when test="not($conditions)">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="sf:satisfies-condition" as="xs:boolean">
		<xsl:param name="conditions-list"/>
		<xsl:param name="tokens-list"/>
		<xsl:value-of select="sf:satisfies-condition($conditions-list, $tokens-list, 1)"/>
	</xsl:function>

	<xsl:function name="sf:satisfies-condition" as="xs:boolean">
		<xsl:param name="conditions-list"/>
		<xsl:param name="tokens-list"/>
		<xsl:param name="index"/>

		<xsl:variable name="and-tokens" select="tokenize($tokens-list[$index], '\+')"/>

		<xsl:choose>
			<xsl:when test="every $item in $and-tokens satisfies $item=$conditions-list">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:when test="$index lt count($tokens-list)">
				<xsl:value-of
					select="sf:satisfies-condition($conditions-list, $tokens-list, $index + 1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="sf:relative-from-absolute-path" as="xs:string">
		<xsl:param name="path"/>
		<xsl:param name="base-path"/>
		<xsl:value-of select="sf:relative-from-absolute-path($path, $base-path, '')"/>
	</xsl:function>

	<xsl:function name="sf:relative-from-absolute-path" as="xs:string">
		<xsl:param name="path" as="xs:string"/>
		<xsl:param name="base-path" as="xs:string"/>
		<xsl:param name="prefix" as="xs:string"/>

		<xsl:variable name="normalized-path"
			select=" sf:path-after-protocol-part(translate(sf:pct-decode($path), '\', '/'))"/>
		<xsl:variable name="normalized-base-path"
			select="sf:path-after-protocol-part(translate(sf:pct-decode($base-path), '\', '/'))"/>
		<xsl:value-of
			select="concat($prefix,substring-after($normalized-path, $normalized-base-path))"/>
	</xsl:function>

	<xsl:function name="sf:path-after-protocol-part" as="xs:string">
		<xsl:param name="path"/>
		<xsl:analyze-string select="$path" regex="^([a-zA-Z]{{2,}}://?/?)?(.+)">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(2)"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>

	<xsl:function name="sf:local-path-from-uri">
		<xsl:param name="uri"/>
		<xsl:value-of select="sf:pct-decode(sf:path-after-protocol-part($uri))"/>
	</xsl:function>

	<!-- Adapted from code published by James A. Robinson at http://www.oxygenxml.com/archives/xsl-list/200911/msg00300.html -->
	<!-- Function to decode percent-encoded characters  -->
	<xsl:function name="sf:pct-decode" as="xs:string?">
		<xsl:param name="in" as="xs:string"/>
		<xsl:sequence select="sf:pct-decode($in, ())"/>
	</xsl:function>
	<xsl:function name="sf:pct-decode" as="xs:string?">
		<xsl:param name="in" as="xs:string"/>
		<xsl:param name="seq" as="xs:string*"/>

		<xsl:choose>
			<xsl:when test="not($in)">
				<xsl:sequence select="string-join($seq, '')"/>
			</xsl:when>
			<xsl:when test="starts-with($in, '%')">
				<xsl:choose>
					<xsl:when test="matches(substring($in, 2, 2), '^[0-9A-Fa-f][0-9A-Fa-f]$')">
						<xsl:variable name="s" as="xs:string" select="substring($in, 2, 2)"/>
						<xsl:variable name="d" as="xs:integer"
							select="sf:hex-to-dec(upper-case($s))"/>
						<xsl:variable name="c" as="xs:string" select="codepoints-to-string($d)"/>
						<xsl:sequence select="sf:pct-decode(substring($in, 4), ($seq, $c))"/>
					</xsl:when>
					<xsl:when test="contains(substring($in, 2), '%')">
						<xsl:variable name="s" as="xs:string"
							select="substring-before(substring($in, 2), '%')"/>
						<xsl:sequence
							select="sf:pct-decode(substring($in, 2 + string-length($s)), ($seq, '%', $s))"
						/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="string-join(($seq, $in), '')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($in, '%')">
				<xsl:variable name="s" as="xs:string" select="substring-before($in, '%')"/>
				<xsl:sequence
					select="sf:pct-decode(substring($in, string-length($s)+1), ($seq, $s))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="string-join(($seq, $in), '')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Function to convert a hexadecimal string into decimal -->
	<xsl:function name="sf:hex-to-dec" as="xs:integer">
		<xsl:param name="hex" as="xs:string"/>

		<xsl:variable name="len" as="xs:integer" select="string-length($hex)"/>
		<xsl:choose>
			<xsl:when test="$len eq 0">
				<xsl:sequence select="0"/>
			</xsl:when>
			<xsl:when test="$len eq 1">
				<xsl:sequence
					select="
					if ($hex eq '0')       then 0
					else if ($hex eq '1')       then 1
					else if ($hex eq '2')       then 2
					else if ($hex eq '3')       then 3
					else if ($hex eq '4')       then 4
					else if ($hex eq '5')       then 5
					else if ($hex eq '6')       then 6
					else if ($hex eq '7')       then 7
					else if ($hex eq '8')       then 8
					else if ($hex eq '9')       then 9
					else if ($hex = ('A', 'a')) then 10
					else if ($hex = ('B', 'b')) then 11
					else if ($hex = ('C', 'c')) then 12
					else if ($hex = ('D', 'd')) then 13
					else if ($hex = ('E', 'e')) then 14
					else if ($hex = ('F', 'f')) then 15
					else error(xs:QName('sf:hex-to-dec'))
					"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence
					select="
					(16 * sf:hex-to-dec(substring($hex, 1, $len - 1)))
					+ sf:hex-to-dec(substring($hex, $len))"
				/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Display first n words -->
	<xsl:function name="sf:first-n-words">
		<xsl:param name="text"/>
		<xsl:param name="words" as="xs:integer"/>
		<xsl:param name="suffix" as="xs:string"/>
		<xsl:variable name="text-string" select="normalize-space(string($text))"/>
		<xsl:variable name="regex" select="concat('^([^\s]+\s*){1,', $words, '}')"/>
		<xsl:if test="$text-string">
			<xsl:analyze-string select="$text-string" regex="{$regex}" flags="s">
				<xsl:matching-substring>
					<xsl:value-of select="concat(regex-group(0), $suffix)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:if>
	</xsl:function>

	<!-- Escape string for XML -->
	<xsl:function name="sf:escape-for-xml">
		<xsl:param name="string"/>
		<xsl:analyze-string select="string($string)" regex="&lt;|&amp;">
			<xsl:matching-substring>
				<xsl:choose>
					<xsl:when test=".='&lt;'">&amp;lt;</xsl:when>
					<xsl:when test=".='&amp;'">&amp;amp;</xsl:when>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:function>

	<!-- Escape string for regex -->
	<!-- Escapes the reserved characters for inserting literal string into a regex expression -->
	<xsl:function name="sf:escape-for-regex">
		<xsl:param name="string"/>
		<xsl:value-of select="replace($string, '([\\\|\.\?\*\+\(\)\{\}\[\]\$\^\-])', '\\$1')"/>
<!--		<xsl:analyze-string select="string($string)" regex="\.|\\">
			<xsl:matching-substring>
				<xsl:value-of select="concat('\',.)"/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>-->
	</xsl:function>

	<xsl:function name="sf:get-topic-type-alias-singular">
		<xsl:param name="topic-set-id"/>
		<xsl:param name="topic-type-name"/>
		<xsl:param name="config"/>
		<xsl:choose>
			<xsl:when
				test="$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:topic-type[config:name=$topic-type-name]/config:aliases/config:singular">
				<xsl:value-of
					select="$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:topic-type[config:name=$topic-type-name]/config:aliases/config:singular"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>No singular topic type alias found for topic type </xsl:text>
						<xsl:value-of select="$topic-type-name"/>
						<xsl:text>. This setting should be defined in the configuration files at </xsl:text>
						<xsl:text>/spfe/topic-type/aliases/singular.</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<!-- FIXME: no point in this return if failure is error. Make fail behavior optional? -->
				<xsl:value-of select="$topic-type-name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="sf:get-topic-type-alias-plural">
		<xsl:param name="topic-set-id"/>
		<xsl:param name="topic-type-name"/>
		<xsl:param name="config"/>
		<xsl:choose>
			<xsl:when
				test="$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:topic-type[config:name=$topic-type-name]/config:aliases/config:plural">
				<xsl:value-of
					select="$config/config:content-set/config:topic-set[config:topic-set-id=$topic-set-id]/config:topic-type[config:name=$topic-type-name]/config:aliases/config:plural"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>No plural topic type alias found for topic type </xsl:text>
						<xsl:value-of select="$topic-type-name"/>
						<xsl:text>. This setting should be defined in the configuration files at </xsl:text>
						<xsl:text>/spfe/topic-type/aliases/plural.</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<!-- FIXME: no point in this return if failure is error. Make fail behavior optional? -->
				<xsl:value-of select="$topic-type-name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="sf:get-subject-type-alias-singular">
		<xsl:param name="subject-type-id"/>
		<xsl:param name="config"/>
		<xsl:choose>
			<xsl:when
				test="$config/config:subject-type[config:id=$subject-type-id]/config:aliases/config:singular">
				<xsl:value-of
					select="$config/config:subject-type[config:id=$subject-type-id]/config:aliases/config:singular"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>No singular subject type alias found for subject type </xsl:text>
						<xsl:value-of select="$subject-type-id"/>
						<xsl:text>. This setting should be defined in the configuration files at </xsl:text>
						<xsl:text>/spfe/subject-types/subject-type/aliases/singular.</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<!-- FIXME: no point in this return if failure is error. Make fail behavior optional? -->
				<xsl:value-of select="$subject-type-id"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="sf:get-subject-type-alias-plural">
		<xsl:param name="subject-type-id"/>
		<xsl:param name="config"/>
		<xsl:choose>
			<xsl:when
				test="$config/config:subject-type[config:id=$subject-type-id]/config:aliases/config:plural">
				<xsl:value-of
					select="$config/config:subject-type[config:id=$subject-type-id]/config:aliases/config:plural"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="sf:error">
					<xsl:with-param name="message">
						<xsl:text>No plural subject type alias found for topic type </xsl:text>
						<xsl:value-of select="$subject-type-id"/>
						<xsl:text>. This setting should be defined in the configuration files at </xsl:text>
						<xsl:text>/spfe/subject-types/subject-type/aliases/plural.</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<!-- FIXME: no point in this return if failure is error. Make fail behavior optional? -->
				<xsl:value-of select="$subject-type-id"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="sf:get-topic-link-priority">
		<xsl:param name="topic-type-name"/>
		<xsl:param name="topic-set-id"/>
		<xsl:param name="config"/>

		<xsl:variable name="topic-type-link-priority" select="$config/config:content-set/config:topic-set[config:topic-set-id eq $topic-set-id]/config:topic-type[config:name eq $topic-type-name]/config:topic-type-link-priority"/>
		<xsl:if test="count($topic-type-link-priority) gt 1"><xsl:message select="count($topic-type-link-priority), $topic-set-id, $topic-type-name, for $i in $topic-type-link-priority return generate-id($i)"></xsl:message></xsl:if>
		<xsl:variable name="topic-set-link-priority" select="$config/config:content-set/config:topic-set[config:topic-set-id eq $topic-set-id]/config:topic-set-link-priority"/>
		<xsl:if test="normalize-space($topic-type-link-priority) eq ''">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message" select="'Topic type link priority not set for namespace ', $topic-type-name"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="normalize-space($topic-set-link-priority) eq ''">
			<xsl:call-template name="sf:error">
				<xsl:with-param name="message" select="'Topic set link priority not set for topic set ID ', $topic-set-id"/>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:value-of select="$topic-type-link-priority + $topic-set-link-priority"
		/>
	</xsl:function>

	<!-- FIXME: Has to be a more elegant way to do this test! -->
	<xsl:function name="sf:has-content" as="xs:boolean">
		<xsl:param name="content"/>
		<xsl:value-of select="string-join(($content/text()[normalize-space(.)] | $content/*),'') ne ''"/>
	</xsl:function>
	
	<xsl:function name="sf:name-in-clark-notation">
		<xsl:param name="element"/>
		<xsl:value-of select="concat('{', namespace-uri($element), '}', local-name($element))"/>
	</xsl:function>

</xsl:stylesheet>
