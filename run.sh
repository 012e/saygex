#!/bin/bash

# Define file names
fileName="doc.md"
templateFile="main.template.typ"
generatedFile="main.generated.typ"
typstSource="main.generated.typ"
typstOutput="main.generated.pdf"
stdoutLog="stdout.log"

template=$(cat "$templateFile")

echo "Generating Typst file from Markdown..."
content=$(pandoc -f gfm -t typst "$fileName" --extract-media="./media/")

echo "Processing content..."
content=$(echo "$content" | sed 's/\r$//' | sed 's/#horizontalrule//g')

echo "Writing to $generatedFile..."
echo -e "${template}\n${content}" > "$generatedFile"

echo "Compiling Typst file to PDF..."
typst compile "$typstSource" "$typstOutput"

echo "Updated $generatedFile."
