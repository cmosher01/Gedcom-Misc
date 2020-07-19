<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!--
    gedcom-unftmevent
    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .
    Replaces EVEN tag with value from child TYPE.

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



    0 INDI
    1 EVEN value
    2 TYPE _FOO

    ->

    0 INDI
    1 _FOO value
    2 TYPE _FOO

    Example usage:
    xslt-pipeline -\-dom=input.xml -\-param=tag:_FOO -\-xslt=gedcom-unftmevent.xslt >input.unftmevent.xml
    diff -u input.xml input.unftmevent.xml | colordiff
-->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"
>
    <xsl:output method="xml" version="1.1" encoding="UTF-8"/>



    <xsl:param name="tag" required="true"/>



    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="
        /gedcom:nodes
        /gedcom:node[fn:matches(@gedcom:tag, 'INDI', 'i')]
        /gedcom:node[
            fn:matches(@gedcom:tag, 'EVEN', 'i') and
            fn:matches(./gedcom:node[fn:matches(@gedcom:tag, 'TYPE', 'i')][1]/gedcom:value/text(), $tag, 'i')
        ]">
        <xsl:element name="gedcom:node">
            <xsl:apply-templates select="@* except @gedcom:tag"/>
            <xsl:attribute name="gedcom:tag" select="
                .
                /gedcom:node[fn:matches(@gedcom:tag, 'TYPE', 'i')][1]
                /gedcom:value
                /text()"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
