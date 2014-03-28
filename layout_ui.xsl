<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" 
  xmlns:as="http://atomserver.org/namespaces/1.0/" xmlns:georss="http://www.georss.org/georss" 
  xmlns:gml="http://www.opengis.net/gml" xmlns:app="http://www.w3.org/2007/app" 
  xmlns:atom="http://www.w3.org/2005/Atom"  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"    
  xmlns:prop="http://saxonica.com/ns/html-property" 
  xmlns:style="http://saxonica.com/ns/html-style-property" 
  exclude-result-prefixes="xs xsl os as georss gml app atom prop js" 
  extension-element-prefixes="ixsl"  xmlns:js="http://saxonica.com/ns/globalJS" 
  xmlns:geogratis="http://geogratis.gc.ca/namespace" version="2.0">
  
  <xsl:template match="atom:link[@rel='api']" mode="generate-ui">
    <form id="theform" target="_blank" method="get" data-base="{resolve-uri(base-uri(.),base-uri(/app:service|/atom:feed))}" data-tref="{@tref}">
      <xsl:apply-templates select="atom:uriQuery" mode="generate-ui"/>
      <xsl:apply-templates select="atom:categoryQuery" mode="generate-ui"/>
      <input type="button" value="Submit" name="submit"/><br/>
    </form>
  </xsl:template>
  <xsl:template match="atom:uriQuery" mode="generate-ui">
    <!-- TODO Fix the templates in the source -->
    <xsl:variable name="vtref" select="replace(replace(@tref,'\{\+q\}','q={q}'),'\{bbox\}','&amp;bbox={bbox*}')"/>
    
    <div data-tref="{$vtref}" id="uriQuery">
      <xsl:apply-templates select="*" mode="generate-ui"/>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:categoryQuery" mode="generate-ui">
    <div data-tref="{@tref}" id="categoryQuery">
      <div id="catPathSep"><value><xsl:value-of select="atom:catPathSep/atom:value"/></value></div>
      <xsl:apply-templates select="atom:categories" mode="generate-ui"/>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:categories" mode="generate-ui">
    <div id="categories" data-tref="{@tref}">
      <xsl:apply-templates select="atom:expression" mode="generate-ui"/>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:expression" mode="generate-ui">
    <!-- expecting an operator here, do nothing with it for the moment... -->
    <div data-tref="{@tref}" id="expression">
      <xsl:apply-templates select="atom:expr" mode="generate-ui"/>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:expr" mode="generate-ui">
    <!-- expecting a value for expression and a value for predicate -->
    <xsl:apply-templates select="atom:value" mode="generate-ui"/>
  </xsl:template>
  
  <xsl:template match="atom:expr/atom:value" mode="generate-ui">
    <div data-tref="{@tref}">
      <xsl:apply-templates select="*" mode="generate-ui"/>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:predicate" mode="generate-ui">
    <div id="predicate" data-tref="{@tref}">
      <xsl:apply-templates select="*" mode="generate-ui"/>
    </div>        
  </xsl:template>
  
  <xsl:template match="atom:scheme" mode="generate-ui">
    <div id="scheme">
      <label for="schemes">Category Scheme:</label>
      <select id="schemes">
        <xsl:for-each select="atom:value">
          <option value="{.}"><xsl:value-of select="@label"/></option>
        </xsl:for-each>
      </select>
    </div>
  </xsl:template>

  <xsl:template match="atom:term" mode="generate-ui">
    <!--        <xsl:variable name="vtref" select="replace(atom:link/@tref,'\{\?q\}\{\+scheme\}', '?q={q}&amp;scheme={+scheme}&amp;alt=xml')"></xsl:variable 
--> 
    <!-- the following is hard-coded, but should be replaced when revision 2007 hits beta -->
    <xsl:variable name="vtref" select="'?q={+q}&amp;scheme={+scheme}&amp;alt=xml'"/>
    <div id="term">
      <label for="categorySuggestions">Category Term: </label>
      <input type="text" id="categorySuggestions" list="categoriesSuggestions" data-tref="{$vtref}" data-base="{resolve-uri(base-uri(atom:link),base-uri(.))}"/>
      <datalist id="categoriesSuggestions">
      </datalist>
    </div>
  </xsl:template>
  <xsl:template match="atom:uriQuery/atom:bbox" mode="generate-ui">
    <div data-tref="{@tref}" id="bbox">
      <xsl:apply-templates select="atom:cardinalDirections" mode="generate-ui"/>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:cardinalDirections" mode="generate-ui">
    <div id="cardinalDirections" data-tref="{@tref}">
      <xsl:apply-templates select="atom:link[@rel='suggestions']"  mode="generate-ui"/>
      <xsl:apply-templates select="atom:west|atom:south|atom:east|atom:north"  mode="generate-ui"/>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:link[@rel='suggestions']" mode="generate-ui">
    <div data-tref="{@tref}" data-base="{@xml:base}" id="cardinalDirectionsSuggestions">
      <label for="cardinalDirectionsSuggestions-q">Location search:</label>
      <input id="cardinalDirectionsSuggestions-q" type="text" list="place_search_results" placeholder="Type a place or map name"/>
      <datalist id="place_search_results"></datalist>
      <span>
        <input id="get-cardinalDirectionsSuggestions-q-button" type="button" ><i>Search</i></input>
      </span>
    </div>
  </xsl:template>
  
  <xsl:template match="atom:west|atom:south|atom:east|atom:north" mode="generate-ui">
    <label for="{local-name()}"><xsl:value-of select="local-name()"/></label>
    <output name="{local-name()}" type="text"/>
    <xsl:if test="position() eq last()">
      <xsl:value-of select="$nl"/><br/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="atom:uriQuery/atom:alt" mode="generate-ui">
    <input type="hidden" id="alt" value="xml"></input>
  </xsl:template>
  
  <xsl:template match="atom:uriQuery/atom:q" mode="generate-ui">
    <label for="q">Search:</label>
    <input type="text" id="q" autofocus="true"/><br/>
  </xsl:template>
  
  <xsl:template match="atom:uriQuery/atom:editedMin" mode="generate-ui">
    <label for="editedMin">Edited since:</label>
    <input type="date" id="editedMin"/><br/>
  </xsl:template>
  
  <xsl:template match="atom:uriQuery/atom:updatedMin" mode="generate-ui">
    <label for="updatedMin">Updated since:</label>
    <input type="date" id="updatedMin"/>
  </xsl:template>
  
  <xsl:template match="atom:uriQuery/atom:updatedMax" mode="generate-ui">
    <label for="updatedMax">Updated before:</label>
    <input type="date" id="updatedMax"/><br/>
    <xsl:value-of select="$nl"/>
  </xsl:template>
  
  <xsl:template match="atom:uriQuery/atom:publishedMin" mode="generate-ui">
    <label for="publishedMin">Published since:</label>
    <input type="date" id="publishedMin"/>
  </xsl:template>
  
  <xsl:template match="atom:uriQuery/atom:publishedMax" mode="generate-ui">
    <label for="publishedMax">Published before:</label>
    <input type="date" id="publishedMax"/><br/>
    <xsl:value-of select="$nl"/>
  </xsl:template>
  <!-- if we don't include this template, the default templates are applied, which don't do what we want -->
  <xsl:template match="*" mode="generate-ui">
    <xsl:apply-templates select="*" mode="generate-ui"/>
  </xsl:template>
  
  
</xsl:stylesheet>