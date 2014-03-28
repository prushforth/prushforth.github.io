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

  <xsl:template match="/atom:feed" mode="process-results">
    <table>
      <thead><th align="left">Title</th></thead>
      <tbody>
        <xsl:apply-templates select="atom:entry" mode="process-results"/>
      </tbody>
    </table>
  </xsl:template>
  
  <xsl:template match="atom:entry" mode="process-results">
    <tr>
      <td>
        <a class="results" href="{resolve-uri(atom:link[starts-with(@type,'application/atom+xml;type=entry')]/@href, base-uri(.))}"><xsl:value-of select="atom:title"/></a>
      </td>
    </tr>
  </xsl:template>
  
  
</xsl:stylesheet>