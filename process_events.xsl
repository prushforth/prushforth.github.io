<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:as="http://atomserver.org/namespaces/1.0/" 
  xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" 
  xmlns:app="http://www.w3.org/2007/app" xmlns:atom="http://www.w3.org/2005/Atom"  
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"    xmlns:prop="http://saxonica.com/ns/html-property" 
  xmlns:style="http://saxonica.com/ns/html-style-property" exclude-result-prefixes="xs xsl os as georss gml app atom prop js" 
  extension-element-prefixes="ixsl"  
  xmlns:js="http://saxonica.com/ns/globalJS" 
  xmlns:geogratis="http://geogratis.gc.ca/namespace" version="2.0">
  
  <xsl:include href="harvest_input.xsl"/>
  <xsl:include href="process_query_results.xsl"/>
  
  <xsl:template match="input[@type='button'][@name='submit']" mode="ixsl:onclick">
    <xsl:result-document href="#results" method="ixsl:replace-content">
      <xsl:variable name="code"> UriTemplate.parse('<xsl:value-of select="ixsl:page()//form[@id='theform']/@data-tref"/>').expand({<xsl:apply-templates select="//form[@id='theform']/(div | input) except self::node()" mode="harvest"/>}) </xsl:variable>
      <xsl:variable name="base" select="ixsl:page()//form/@data-base"/>
      <xsl:variable name="url" select="resolve-uri(ixsl:eval(string($code)), $base)"/>
      <xsl:variable name="results" select="doc($url)"/>
      <xsl:apply-templates select="doc($url)" mode="process-results"/>
      <p>xml:base from document: <xsl:value-of select="$base"/></p>
      <p>Here's the code: <xsl:value-of select="$code"/></p>
      <p>Calculated URI: <xsl:value-of select="$url"/></p>
    </xsl:result-document>
  </xsl:template>

<!--  <xsl:template match="input[@id='cardinalDirectionsSuggestions-q']" mode="ixsl:onchange">
    <xsl:result-document href="#results" method="ixsl:replace-content">
      <p>Selection: <xsl:value-of select="@prop:value"/></p>
      <p>Datalist: <xsl:value-of select="ixsl:page()//datalist[@id='place_search_results']/option[@prop:selected='false']/*"/></p>
    </xsl:result-document>
  </xsl:template>
-->  
  <xsl:template match="input[@id='cardinalDirectionsSuggestions-q']" mode="ixsl:onfocus">
    <xsl:result-document href="#results" method="ixsl:append-content">
      <p> input[@id='cardinalDirectionsSuggestions-q'] ixsl:onfocus</p>
    </xsl:result-document>
  </xsl:template>
  <xsl:template match="input[@id='cardinalDirectionsSuggestions-q']" mode="ixsl:onblur">
    <xsl:result-document href="#results" method="ixsl:append-content">
      <p> input[@id='cardinalDirectionsSuggestions-q'] ixsl:onblur</p>
    </xsl:result-document>
  </xsl:template>
  <xsl:template match="input[@id='cardinalDirectionsSuggestions-q']" mode="ixsl:onselect">
    <xsl:result-document href="#results" method="ixsl:append-content">
      <p> input[@id='cardinalDirectionsSuggestions-q'] ixsl:onselect</p>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="datalist[@id='place_search_results']" mode="ixsl:onchange">
    <!--<ixsl:set-attribute name="prop:selected" select="'true'"/>-->
    <xsl:result-document href="#results" method="ixsl:append-content">
      <p>Datalist event</p>
    </xsl:result-document>
  </xsl:template>
  
  
  
  <xsl:template match="select[@id='schemes']" mode="ixsl:onchange">
    <!-- this result-document technique is described here: http://www.saxonica.com/ce/user-doc/1.1/index.html#!coding/result-documents -->
    <xsl:result-document href="?select=//datalist[@id='categoriesSuggestions']" method="ixsl:replace-content">
      <xsl:for-each select="geogratis:getCategorySuggestions()">
        <option value="{@term}" label="{@label}"/>
      </xsl:for-each>
    </xsl:result-document>
  </xsl:template>
  
  
  
  <xsl:template match="input[@id='categorySuggestions']" mode="ixsl:onchange">
    <!-- should test a) that user has entered or there is a string selected and b) the event is happening more than the time it takes for one keystroke since the last keystroke and c) -->
    <xsl:if test="string-length(@prop:value) &gt; 2" >
      <!-- this result-document technique is described here: http://www.saxonica.com/ce/user-doc/1.1/index.html#!coding/result-documents -->
      <xsl:result-document href="?select=//datalist[@id='categoriesSuggestions']" method="ixsl:replace-content">
        <xsl:for-each select="geogratis:getCategorySuggestions()">
          <option value="{@term}" label="{@label}"/>
        </xsl:for-each>
      </xsl:result-document>
    </xsl:if>
    <xsl:result-document href="#results" method="ixsl:replace-content">
      <p>Value of the input: <xsl:value-of select="@prop:value"/></p>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:function name="geogratis:getCategorySuggestions"  as="element()*">
    <xsl:variable name="schemesSelect" select="ixsl:page()//select[@id='schemes']"/>
    <xsl:variable name="suggestionsInput" select="ixsl:page()//input[@id='categorySuggestions']"/>
    <xsl:variable name="code" select= "concat('UriTemplate.parse(','''',$suggestionsInput/@data-tref,'''',').expand({q:','''',$suggestionsInput/@prop:value,'''',',scheme :','''',$schemesSelect/@prop:value,'''','})')"/>
    <xsl:variable name="url" select="resolve-uri(ixsl:eval(string($code)),$suggestionsInput/@data-base)"/>
    <xsl:copy-of select="doc($url)//atom:category"/>
  </xsl:function>
  
  <xsl:template match="a" mode="ixsl:onclick"  ixsl:prevent-default="yes">
    <xsl:result-document href="#results" method="ixsl:replace-content">
      <xsl:apply-templates select="doc(@href)" mode="process-entry"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="atom:entry" mode="process-entry">
    <h1><xsl:value-of select="atom:title"/></h1>
    <br/>
    <p><xsl:value-of select="atom:summary"/></p>
  </xsl:template>
  
  
  <xsl:template match="input[@id='get-cardinalDirectionsSuggestions-q-button']" mode="ixsl:onclick">
    <xsl:variable name="srchInput" select="ixsl:page()//input[@id='cardinalDirectionsSuggestions-q']"/>
    <xsl:if test="string-length($srchInput/@prop:value) &gt; 2">
      <xsl:variable name="tref" select="$srchInput/ancestor::div[1]/@data-tref"/> 
      <xsl:variable name="template">
        UriTemplate.parse('<xsl:value-of select="$tref"/>').expand({<xsl:value-of select="'q'"/>:'<xsl:value-of select="$srchInput/@prop:value"/>'})
      </xsl:variable>
      <xsl:variable name="placeSearchResults" select="unparsed-text(resolve-uri(ixsl:eval(string($template)),$srchInput/ancestor::div[1]/@data-base))"/>
      <!--        <xsl:result-document href="#results" method="ixsl:replace-content">
          <p>template is: <xsl:value-of select="$template"/></p>
          <p>search result is: <xsl:value-of select="$placeSearchResults"/></p>
        </xsl:result-document>
