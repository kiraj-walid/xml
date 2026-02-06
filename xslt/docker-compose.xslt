<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="environment" select="'dev'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="devops-config/environments/environment[name=$environment]"/>
    </xsl:template>
    
    <xsl:template match="environment">
        <xsl:text>version: '3.8'

services:
</xsl:text>
        <xsl:apply-templates select="services/service"/>
    </xsl:template>
    
    <xsl:template match="service">
        <xsl:text>  </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>:
    image: </xsl:text>
        <xsl:value-of select="image"/>
        <xsl:if test="tag">
            <xsl:text>:</xsl:text>
            <xsl:value-of select="tag"/>
        </xsl:if>
        <xsl:text>
</xsl:text>
        
        <!-- Ports -->
        <xsl:if test="ports/port">
            <xsl:text>    ports:
</xsl:text>
            <xsl:for-each select="ports/port">
                <xsl:text>      - "</xsl:text>
                <xsl:value-of select="host"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="container"/>
                <xsl:if test="protocol and protocol != 'tcp'">
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="protocol"/>
                </xsl:if>
                <xsl:text>"
</xsl:text>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Volumes -->
        <xsl:if test="volumes/volume">
            <xsl:text>    volumes:
</xsl:text>
            <xsl:for-each select="volumes/volume">
                <xsl:text>      - </xsl:text>
                <xsl:value-of select="host_path"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="container_path"/>
                <xsl:if test="mode and mode != 'rw'">
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="mode"/>
                </xsl:if>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Environment Variables -->
        <xsl:if test="environment/variable or ../../variables/variable">
            <xsl:text>    environment:
</xsl:text>
            <!-- Variables globales de l'environnement -->
            <xsl:for-each select="../../variables/variable">
                <xsl:text>      - </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>=</xsl:text>
                <xsl:value-of select="value"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
            <!-- Variables spécifiques au service -->
            <xsl:for-each select="environment/variable">
                <xsl:text>      - </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>=</xsl:text>
                <xsl:value-of select="value"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Depends On -->
        <xsl:if test="depends_on/service">
            <xsl:text>    depends_on:
</xsl:text>
            <xsl:for-each select="depends_on/service">
                <xsl:text>      - </xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Command -->
        <xsl:if test="command">
            <xsl:text>    command: </xsl:text>
            <xsl:value-of select="command"/>
            <xsl:text>
</xsl:text>
        </xsl:if>
        
        <!-- Working Directory -->
        <xsl:if test="working_dir">
            <xsl:text>    working_dir: </xsl:text>
            <xsl:value-of select="working_dir"/>
            <xsl:text>
</xsl:text>
        </xsl:if>
        
        <xsl:text>
</xsl:text>
    </xsl:template>
</xsl:stylesheet>
