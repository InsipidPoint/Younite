#! /bin/bash

var="array("
while read myline
do
	var=$var$myline","
done
var=$var")"
echo $var