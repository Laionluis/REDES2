#!/bin/bash

#funcao que informa se enlace esta ON ou OFF
esta_online_ping()
{
	data=$(date)											  # Pega data e hora
	ping=$(ping -c 1 -W 1 $i)                                 # Para depois de mandar 1 pacote ECHO_REQUEST, e timeout de 1 segundo (-W 1)
	ping1=$(echo $ping | tail -2)							  # pega as duas ultimas linhas do resultado do ping
	ip_addrs=$(echo $ping | grep PING | awk '{print $3}') 	  # pega ip do enlace
	loss=$(echo $ping1 | cut -d"," -f3 | cut -d" " -f2)		  # pega a partir do resultado do ping a porcentagem de perda dos pacotes (loss)
	erro=$(echo "$ping" | grep From -m1 | awk '{$1=""; $2=""; $3=""; print}') #pega erro se tiver 

	if [ "$loss" = "100%" ] ; then							  # se o loss for igual a 100% significa que enlace pode estar offline 
 		echo $data = $i $ip_addrs parece estar OFFLINE  >> log_enlaces_2.log
	else if [ "$loss" = "+2" ] ; then
		echo $data : $i $ip_addrs parece estar OFFLINE: $erro >> log_enlaces_2.log	
    else
		echo $data = $i $ip_addrs esta ONLINE  >> log_enlaces_2.log
	fi
	fi
}

#Percebi usando traceroute que a maioria dos links tem ip 200.143.252.* ou 200.143.253.*
#entao fiz essa função que testa usando ping se link esta ou nao online
verifica_enlaces_func()
{
	for i in {1,2,21,22,25,26,29,30,33,34,37,38,53,54,57,58,61,62,65,66,73,74,77,78,81,82,85,86,89,90,93,94,97,98,101,102,105,106,109,110,113,114,117,118,121,122,125,126,129,130,133,134,137,138,141,142,145,146,149,150,153,154,157,158,161,162,165,166,169,170,185,217,218}; do
		
		data=$(date)											  # Pega data e hora
		ping=$(ping -c 1 -W 1 200.143.252.$i)                     # Para depois de mandar 1 pacote ECHO_REQUEST, e timeout de 1 segundo (-W 1)
		nome=$(host 200.143.252.$i | grep name | awk '{ print $5}') #pega o nome do link
		ping1=$(echo $ping | tail -2)							  # pega as duas ultimas linhas do resultado do ping
		loss=$(echo $ping1 | cut -d"," -f3 | cut -d" " -f2)		  # pega a partir do resultado do ping a porcentagem de perda dos pacotes (loss)
		erro=$(echo "$ping" | grep From -m1 | awk '{$1=""; $2=""; $3=""; print}') #pega erro se tiver 
		
		if [ -n "$nome" ] ; then
			if [ "$loss" = "100%" ] ; then											 # se loss for igual a 100% significa que o link esta fora do ar
				echo $data : o link $nome não esta respondendo 	>> log_enlaces_2.log
			else if [ "$loss" = "+2" ] ; then
				echo $data : o link $nome não esta respondendo: $erro >> log_enlaces_2.log					 
			fi
			fi
		fi
	done

	for i in {21,22,25,26,29,30,33,34,37,38,49,65,66,77,78,81,82,105,106,113,114,121,122,125,126,149,150,173,174,189,190,213,214,217,218,221,222,225,226}; do
		
		data=$(date)											  # Pega data e hora
		ping=$(ping -c 1 -W 1 200.143.253.$i)                     # Para depois de mandar 1 pacote ECHO_REQUEST, e timeout de 1 segundo (-W 1)
		nome=$(host 200.143.253.$i | grep name | awk '{ print $5}') #pega o nome do link
		ping1=$(echo $ping | tail -2)							  # pega as duas ultimas linhas do resultado do ping
		loss=$(echo $ping1 | cut -d"," -f3 | cut -d" " -f2)		  # pega a partir do resultado do ping a porcentagem de perda dos pacotes (loss)
		erro=$(echo "$ping" | grep From -m1 | awk '{$1=""; $2=""; $3=""; print}') #pega erro se tiver 
		
		if [ -n "$nome" ] ; then
			if [ "$loss" = "100%" ] ; then											 # se loss for igual a 100% significa que o link esta fora do ar
				echo $data : o link $nome não esta respondendo 	>> log_enlaces_2.log
			else if [ "$loss" = "+2" ] ; then
				echo $data : o link $nome não esta respondendo: $erro >> log_enlaces_2.log					 
			fi
			fi
		fi
	done
}

while true; do
	for i in {www.pop-{pr,ac,al,am,ap,ba,ce,df,es,go,ma,mg,ms,mt,pa,pb,pe,pi,rn,ro,rr,rs,sc,se,sp,to}.rnp.br,www.faperj.br}
	do
		esta_online_ping $i
	done
	verifica_enlaces_func 
	echo =======================  >> log_enlaces_2.log
	sleep 10m
done