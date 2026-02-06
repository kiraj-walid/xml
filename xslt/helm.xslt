<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="environment" select="'dev'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="devops-config/environments/environment[name=$environment]"/>
    </xsl:template>
    
    <xsl:template match="environment">
        <xsl:variable name="app-name" select="../../application/name"/>
        <xsl:variable name="app-version" select="../../application/version"/>
        
        <xsl:text># Helm Chart généré depuis XML
# Application: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
# Version: </xsl:text>
        <xsl:value-of select="$app-version"/>
        <xsl:text>
# Environnement: </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>

---
# Chart.yaml
apiVersion: v2
name: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
description: Helm chart for </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
type: application
version: </xsl:text>
        <xsl:value-of select="$app-version"/>
        <xsl:text>
appVersion: "</xsl:text>
        <xsl:value-of select="$app-version"/>
        <xsl:text>"

---
# values.yaml
replicaCount: 1

image:
  repository: ""
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

env:
</xsl:text>
        <xsl:for-each select="variables/variable">
            <xsl:text>  - name: </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>
    value: "</xsl:text>
            <xsl:value-of select="value"/>
            <xsl:text>"
</xsl:text>
        </xsl:for-each>

        <xsl:text>
---
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
  labels:
    app: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
  template:
    metadata:
      labels:
        app: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
    spec:
      containers:
</xsl:text>
        <xsl:apply-templates select="services/service" mode="helm-deployment"/>
        <xsl:text>
---
# templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
spec:
  type: {{ .Values.service.type }}
  ports:
</xsl:text>
        <xsl:for-each select="services/service[ports/port]">
            <xsl:for-each select="ports/port">
                <xsl:text>    - port: </xsl:text>
                <xsl:value-of select="host"/>
                <xsl:text>
      targetPort: </xsl:text>
                <xsl:value-of select="container"/>
                <xsl:text>
      protocol: </xsl:text>
                <xsl:value-of select="translate(protocol, 'tcp', 'TCP')"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:text>  selector:
    app: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="service" mode="helm-deployment">
        <xsl:text>      - name: </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>
        image: "{{ .Values.image.repository }}:</xsl:text>
        <xsl:choose>
            <xsl:when test="tag">
                <xsl:value-of select="tag"/>
            </xsl:when>
            <xsl:otherwise>latest</xsl:otherwise>
        </xsl:choose>
        <xsl:text>"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
</xsl:text>
        <xsl:for-each select="ports/port">
            <xsl:text>          - containerPort: </xsl:text>
            <xsl:value-of select="container"/>
            <xsl:text>
</xsl:text>
        </xsl:for-each>
        <xsl:text>        env:
</xsl:text>
        <xsl:for-each select="environment/variable">
            <xsl:text>          - name: </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>
            value: "</xsl:text>
            <xsl:value-of select="value"/>
            <xsl:text>"
</xsl:text>
        </xsl:for-each>
        <xsl:text>        resources:
          {{- toYaml .Values.resources | nindent 12 }}
</xsl:text>
    </xsl:template>
</xsl:stylesheet>
