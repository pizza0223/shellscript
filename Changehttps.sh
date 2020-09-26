#!/bin/sh
 
# 把 http:// 或 https:// 都換成 //
for htm in `find $1 -regextype posix-egrep -regex ".*\.(css|shtml|htm|html|php|template)$"`; do
  echo "cleaning $htm ..."
    sed -i '' -e 's,\(src="\)http:\(//\),\1\2,g' -e 's,\(src="\)https:\(//\),\1\2,g' $htm 
    sed -i '' -e 's,\(href="\)http:\(//\),\1\2,g' -e 's,\(href="\)https:\(//\),\1\2,g' $htm
    sed -i '' -e 's,\(url(\)http:\(//\),\1\2,g' -e 's,\(url(\)https:\(//\),\1\2,g' $htm
    sed -i '' -e 's,\(background="\)http:\(//\),\1\2,g' -e 's,\(background="\)https:\(//\),\1\2,g' $htm
done
 
# optipng
for png in `find $1 -iname "*.png"`; do
  echo "optipng $png ..."
  optipng -preserve -fix -force -o3 "$png"
done
 
# jpegtran
for jpg in `find $1 -iname "*.jpg"`; do
  echo "crushing $jpg ..."
  jpegtran -progressive -optimize -copy none "$jpg" > temp.jpg
 
  # preserve original on error
  if [ $? = 0 ]; then
    mv -f temp.jpg $jpg
  else
    rm temp.jpg
  fi
done