-->
      <xsl:result-document href="?select=//datalist[@id='place_search_results']" method="ixsl:replace-content">
        <xsl:copy-of select="geogratis:locationJson2Options($placeSearchResults)"/>
      </xsl:result-document>
      
    </xsl:if>
  </xsl:template>
  
  <xsl:function name="geogratis:locationJson2Options">
    <xsl:param name="json"/>
    
    <xsl:variable name="objStartRE">\{.*?</xsl:variable>
    <xsl:variable name="objEndRE">\}+</xsl:variable>
    
    <xsl:variable name="dotStarNonGreedyRE">.*?</xsl:variable>
    <xsl:variable name="ds" select="$dotStarNonGreedyRE"/>
    
    <xsl:variable name="titleRE">("title":.*?"(.*?)")</xsl:variable>
    <xsl:variable name="qualifierRE">("qualifier":.*?"(.*?)")</xsl:variable>
    <xsl:variable name="typeRE">("type":.*?"(.*?)")</xsl:variable>
    <xsl:variable name="bboxRE">("bbox":.*?\[(.*?)\])</xsl:variable>
    <xsl:variable name="geometryRE">("geometry":.*?(\{.*?\}))</xsl:variable>
    
    <xsl:variable name="bboxThenGeometryRE" select="concat('(',$bboxRE,$ds,$geometryRE,$ds,$objEndRE,')')"/>
    <xsl:variable name="justGeometryRE" select="concat('(',$geometryRE,$ds,$objEndRE,')')"/>
    <xsl:variable name="bboxThenGeometryOrJustGeometryRE" select="concat('(',$bboxThenGeometryRE,'|',$justGeometryRE,')')"/>
    
    <xsl:variable name="regex" select="concat('(',$objStartRE,$titleRE,$ds,$qualifierRE,$ds,$typeRE,$ds,$bboxThenGeometryOrJustGeometryRE,')')"/>
    <xsl:variable name="bboxExistsGroupNo" select="count(index-of(string-to-codepoints(substring-before($regex,$bboxRE)),string-to-codepoints('(')))"/>
    <xsl:variable name="bboxValueGroupNo" select="$bboxExistsGroupNo + 2"/>
    <xsl:variable name="titleValueGroupNo" select="count(index-of(string-to-codepoints(substring-before($regex,$titleRE)),string-to-codepoints('('))) + 2"/>
    
    <xsl:analyze-string select="$json" regex="{$regex}" flags="s">
      <xsl:matching-substring>
        <xsl:variable name="bboxExists" select="regex-group($bboxExistsGroupNo)"/>
        <xsl:if test="$bboxExists">
          <xsl:variable name="bbox" select="translate(regex-group($bboxValueGroupNo),' ','')"/>
          <xsl:variable name="title" select="regex-group($titleValueGroupNo)"/>
          <xsl:element name="option">
            <xsl:attribute name="data-bbox" select="$bbox"/>
            <xsl:value-of select="$title"/>
          </xsl:element>
        </xsl:if>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:function>
  
</xsl:stylesheet>