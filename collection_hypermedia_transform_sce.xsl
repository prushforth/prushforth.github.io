<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:as="http://atomserver.org/namespaces/1.0/" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" xmlns:app="http://www.w3.org/2007/app" xmlns:atom="http://www.w3.org/2005/Atom"  xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"    xmlns:prop="http://saxonica.com/ns/html-property" xmlns:style="http://saxonica.com/ns/html-style-property" exclude-result-prefixes="xs xsl os as georss gml app atom prop js" extension-element-prefixes="ixsl"  xmlns:js="http://saxonica.com/ns/globalJS" xmlns:geogratis="http://geogratis.gc.ca/namespace" version="2.0">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="nl">
        <xsl:text>&#xa;</xsl:text>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:result-document href="#ui">
            <xsl:apply-templates select="//app:collection/atom:link[@rel='api']" mode="generate-ui"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="atom:link[@rel='api']" mode="generate-ui">
        <form id="theform" target="_blank" method="get" data-base="{resolve-uri(base-uri(.),base-uri(/app:service|/atom:feed))}" data-tref="{@tref}">
            <xsl:apply-templates select="atom:uriQuery" mode="generate-ui"/>
            <xsl:apply-templates select="atom:categoryQuery" mode="generate-ui"/>
            <input type="button" value="Submit" name="submit"/><br/>
        </form>
    </xsl:template>
    
    <xsl:template match="input[@type='button'][@name='submit']" mode="ixsl:onclick">
        <xsl:result-document href="#results" method="ixsl:replace-content">
            <xsl:variable name="code">
                UriTemplate.parse('<xsl:value-of select="ixsl:page()//form[@id='theform']/@data-tref"/>').expand({<xsl:apply-templates select="//form[@id='theform']/(div | input) except self::node()" mode="harvest"/>})
            </xsl:variable>
            <xsl:variable name="base" select="ixsl:page()//form/@data-base"/>
            <xsl:variable name="url" select="resolve-uri(ixsl:eval(string($code)), $base)"/>
            <xsl:variable name="results" select="doc($url)"/>
            <xsl:apply-templates select="doc($url)" mode="process-results"/>
            <p>xml:base from document: <xsl:value-of select="$base"/></p>
            <p>Here's the code: <xsl:value-of select="$code"/></p>
            <p>Calculated URI: <xsl:value-of select="$url"/></p>  
        </xsl:result-document>
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
    
    <xsl:template match="select[@id='schemes']" mode="ixsl:onchange">
        <!-- this result-document technique is described here: http://www.saxonica.com/ce/user-doc/1.1/index.html#!coding/result-documents -->
        <xsl:result-document href="?select=//datalist[@id='categoriesSuggestions']" method="ixsl:replace-content">
            <xsl:for-each select="geogratis:getCategorySuggestions()">
                <option value="{@term}" label="{@label}"/>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
        
    <xsl:template match="atom:term" mode="generate-ui">
        <xsl:variable name="vtref" select="replace(atom:link/@tref,'\{\?q\}\{\+scheme\}', '?q={q}&amp;scheme={+scheme}&amp;alt=xml')"></xsl:variable>
        <div id="term">
            <label for="categorySuggestions">Category Term: </label>
            <input type="text" id="categorySuggestions" list="categoriesSuggestions" data-tref="{$vtref}" data-base="{resolve-uri(base-uri(atom:link),base-uri(.))}"/>
            <datalist id="categoriesSuggestions">
            </datalist>
        </div>
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
            <input id="cardinalDirectionsSuggestions-q" type="text" list="place_search_results"/>
            <datalist id="place_search_results"></datalist>
        </div>
    </xsl:template>
    
    <xsl:template match="atom:west|atom:south|atom:east|atom:north" mode="generate-ui">
        <label for="{local-name()}"><xsl:value-of select="local-name()"/></label>
        <input id="{local-name()}" type="text"/>
        <xsl:if test="position() eq last()">
            <xsl:value-of select="$nl"/><br/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="atom:uriQuery/atom:alt" mode="generate-ui">
        <input type="hidden" id="alt" value="xml"></input>
    </xsl:template>
    
    <xsl:template match="atom:uriQuery/atom:q" mode="generate-ui">
        <label for="q">Search:</label>
        <input type="text" id="q"/><br/>
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
    
    <xsl:template match="input[@id='cardinalDirectionsSuggestions-q']" mode="ixsl:onkeypress">
        <xsl:if test="string-length(@prop:value) &gt; 2">
            <xsl:variable name="tref" select="replace(ancestor::div[1]/@data-tref,'\{q\}','q={q}')"></xsl:variable>
            <xsl:variable name="template">
                UriTemplate.parse('<xsl:value-of select="$tref"/>').expand({<xsl:value-of select="'q'"/>:'<xsl:value-of select="@prop:value"/>'})
            </xsl:variable>
            <xsl:variable name="placeSearchResults" select="doc(resolve-uri(ixsl:eval(string($template)),ancestor::div[1]/@data-base))"/>
            <xsl:result-document href="#diagnostics" method="ixsl:replace-content">
                <p>template is: <xsl:value-of select="$template"/></p>
                <p>search result is: <xsl:value-of select="$placeSearchResults"/></p>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    
    <!-- if we don't include this template, the default templates are applied, which don't do what we want -->
    <xsl:template match="*" mode="generate-ui">
        <xsl:apply-templates select="*" mode="generate-ui"/>
    </xsl:template>
    
    <xsl:template match="form[@id='theform']/div[@data-tref][@id != 'cardinalDirectionsSuggestions'][@id != 'bbox']" mode="harvest">
        <xsl:value-of select="concat(@id,': ')"/>UriTemplate.parse('<xsl:value-of select="@data-tref"/>').expand({<xsl:apply-templates select="div | input" mode="harvest"/>})
        <xsl:if test="position() ne last()">,</xsl:if>
    </xsl:template>
    
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
    
    <xsl:template match="*|node()|text()" mode="harvest"/>
<!--    <xsl:template match="atom:categoryQuery" mode="generate-script"/>
-->    <xsl:template match="atom:mediaType" mode="generate-script"/>
    <xsl:template match="*|@*|text()"/>
    
    
    
</xsl:stylesheet>
