#!/bin/bash

#Aqui usei para descobrir os nomes e ips dos links, menos do am-pa.
#usei 200.143.{252,253,254.255}.{1..255}


for i in {1..255}; do
	ping=$(ping -c 1 -W 1 200.143.255.$i | grep 'from' | awk '{print $4}' | tr --delete ':')
	if [ -n "$ping" ] ; then
		echo "$ping"
		host 200.143.255.$i | grep name | awk '{ print $5}'

	fi
done

