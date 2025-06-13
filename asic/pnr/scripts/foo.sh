#!/bin/sh

pid=$$
file=$1

cat $file | \
 sed -e 's/\.VSSPST(UNCONNECTED[0-9]*)/.VSSPST(VSSPST)/' | \
 sed -e 's/\.VDDPST(UNCONNECTED[0-9]*)/.VDDPST(VDDPST)/' > /tmp/$pid

mv /tmp/$pid $file
