#!/bin/bash
echo
echo "Compare File 1 to File 2"

echo "File 1 = /home/nalle/bigfile.txt"
echo "File 2 = /home/nalle/backup/bigfile.txt.old"
echo
read -p "File 1: " file1
read -p "File 2: " file2



if cmp -s "$file1" "$file2"; then
    printf 'The file "%s" is the same as "%s"\n' "$file1" "$file2"
else
    printf 'The file "%s" is different from "%s"\n' "$file1" "$file2"
fi
