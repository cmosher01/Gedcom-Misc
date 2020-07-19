<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
    gedcom-eventize
    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .
    Convert (custom) GEDCOM events into EVEN.TYPE events

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Example usage:

    xslt-pipeline -\-dom=input.xml -\-param=tag:_milt -\-param=type:Military -\-xslt=gedcom-eventize.xslt >input.ev.xml
-->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:exsl="http://exslt.org/common"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:param name="tag" required="true"/>
    <xsl:param name="type" required="true"/>

    <xsl:template match="/gedcom:nodes/gedcom:node/gedcom:node[fn:matches(@gedcom:tag, $tag, 'i')]">
        <xsl:element name="gedcom:node">
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="gedcom:tag" select="'EVEN'"/>
            <xsl:element name="gedcom:node">
                <xsl:apply-templates select="@*"/>
                <xsl:attribute name="gedcom:tag" select="'TYPE'"/>
                <xsl:element name="gedcom:value">
                    <xsl:value-of select="$type"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="gedcom:node">
                <xsl:apply-templates select="@*"/>
                <xsl:attribute name="gedcom:tag" select="'NOTE'"/>
                <xsl:element name="gedcom:value">
                    <xsl:value-of select="gedcom:value"/>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates select="gedcom:node"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
