<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="environment" select="'dev'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="devops-config/environments/environment[name=$environment]"/>
    </xsl:template>
    
    <xsl:template match="environment">
        <xsl:variable name="app-name" select="../../application/name"/>
        <xsl:variable name="env-name" select="name"/>
        <xsl:variable name="namespace" select="kubernetes/namespace"/>
        
        <!-- ConfigMap -->
        <xsl:if test="variables/variable">
            <xsl:text>---
apiVersion: v1
kind: ConfigMap
metadata:
  name: </xsl:text>
            <xsl:value-of select="$app-name"/>
            <xsl:text>-config-</xsl:text>
            <xsl:value-of select="$env-name"/>
            <xsl:text>
</xsl:text>
            <xsl:if test="$namespace">
                <xsl:text>  namespace: </xsl:text>
                <xsl:value-of select="$namespace"/>
                <xsl:text>
</xsl:text>
            </xsl:if>
            <xsl:text>data:
</xsl:text>
            <xsl:for-each select="variables/variable">
                <xsl:text>  </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>: "</xsl:text>
                <xsl:value-of select="value"/>
                <xsl:text>"
</xsl:text>
            </xsl:for-each>
            <xsl:text>
</xsl:text>
        </xsl:if>
        
        <!-- Secrets -->
        <xsl:if test="secrets/secret">
            <xsl:text>---
apiVersion: v1
kind: Secret
metadata:
  name: </xsl:text>
            <xsl:value-of select="$app-name"/>
            <xsl:text>-secrets-</xsl:text>
            <xsl:value-of select="$env-name"/>
            <xsl:text>
</xsl:text>
            <xsl:if test="$namespace">
                <xsl:text>  namespace: </xsl:text>
                <xsl:value-of select="$namespace"/>
                <xsl:text>
</xsl:text>
            </xsl:if>
            <xsl:text>type: Opaque
stringData:
</xsl:text>
            <xsl:for-each select="secrets/secret">
                <xsl:text>  </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>: "PLACEHOLDER_FROM_</xsl:text>
                <xsl:value-of select="source"/>
                <xsl:text>"
</xsl:text>
            </xsl:for-each>
            <xsl:text>
</xsl:text>
        </xsl:if>
        
        <!-- Deployments -->
        <xsl:apply-templates select="services/service" mode="deployment">
            <xsl:with-param name="app-name" select="$app-name"/>
            <xsl:with-param name="env-name" select="$env-name"/>
            <xsl:with-param name="namespace" select="$namespace"/>
        </xsl:apply-templates>
        
        <!-- Services -->
        <xsl:apply-templates select="services/service" mode="service">
            <xsl:with-param name="app-name" select="$app-name"/>
            <xsl:with-param name="env-name" select="$env-name"/>
            <xsl:with-param name="namespace" select="$namespace"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Deployment Template -->
    <xsl:template match="service" mode="deployment">
        <xsl:param name="app-name"/>
        <xsl:param name="env-name"/>
        <xsl:param name="namespace"/>
        
        <xsl:text>---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$env-name"/>
        <xsl:text>
</xsl:text>
        <xsl:if test="$namespace">
            <xsl:text>  namespace: </xsl:text>
            <xsl:value-of select="$namespace"/>
            <xsl:text>
</xsl:text>
        </xsl:if>
        <xsl:text>  labels:
    app: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
    environment: </xsl:text>
        <xsl:value-of select="$env-name"/>
        <xsl:text>
spec:
  replicas: </xsl:text>
        <xsl:choose>
            <xsl:when test="replicas">
                <xsl:value-of select="replicas"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
        <xsl:text>
  selector:
    matchLabels:
      app: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
      component: </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>
  template:
    metadata:
      labels:
        app: </xsl:text>
        <xsl:value-of select="$app-name"/>
        <xsl:text>
        component: </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>
        environment: </xsl:text>
        <xsl:value-of select="$env-name"/>
        <xsl:text>
    spec:
      containers:
      - name: </xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>
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
            <xsl:text>        ports:
</xsl:text>
            <xsl:for-each select="ports/port">
                <xsl:text>        - containerPort: </xsl:text>
                <xsl:value-of select="container"/>
                <xsl:text>
          protocol: </xsl:text>
                <xsl:value-of select="translate(protocol, 'tcp', 'TCP')"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Environment Variables -->
        <xsl:if test="environment/variable or ../../variables/variable or ../../secrets/secret">
            <xsl:text>        env:
