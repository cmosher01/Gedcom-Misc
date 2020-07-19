(:
    gedcom-check-len
    Finds possibly truncated citations (PAGE) in GEDCOM (in XML format)

    Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

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

    Ancestry.com (as of 2020) will truncate citation extries ("PAGE" in GEDCOM) to around 256 characters.
    This XQuery program detects citations near that length and writes them to stdout.
    Of course, there may be false positives, so human inspection will be necessary to determine
    if the entries are actually truncated or not.

    Example command-line use:

    alias saxon='java -cp ~/.gradle/caches/modules-2/files-2.1/net.sf.saxon/Saxon-HE/10.1/f37d76f5705830d19147c4aa1b564ecfbcc05bd/Saxon-HE-10.1.jar'
    saxon net.sf.saxon.Query -s:input.xml -q:gedcom-check-len.xql -o:input_possible_truncation.xml
    cat input_possible_truncation.xml | xmllint --pretty 1 - | source-highlight -s xml -f esc256 | less -R

:)

declare namespace gedcom="https://mosher.mine.nu/xmlns/gedcom";
declare namespace saxon="http://saxon.sf.net/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

declare option saxon:output "indent=yes";



declare function functx:fragment-from-uri($uri as xs:string?) as xs:string? {
    fn:substring-after($uri,'#')
};

declare function gedcom:sub($parent as element(), $name as xs:string) as element(gedcom:node)* {
    $parent/gedcom:node[@gedcom:tag=$name]
};



declare variable $len as xs:positiveInteger external := xs:positiveInteger(256);
declare variable $r as xs:positiveInteger external := xs:positiveInteger(3);


<suspects xmlns:gedcom="https://mosher.mine.nu/xmlns/gedcom"> {
    for $citation
    in /gedcom:nodes/gedcom:sub(.,"INDI")/*/gedcom:sub(.,"SOUR")/gedcom:sub(.,"PAGE")/gedcom:value
    let $c := fn:string-length($citation)
    where ($len - $r) le $c and $c le ($len + $r)
    return
    <suspect>
        <title> {
            let $sour_ref := $citation/../../gedcom:value/@xlink:href
            let $sour_uri := fn:resolve-uri($sour_ref, fn:base-uri())
            (: TODO check to make sure it's in the same document :)
            let $id := functx:fragment-from-uri($sour_uri)
            return fn:id($id)/gedcom:sub(.,"TITL")/gedcom:value/text()
        }
        </title>
        <citation> {
            $citation/text()
        }
        </citation>
        <length> {
            fn:string-length($citation/text())
        }
        </length>
    </suspect>
}
</suspects>
