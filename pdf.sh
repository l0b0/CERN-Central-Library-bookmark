#!/bin/bash
for name in recto verso
do
    # Convert SVG to PDF
    svg=${name}.svg
    pdf=${name}.pdf
    inkscape --export-pdf=$pdf $svg

    # Make 5 pages of the same
    pdf_multipage=${name}-multipage.pdf
    pdftk P=$pdf cat P P P P P output $pdf_multipage
    rm $pdf

    # Nup all pages into one
    pdf_a4=${name}-a4.pdf
    pdfnup $pdf_multipage --nup 5x1 --paper a4paper --orient landscape --outfile $pdf_a4
    rm $pdf_multipage
done

pdftk R=recto-a4.pdf V=verso-a4.pdf cat R1W V1E output bookmark.pdf

rm recto-a4.pdf verso-a4.pdf
