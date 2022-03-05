#!/bin/sh -x

# requires:
# lyx or libreoffice or ConTeXt (depending in input source file)
# convert (ImageMagick)
# qpdf

if [ -z "$3" ] ; then
    echo "usage: $0 lyx-or-odt-file user-pass owner-pass"
    exit 1
fi

cvt_opts="-density 300 -compress jpeg -quality 35 -sampling-factor 4:2:0 -type TrueColor -interlace plane -define jpeg:dct-method=float -strip"
encrypt_opts="--verbose --replace-input --encrypt $2 $3 256 --extract=n --assemble=n --annotate=n --form=n --modify-other=n --print=none --"
show_opts="--password=$2 --check --show-object=trailer --show-pages --with-images"

if [ ! -e "$1" ] ; then
    echo "File not found: $1"
    exit 1
fi

nam="${1%.*}"
ext="${1##*.}"

if [ $ext = lyx ] ; then
    # convert lyx to pdf
    lyx -batch -E pdf4 $nam-txt.pdf $nam.lyx
elif [ $ext = context ] ; then
    context --result=$nam-txt.pdf $1
elif [ $ext = fodt -o $ext = odt ] ; then
    # export original ODT source document to (text-based) PDF file
    soffice --headless --convert-to pdf $nam.fodt
    mv $nam.pdf $nam-txt.pdf
else
    echo "filetype not supported"
    exit 1
fi

# build PDF with JPEG pages
convert $cvt_opts $nam-txt.pdf $nam-jpg.pdf

# encrypt PDF files
qpdf $encrypt_opts $nam-txt.pdf
qpdf $encrypt_opts $nam-jpg.pdf

# show PDF stats
qpdf $show_opts $nam-txt.pdf
qpdf $show_opts $nam-jpg.pdf

ls -lhtr --full-time $nam*











# qpdf1="qpdf --verbose --encrypt foo bar 256 --extract=n --assemble=n --annotate=n --form=n --modify-other=n --print=none --"
# qpdf2="qpdf --verbose --password=foo --check --show-object=trailer --show-pages --with-images"
# cvjpg="convert -strip -interlace Plane -quality 33% -define jpeg:dct-method=float -sampling-factor 4:2:0"

# paper=$(grep \\papersize $1 | cut -d' ' -f 2 | xargs printf '--%s')

# # build "normal" PDF (text pages)
# $qpdf1 $nam-orig.pdf $nam-txt.pdf


# #-r 300 -scale-to 1040
# # convert text-based PDF to series of page images (PNG)
# pdftoppm -png -r 300 -forcenum $nam-orig.pdf $nam-page
# # assemble PNG images into PDF file
# pdfjam --noautoscale true $paper $nam-page-*.png -o $nam-png-raw.pdf
# # encrypt PDF file, for final output PDF(PNG)
# $qpdf1 $nam-png-raw.pdf $nam-png.pdf



# # build lossy JPEG images (from PNG images)
# for i in $nam-page-*.png ; do $cvjpg $i ${i%.*}.jpg ; done
# # assemble JPEG images into PDF file
# pdfjam --noautoscale true $paper $nam-page-*.jpg -o $nam-jpg-raw.pdf
# # encrypt PDF file, for final output PDF(JPG)
# $qpdf1 $nam-jpg-raw.pdf $nam-jpg.pdf



# #show PDF stats
# $qpdf2 $nam-txt.pdf
# $qpdf2 $nam-png.pdf
# $qpdf2 $nam-jpg.pdf



# NOTE: use i7j-rups to view internal structure of PDF files
