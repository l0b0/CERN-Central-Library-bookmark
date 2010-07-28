#!/bin/bash
#
# NAME
#    pdf.sh - Convert bookmark SVG files to printable PDF
#
# SYNOPSIS
#    pdf.sh recto.svg verso.svg
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2010 CERN
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

error()
{
    test -t 1 && {
        tput setf 4
        echo "$1" >&2
        tput setf 7
    } || echo "$1" >&2
    if [ -z "$2" ]
    then
        exit $EX_UNKNOWN
    else
        exit $2
    fi
}

usage()
{
    error "Usage: ${cmdname} recto.svg verso.svg" $EX_USAGE
}

PATH='/usr/bin:/bin'
cmdname=$(basename $0)

# Exit codes from /usr/include/sysexits.h, as recommended by
# http://www.faqs.org/docs/abs/HTML/exitcodes.html
EX_USAGE=64       # command line usage error

# Custom errors
EX_UNKNOWN=1

if [ -z "$2" ]
then
    usage
fi

recto=$1
verso=$2
files=( $recto $verso )

cmdname=$(basename $0)
temp_dir=$(mktemp -t -d ${cmdname}.XXXXXXXXXX) || error 'Could not create temporary directory'

for index in $(seq 0 $((${#files[@]} - 1)))
do
    file=${files[$index]}

    # Get file name without extension
    name=$(basename $file)
    name=${name%.*}

    pdf_file=$temp_dir/${name}.pdf
    inkscape --export-pdf=$pdf_file $file \
        || error 'Could not convert SVG to PDF' $?

    pdf_multipage=$temp_dir/${name}-multipage.pdf
    pdftk $pdf_file $pdf_file $pdf_file $pdf_file $pdf_file cat output $pdf_multipage \
        || error 'Could not concatenate PDFs' $?
    
    pdf_a4=$temp_dir/${name}-a4.pdf
    pdfnup $pdf_multipage --nup 5x1 --paper a4paper --orient landscape --outfile $pdf_a4 \
        || error 'Could not merge PDF files into a single A4 page' $?

    # All done for now
    pdf_a4s[$index]=$pdf_a4
done

pdftk R=${pdf_a4s[0]} V=${pdf_a4s[1]} cat R1W V1E output bookmark.pdf \
    || error 'Could not rotate and merge pages into bookmark' $?
