<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
    gedcom-restore-ids
    Copyright © 2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .
    Restores xml:id values is a XML GEDCOM document to (original) values from a master document.

    !!!
    (Only generates gedcom:old-id attributes, for now; does not change any xml:id or xlink:href.)
    !!!

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
-->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:functx="http://www.functx.com"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:param name="tag" required="true" as="xs:string"/>
    <xsl:param name="master" required="true" as="xs:anyURI"/>

    <xsl:key name="mapIds" match="gedcom:node[@xml:id]" use="./gedcom:node[fn:matches(@gedcom:tag, $tag, 'i')]/gedcom:value"/>

    <xsl:template match="/gedcom:nodes/gedcom:node[@xml:id and fn:not(@gedcom:old-id)]">
        <xsl:variable name="newid" select="./gedcom:node[fn:matches(@gedcom:tag, $tag, 'i')]/gedcom:value"/>
        <xsl:variable name="origid">
            <xsl:for-each select="document($master,.)">
                <xsl:variable name="found" select="fn:key('mapIds', $newid)"/>
                <xsl:if test="fn:count($found) = 1">
                    <xsl:value-of select="$found/@xml:id" />
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:if test="fn:string-length($origid) > 0">
                <xsl:attribute name="gedcom:old-id" select="$origid"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