</xsl:text>
            <!-- Variables from ConfigMap -->
            <xsl:for-each select="../../variables/variable">
                <xsl:text>        - name: </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>
          valueFrom:
            configMapKeyRef:
              name: </xsl:text>
                <xsl:value-of select="$app-name"/>
                <xsl:text>-config-</xsl:text>
                <xsl:value-of select="$env-name"/>
                <xsl:text>
              key: </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
            <!-- Variables from Secrets -->
            <xsl:for-each select="../../secrets/secret">
                <xsl:text>        - name: </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>
          valueFrom:
            secretKeyRef:
              name: </xsl:text>
                <xsl:value-of select="$app-name"/>
                <xsl:text>-secrets-</xsl:text>
                <xsl:value-of select="$env-name"/>
                <xsl:text>
              key: </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
            <!-- Service-specific variables -->
            <xsl:for-each select="environment/variable">
                <xsl:text>        - name: </xsl:text>
                <xsl:value-of select="name"/>
                <xsl:text>
          value: "</xsl:text>
                <xsl:value-of select="value"/>
                <xsl:text>"
</xsl:text>
            </xsl:for-each>
        </xsl:if>
        
        <!-- Resources -->
        <xsl:if test="../../kubernetes/resources">
            <xsl:text>        resources:
</xsl:text>
            <xsl:if test="../../kubernetes/resources/requests">
                <xsl:text>          requests:
</xsl:text>
                <xsl:if test="../../kubernetes/resources/requests/cpu">
                    <xsl:text>            cpu: </xsl:text>
                    <xsl:value-of select="../../kubernetes/resources/requests/cpu"/>
                    <xsl:text>
</xsl:text>
                </xsl:if>
                <xsl:if test="../../kubernetes/resources/requests/memory">
                    <xsl:text>            memory: </xsl:text>
                    <xsl:value-of select="../../kubernetes/resources/requests/memory"/>
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="../../kubernetes/resources/limits">
                <xsl:text>          limits:
</xsl:text>
                <xsl:if test="../../kubernetes/resources/limits/cpu">
                    <xsl:text>            cpu: </xsl:text>
                    <xsl:value-of select="../../kubernetes/resources/limits/cpu"/>
                    <xsl:text>
</xsl:text>
                </xsl:if>
                <xsl:if test="../../kubernetes/resources/limits/memory">
                    <xsl:text>            memory: </xsl:text>
                    <xsl:value-of select="../../kubernetes/resources/limits/memory"/>
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:if>
        
        <!-- Command -->
        <xsl:if test="command">
            <xsl:text>        command:
</xsl:text>
            <xsl:call-template name="split-command">
                <xsl:with-param name="command" select="command"/>
            </xsl:call-template>
        </xsl:if>
        
        <!-- Working Directory -->
        <xsl:if test="working_dir">
            <xsl:text>        workingDir: </xsl:text>
            <xsl:value-of select="working_dir"/>
            <xsl:text>
</xsl:text>
        </xsl:if>
        
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <!-- Service Template -->
    <xsl:template match="service" mode="service">
        <xsl:param name="app-name"/>
        <xsl:param name="env-name"/>
        <xsl:param name="namespace"/>
        
        <xsl:if test="ports/port">
            <xsl:text>---
apiVersion: v1
kind: Service
metadata:
  name: </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>-service-</xsl:text>
            <xsl:value-of select="$env-name"/>
            <xsl:text>
</xsl:text>
            <xsl:if test="$namespace">
                <xsl:text>  namespace: </xsl:text>
                <xsl:value-of select="$namespace"/>
                <xsl:text>
</xsl:text>
            </xsl:if>
            <xsl:text>  labels:
    app: </xsl:text>
            <xsl:value-of select="$app-name"/>
            <xsl:text>
    component: </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>
spec:
  type: </xsl:text>
            <xsl:choose>
                <xsl:when test="../../kubernetes/service/type">
                    <xsl:value-of select="../../kubernetes/service/type"/>
                </xsl:when>
                <xsl:otherwise>ClusterIP</xsl:otherwise>
            </xsl:choose>
            <xsl:text>
  selector:
    app: </xsl:text>
            <xsl:value-of select="$app-name"/>
            <xsl:text>
    component: </xsl:text>
            <xsl:value-of select="name"/>
            <xsl:text>
  ports:
</xsl:text>
            <xsl:for-each select="ports/port">
                <xsl:text>  - port: </xsl:text>
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
            <xsl:text>
</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- Helper template to split command -->
    <xsl:template name="split-command">
        <xsl:param name="command"/>
        <xsl:choose>
            <xsl:when test="contains($command, ' ')">
                <xsl:text>        - </xsl:text>
                <xsl:value-of select="substring-before($command, ' ')"/>
                <xsl:text>
</xsl:text>
                <xsl:call-template name="split-command">
                    <xsl:with-param name="command" select="substring-after($command, ' ')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>        - </xsl:text>
                <xsl:value-of select="$command"/>
                <xsl:text>
</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
