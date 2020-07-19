<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
    gedcom-note-gc
    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .
    Removes unreferenced top-level NOTE records.

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

    xslt-pipeline -\-dom=input.xml -\-xslt=gedcom-note-gc.xslt >input.note_gc.xml
    diff -u input.xml input.note_gc.xml | colordiff
-->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:exsl="http://exslt.org/common"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:key name="mapIds" match="gedcom:value[@xlink:href]" use="@xlink:href"/>
    <xsl:template match="/gedcom:nodes/gedcom:node[@gedcom:tag = 'NOTE' and fn:not(fn:boolean(fn:key('mapIds', fn:concat('#', @xml:id))))]"/>
</xsl:stylesheet>
