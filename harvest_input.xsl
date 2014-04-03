<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:as="http://atomserver.org/namespaces/1.0/" 
  xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" 
  xmlns:app="http://www.w3.org/2007/app" xmlns:atom="http://www.w3.org/2005/Atom"  
  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"    xmlns:prop="http://saxonica.com/ns/html-property" 
  xmlns:style="http://saxonica.com/ns/html-style-property" exclude-result-prefixes="xs xsl os as georss gml app atom prop js" 
  extension-element-prefixes="ixsl"  xmlns:js="http://saxonica.com/ns/globalJS" xmlns:geogratis="http://geogratis.gc.ca/namespace" version="2.0">
  
  <xsl:template match="form[@id='theform']/div[@data-tref]" mode="harvest">
    <xsl:value-of select="concat(@id,': ')"/>UriTemplate.parse('<xsl:value-of select="@data-tref"/>').expand({<xsl:apply-templates select="div | input" mode="harvest"/>})
    <xsl:if test="position() ne last()">,</xsl:if>
  </xsl:template>

  <xsl:template match="div[@id='bbox']" mode="harvest">
    <xsl:choose>
      <xsl:when test="descendant::output[1] ne ''">
        <xsl:value-of select="concat(@id,': ')"/>UriTemplate.parse('<xsl:value-of select="@data-tref"/>').expand({<xsl:apply-templates select="div | descendant::output" mode="harvest"/>})
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(@id,': ','''','''')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="position() ne last()">,</xsl:if>
  </xsl:template>
  
  <xsl:template match="div[@id='cardinalDirections']" mode="harvest">
    <xsl:value-of select="concat(@id,': ')"/>UriTemplate.parse('<xsl:value-of select="@data-tref"/>').expand({<xsl:apply-templates select="descendant::output" mode="harvest"/>})
    <xsl:if test="position() ne last()">,</xsl:if>
  </xsl:template>
  
  <xsl:template match="div[@id='cardinalDirectionsSuggestions']" mode="harvest"/>
  
  <!-- this is temporary to get the submission working without the category query component, just uri params... 
            <xsl:value-of select="concat('categoryQuery : ', '''', '-/(urn:atom:author)paul-d/(urn:atom:author)tella-s/','''')"/>
-->
  <xsl:template match="div[@id='categoryQuery']" mode="harvest">
    <xsl:value-of select="'categoryQuery : '''''"/>
  </xsl:template>
  
  
  <xsl:template match="form[@id='theform']//input[@type='text' or @type='date' or @type='hidden']" mode="harvest">
    <xsl:value-of select="concat(@id,': ' ,'''',@prop:value,'''')"/>
    <xsl:if test="position() ne last()">,</xsl:if>
  </xsl:template>
  
  <xsl:template match="output" mode="harvest">
    <xsl:value-of select="concat(@id,':',text())"></xsl:value-of>
    <xsl:if test="position() ne last()">,</xsl:if>
  </xsl:template>
  
  
  <xsl:template match="*|node()|text()" mode="harvest"/>
</xsl:stylesheet>