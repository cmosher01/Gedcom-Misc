<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
    gedcom-note-gc
    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .
    Cleans up NOTE records in XML GEDCOM document.

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

    1. Deletes empty NOTEs (records or in-line).
    2. Copies NOTE records to in-line references.
    3. Deletes NOTE records.

    Example usage:

    xslt-pipeline -\-dom=input.xml -\-xslt=gedcom-note-gc.xslt >input.note_gc.xml
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
    <xsl:function name="functx:trim" as="xs:string" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="replace(replace($arg,'\s+$',''),'^\s+','')"/>
    </xsl:function>

    <!-- delete top-level NOTE records -->
    <xsl:template match="/gedcom:nodes/gedcom:node[fn:matches(@gedcom:tag, 'NOTE', 'i')]"/>

    <!-- delete blank in-line NOTEs -->
    <xsl:template match="
        gedcom:node[
            fn:matches(@gedcom:tag, 'NOTE', 'i') and
            not(./@xml:id) and
            not(./gedcom:value/@xlink:href) and
            fn:string-length(functx:trim(./gedcom:value/text())) = 0]"/>

    <!-- in-line NOTE references, unless they are blank, in which case delete them -->
    <xsl:template match="gedcom:node[fn:matches(@gedcom:tag, 'NOTE', 'i') and ./gedcom:value/@xlink:href]">
        <xsl:variable name="note" select="fn:element-with-id(fn:substring(./gedcom:value/@xlink:href, 2))"/>
        <xsl:if test="fn:string-length(functx:trim($note)) > 0">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:element name="gedcom:value">
                    <xsl:value-of select="$note"/>
                </xsl:element>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
