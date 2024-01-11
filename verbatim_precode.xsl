<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    version     = "1.0"
    xmlns:xsl   = "http://www.w3.org/1999/XSL/Transform"
    xmlns:ltx   = "http://dlmf.nist.gov/LaTeXML"
    xmlns:func  = "http://exslt.org/functions"
    xmlns:f     = "http://dlmf.nist.gov/LaTeXML/functions"
    extension-element-prefixes="func f"
    exclude-result-prefixes = "ltx func f">

  <xsl:import href="urn:x-LaTeXML:XSLT:LaTeXML-html5.xsl"/>

  <xsl:template match="ltx:verbatim">
    <xsl:param name="context"/>
    <xsl:choose>
      <xsl:when test="contains(text(),'&#xA;')">
        <xsl:element name="pre" namespace="{$html_ns}">
          <xsl:element name="code" namespace="{$html_ns}">
            <xsl:call-template name="add_id"/>
            <xsl:call-template name="add_attributes">
              <xsl:with-param name="extra_classes">
                <xsl:choose>
                  <xsl:when test="contains(text(),'function')"> <!-- function appears in pseudocode only -->
                    language-julia
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="contains(text(),'inline')"> <!-- function appears in pseudocode only -->
                        language-c
                      </xsl:when>
                      <xsl:otherwise>
                        language-python
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="." mode="begin">
              <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
            <xsl:apply-templates>
              <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="." mode="end">
              <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="code" namespace="{$html_ns}">
          <xsl:call-template name="add_id"/>
          <xsl:call-template name="add_attributes"/>
          <xsl:apply-templates select="." mode="begin">
            <xsl:with-param name="context" select="$context"/>
          </xsl:apply-templates>
          <xsl:apply-templates>
            <xsl:with-param name="context" select="$context"/>
          </xsl:apply-templates>
          <xsl:apply-templates select="." mode="end">
            <xsl:with-param name="context" select="$context"/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
