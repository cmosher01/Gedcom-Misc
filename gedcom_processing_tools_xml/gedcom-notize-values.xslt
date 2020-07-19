<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
    gedcom-notize-values
    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .
    Convert values on GEDCOM lines (assumed non-standard) into subordinate NOTEs.

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

    xslt-pipeline -\-dom=input.xml -\-param=tag:resi -\-xslt=gedcom-notize-values.xslt >input.na.xml
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

    <xsl:template match="/gedcom:nodes/gedcom:node/gedcom:node[fn:matches(@gedcom:tag, $tag, 'i') and fn:string-length(./gedcom:value/text()) > 0]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="gedcom:node">
                <xsl:attribute name="gedcom:tag" select="'NOTE'"/>
                <xsl:element name="gedcom:value">
                    <xsl:value-of select="gedcom:value"/>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates select="gedcom:node"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
