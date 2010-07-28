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
if [ -z "$2" ]
then
    echo "Syntax: ./pdf.sh recto.svg verso.svg"
    exit 1
fi

recto=$1
verso=$2
files=( $recto $verso )

cmdname=$(basename $0)
temp_dir=$(mktemp -t -d ${cmdname}.XXXXXXXXXX) || exit 1

for index in $(seq 0 $((${#files[@]} - 1)))
do
    file=${files[$index]}

    # Get file name without extension
    name=$(basename $file)
    name=${name%.*}

    # Get name of PDF file for a single bookmark
    pdf_file=$temp_dir/$name.pdf

    # Get name of A4 PDF file
    a4_file=$temp_dir/$name-a4.pdf
    a4_files[$index]=$a4_file

    # Convert SVG to PDF
    inkscape --export-background=white --export-pdf=$pdf_file $file

    # Append copies of the PDF to make an A4 landscape page
    convert -background none $pdf_file $pdf_file $pdf_file $pdf_file $pdf_file +append $a4_file
done

# Rotate and merge PDFs into a single document
pdftk R=${a4_files[0]} V=${a4_files[1]} cat R1W V1E output bookmark.pdf
