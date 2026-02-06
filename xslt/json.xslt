<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="environment" select="'dev'"/>
    
    <xsl:template match="/">
        <xsl:text>{
  "application": {
    "name": "</xsl:text>
        <xsl:value-of select="devops-config/application/name"/>
        <xsl:text>",
    "version": "</xsl:text>
        <xsl:value-of select="devops-config/application/version"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="devops-config/application/description">
            <xsl:text>,
    "description": "</xsl:text>
            <xsl:value-of select="devops-config/application/description"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:text>
  },
  "environment": "</xsl:text>
        <xsl:value-of select="$environment"/>
        <xsl:text>",
  "services": [
</xsl:text>
        <xsl:apply-templates select="devops-config/environments/environment[name=$environment]/services/service"/>
        <xsl:text>  ],
  "variables": [
</xsl:text>
        <xsl:apply-templates select="devops-config/environments/environment[name=$environment]/variables/variable" mode="variables"/>
        <xsl:text>  ],
  "secrets": [
</xsl:text>
        <xsl:apply-templates select="devops-config/environments/environment[name=$environment]/secrets/secret" mode="secrets"/>
        <xsl:text>  ]
}
</xsl:text>
    </xsl:template>
    
    <xsl:template match="service">
        <xsl:text>    {
      "name": "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>",
      "image": "</xsl:text>
        <xsl:value-of select="image"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="tag">
            <xsl:text>,
      "tag": "</xsl:text>
            <xsl:value-of select="tag"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="ports/port">
            <xsl:text>,
      "ports": [
</xsl:text>
            <xsl:for-each select="ports/port">
                <xsl:text>        {
          "host": </xsl:text>
                <xsl:value-of select="host"/>
                <xsl:text>,
          "container": </xsl:text>
                <xsl:value-of select="container"/>
                <xsl:if test="protocol">
                    <xsl:text>,
          "protocol": "</xsl:text>
                    <xsl:value-of select="protocol"/>
                    <xsl:text>"</xsl:text>
                </xsl:if>
                <xsl:text>
        }</xsl:text>
                <xsl:if test="position() != last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
            <xsl:text>      ]</xsl:text>
        </xsl:if>
        <xsl:if test="environment/variable">
            <xsl:text>,
      "environment": {
</xsl:text>
            <xsl:for-each select="environment/variable">
                <xsl:text>        "</xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>": "</xsl:text>
                <xsl:value-of select="value"/>
                <xsl:text>"</xsl:text>
                <xsl:if test="position() != last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
            <xsl:text>      }</xsl:text>
        </xsl:if>
        <xsl:if test="command">
            <xsl:text>,
      "command": "</xsl:text>
            <xsl:value-of select="command"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="working_dir">
            <xsl:text>,
      "working_dir": "</xsl:text>
            <xsl:value-of select="working_dir"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:if test="replicas">
            <xsl:text>,
      "replicas": </xsl:text>
            <xsl:value-of select="replicas"/>
        </xsl:if>
        <xsl:text>
    }</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="variable" mode="variables">
        <xsl:text>    {
      "name": "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>",
      "value": "</xsl:text>
        <xsl:value-of select="value"/>
        <xsl:text>"
    }</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="secret" mode="secrets">
        <xsl:text>    {
      "name": "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>",
      "source": "</xsl:text>
        <xsl:value-of select="source"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="key">
            <xsl:text>,
      "key": "</xsl:text>
            <xsl:value-of select="key"/>
            <xsl:text>"</xsl:text>
        </xsl:if>
        <xsl:text>
    }</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>
</xsl:text>
    </xsl:template>
</xsl:stylesheet>
