#!/bin/sh

pid=$$
file=$1

cat $file | \
 sed -e 's/DEFINE mklib mklib//' > /tmp/$pid
 
mv /tmp/$pid $file
