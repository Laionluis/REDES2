#!/bin/bash

#funcao que informa se enlace esta ON ou OFF
esta_online_ping()
{
	data=$(date)											  # Pega data e hora
	ping=$(ping -c 1 -W 1 $i)                                 # Para depois de mandar 1 pacote ECHO_REQUEST, e timeout de 1 segundo (-W 1)
	ping1=$(echo $ping | tail -2)							  # pega as duas ultimas linhas do resultado do ping
	ip_addrs=$(echo $ping | grep PING | awk '{print $3}') 	  # pega ip do enlace
	loss=$(echo $ping1 | cut -d"," -f3 | cut -d" " -f2)		  # pega a partir do resultado do ping a porcentagem de perda dos pacotes (loss)

	if [ "$loss" = "100%" ] ; then							  # se o loss for igual a 100% significa que enlace pode estar offline 
 		echo $data = $i $ip_addrs parece estar OFFLINE  >> log_enlaces.log
	else
		echo $data = $i $ip_addrs esta ONLINE  >> log_enlaces.log
	fi
}

#aqui faz traceroute para todos os pop e compara resultados com oque o padrão 
#se for diferente testa os links ou ips que não esta na nova rota mas estão no padrão
#o teste é um ping, para verificar se esta online ou não, se não tiver, grava num arquivo, com hora e data
traceroute_func()
{
	#traceroute $i | tail -n +2 | awk '{print $2" "$3}' > $i.log                    
	data=$(date)
	aux=$(traceroute $i | tail -n +2 | awk '{print $2" "$3}')                        # faz traceroute e pega somente a primeira e a segunda coluna 
																					 # que é o nome e o ip 
	aux2=$(cat <(echo "$aux") | tail -1)											 # Pega ultima linha do resultado do traceroute (aux)
	if [ "$aux2" = "* *" ] ; then 													 # Se ultima linha tiver asteriscos 
		echo $data: No caminho para $i deve ter algum firewall dropando os pacotes. >> log_enlaces.log
	fi 

	compara=$(diff -u $i.log <(echo "$aux") | tail -n +4 | grep ^-)					 # Usando o diff -u comparo o resultado do traceroute(aux)
																					 # com um arquivo que contem a rota padrao 

	if [ -n "$compara" ] ; then														 # Se variavel compara tiver alguma coisa faz testes
		while read -r line ; do 													 
			tmp0=$(echo "$line" | awk '{print $1}') 								 # pega nome do link
			tmp=$(echo "$line" | awk '{print $2}' | tr -d '()') 					 # pega ip do link
			ping=$(ping -c2 "$tmp")  												 # faz pinga com count igual a 2 para o ip do link
			ping1=$(echo $ping | tail -2)  											 
			loss=$(echo $ping1 | cut -d"," -f3 | cut -d" " -f2) 					 # pega o loss do resultado do ping
			erro=$(echo "$ping" | grep From -m1 | awk '{$1=""; $2=""; $3=""; print}') #pega erro se tiver 
			if [ "$loss" = "100%" ] ; then											 # se loss for igual a 100% significa que o link esta fora do ar
				echo $data : o link ou enlace $tmp0 não esta respondendo 	>> log_enlaces.log
			else if [ "$loss" = "+2" ] ; then
				echo $data : o link ou enlace $tmp0 não esta respondendo: $erro >> log_enlaces.log					 
			fi
			fi
		done <<< "$compara"		
	fi
}

while true; do
for i in {www.pop-{pr,ac,al,am,ap,ba,ce,df,es,go,ma,mg,ms,mt,pa,pb,pe,pi,rn,ro,rr,rs,sc,se,sp,to}.rnp.br,www.faperj.br}
do
	esta_online_ping $i
	traceroute_func $i  
	echo ------  >> log_enlaces.log
done
echo =======================  >> log_enlaces.log
sleep 10m
done
