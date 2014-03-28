<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" 
  xmlns:as="http://atomserver.org/namespaces/1.0/" xmlns:georss="http://www.georss.org/georss" 
  xmlns:gml="http://www.opengis.net/gml" xmlns:app="http://www.w3.org/2007/app" 
  xmlns:atom="http://www.w3.org/2005/Atom"  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"    
  xmlns:prop="http://saxonica.com/ns/html-property" xmlns:style="http://saxonica.com/ns/html-style-property" 
  exclude-result-prefixes="xs xsl os as georss gml app atom prop js" 
  extension-element-prefixes="ixsl"  xmlns:js="http://saxonica.com/ns/globalJS" 
  xmlns:geogratis="http://geogratis.gc.ca/namespace" version="2.0">
  
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  
  <xsl:include href="layout_ui.xsl"/>
  <xsl:include href="process_events.xsl"/>
  
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:result-document href="#ui">
      <xsl:apply-templates select="//app:collection/atom:link[@rel='api']" mode="generate-ui"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="*|@*|text()"/>
  
</xsl:stylesheet>
