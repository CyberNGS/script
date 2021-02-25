#!/bin/bash
function ip_estatico(){
#!/bin/bash
cd /etc/netplan
echo "Quantas placas de rede tem a máquina local"
read placas 
if [ $placas == "1" ]
then
echo "Qual o nome da placa"
read placa
echo "Qual o IP que pretende atribuir a este servidor"
read ip
echo "Qual a máscara de rede "
echo "Exemplo: 255.255.255.0 = /24"
echo "Somente o bit count : 24"
read mask
echo "Qual o IP de gateway da rede"
read gateway
echo "Quantos DNS servers existem na rede"
read numero_dns
sed -i '3,$d' 00-installer-config.yaml
if [ $numero_dns == "1" ]
then
echo "Qual o IP do servidor de DNS da rede"
read ip_dns
total="$ip_dns"
echo "  ethernets:
    $placa:
      dhcp4: false
      addresses: [$ip/$mask]
      gateway4: $gateway
      nameservers:
       addresses: [$total]
  version: 2
" >> 00-installer-config.yaml
netplan apply
elif [ $numero_dns -gt "1" ]
then
echo "Qual o IP do servidor de DNS"
read total
for((k=0;k<$numero_dns-1;k++))
do
echo "Qual o IP do servidor de DNS"
read ip_dns
total="$total,$ip_dns"
done
echo "  ethernets:
    $placa:
      dhcp4: false
      addresses: [$ip/$mask]
      gateway4: $gateway
      nameservers:
       addresses: [$total]
  version: 2
" >> 00-installer-config.yaml
netplan apply
fi
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa NAT"
read placa_nat
echo "Qual o nome da placa internal"
read placa_internal
sed -i '3,$d' 00-installer-config.yaml
echo "Qual o IP que pretende atribuir a este servidor"
read ip
echo "Qual a máscara de rede"
echo "Exemplo: 255.255.255.0 = /24"
echo "Somente o bit count 24"
read mask
echo "Qual o IP de gateway da rede"
read gateway
echo "Quantos DNS servers existem na rede"
read numero_dns
if [ $numero_dns == "1" ]
then
echo "Qual o IP do servidor de DNS da rede"
read ip_dns
total="$ip_dns"
echo "  ethernets:
    $placa_nat:
      dhcp4: true
    $placa_internal:
      addresses: [$ip/$mask]
      gateway4: $gateway
      nameservers:
       addresses: [$total]
  version: 2
" >> 00-installer-config.yaml
netplan apply
elif [ $numero_dns -gt "1" ]
then
echo "Qual o IP do servidor de DNS"
read total
for((k=0;k<$numero_dns-1;k++))
do
echo "Qual o IP do servidor de DNS"
read ip_dns
total="$total,$ip_dns"
done
echo "  ethernets:
    $placa_nat:
      dhcp4: true
    $placa_internal:
      addresses: [$ip/$mask]
      gateway4: $gateway
      nameservers:
       addresses: [$total]
  version: 2
" >> 00-installer-config.yaml
netplan apply
fi
fi
exec bash
}
function ssh(){
#!/bin/bash
echo "*****************************************************************************"
echo "*****************************************************************************"
echo "*************************************SSH*************************************"
echo "*****************************************************************************"
echo "*****************************************************************************"
cd /
echo "Quantas placas tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa de rede NAT"
read placa_nat
echo "Qual o nome da placa de rede internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y ssh
ip link set $placa_nat down
ip link set $placa_internal up
echo "Vamos testar o serviço ssh"
echo "Exemplo ssh nome_do_utilizador@ip_da_máquina onde pretende aceder"
exec bash
}
function dominio(){
#!/bin/bash
echo "*****************************************************************"
echo "*****************************************************************"
echo "***************************AD DOMAIN*****************************"
echo "*****************************************************************"
echo "*****************************************************************"
cd /
echo "Qual o domínio do Windows Server"
read dominio
echo "Introduza a password do Administrator do Windows Server"
read -s password
echo "Para fazer domain join é necessário instalar o SSH"
echo "Quantas placas de rede existem na máquina local?"
read placas
if [ $placas == "1" ]
then
echo "Introduza o nome da placa"
read nome_placa1
ip link set $nome_placa1 up
fi
if [ $placas == "2" ]
then
echo "Introduza o nome da placa internal"
read placa_internal
echo "Introduza o nome da placa NAT"
read placa_nat
ip link set $placa_nat up
ip link set $placa_internal down
sleep 5
fi
apt-get install -y ssh
echo "Iremos instalar o Pbis"
echo "Tem algum certificado instalado"
echo "Sim ou Não"
read resposta
if [ $resposta == "Sim" ] || [ $resposta == "sim" ] || [ $resposta == "S" ] || [ $resposta == "s" ]
then
wget https://github.com/BeyondTrust/pbis-open/releases/download/9.1.0/pbis-open-9.1.0.551.linux.x86_64.deb.sh --no-check-certificate
else
wget https://github.com/BeyondTrust/pbis-open/releases/download/9.1.0/pbis-open-9.1.0.551.linux.x86_64.deb.sh
fi
ip link set $placa_nat down
ip link set $placa_internal up
sleep 5
chmod +x pbis-open-9.1.0.551.linux.x86_64.deb.sh
./pbis-open-9.1.0.551.linux.x86_64.deb.sh
cd /opt/pbis/bin
domainjoin-cli join $dominio Administrator $password
cd /
/opt/pbis/bin/config UserDomainPrefix $dominio
/opt/pbis/bin/config AssumeDefaultDomain True
/opt/pbis/bin/config LoginShellTemplate /bin/bash
/opt/pbis/bin/config HomeDirTemplate %H/%D/%U
cd /opt/pbis/bin
domainjoin-cli join $dominio Administrator $password
cd /
echo "Vamos verificar se a máquina está no domínio do Windows Server"
domainjoin-cli query
rm -r pbis-open-9.1.0.551.linux.x86_64.deb.sh
exec bash
}
function dhcp(){
#!/bin/bash
echo "****************************************************************"
echo "****************************************************************"
echo "******************************DHCP******************************"
echo "****************************************************************"
echo "****************************************************************"
cd /
ip link set enp0s8 down
ip link set enp0s3 up
sleep 5
apt-get install -y isc-dhcp-server
ip link set enp0s3 down
ip link set enp0s8 up
sleep 5
echo "Qual o nome da internal network"
read placa_internal
cd /etc/default
sed -i 's/v4=".*/v4="'$placa_internal'"/g' isc-dhcp-server
cd /etc/dhcp
echo "Insira o dominio"
read dominio
sed -i 's/option domain-name ".*/option domain-name "'$dominio'";/g' dhcpd.conf
echo "Quantos servidores de DNS existem na rede"
read numip
if [ $numip == 1 ]
then
echo "Introduza o IP"
read ip
sed -i "s/option domain-name-servers .*/option domain-name-servers $ip;/g" dhcpd.conf
else
echo "Introduza o IP"
read iptotal
for((i=0;i<$numip-1;i++))
do
echo "Introduza o IP"
read ip
iptotal="$iptotal, $ip"
done
sed -i "s/option domain-name-servers .*/option domain-name-servers $iptotal;/g" dhcpd.conf
fi
echo "Insira o IP de rede"
echo "Exemplo: 172.20.27.0"
read ip_rede
echo "Insira a máscara de rede"
echo "Exemplo: 255.255.255.0 e não /24"
read netmask
echo "Insira a range de IP's"
echo "Introduza o primeiro IP"
read primeiro_ip
echo "Introduza o último IP"
read ultimo_ip
echo "Introduza o IP de gateway"
read gateway
sed -i "/subnet /,+20d" dhcpd.conf
echo "subnet $ip_rede netmask $netmask {
	range $primeiro_ip $ultimo_ip;
	option routers $gateway;
} " >> dhcpd.conf
service  isc-dhcp-server restart
service isc-dhcp-server status
cd /
exec bash
}
function dns(){
#!/bin/bash
echo "***********************************************************"
echo "***********************************************************"
echo "***************************DNS*****************************"
echo "***********************************************************"
echo "***********************************************************"
ip link set enp0s8 down
ip link set enp0s3 up
sleep 5
apt-get install -y bind9 bind9utils
ip link set enp0s3 down
ip link set enp0s8 up
sleep 5
cd /etc/bind
echo "Introduza o domínio"
read dominio
echo "Qual o IP do servidor de DNS?"
echo "Introduza o primeiro octeto"
echo "Exemplo: 192.x.x.x"
read ip1
echo "Introduza o segundo octeto"
echo "Exemplo: x.168.x.x"
read ip2
echo "Introduza o terceiro octeto"
echo "Exemplo: x.x.1.x"
read ip3
echo "Introduza o quarto octeto"
echo "Exemplo: x.x.x.1"
read ip4
sed -i '/zone /,+50d' named.conf.local
echo 'zone "'${dominio}'" IN { ' >> named.conf.local
echo "	type master;" >> named.conf.local
echo '	file "/etc/bind/forward.'$dominio'";' >> named.conf.local
echo "};" >> named.conf.local
echo -e "\n" >> named.conf.local
echo 'zone "'$ip3'.'$ip2'.'$ip1'.in-addr.arpa" IN {' >> named.conf.local
echo "	type master;" >> named.conf.local
echo '	file "/etc/bind/reverse.'$dominio'";' >> named.conf.local
echo "};" >> named.conf.local
rm -r forward.*
rm -r reverse.* 
cp db.empty forward.${dominio}
cp db.empty reverse.${dominio}
sed -i "s/SOA	.*/SOA	server.$dominio. root.$dominio. (/g" forward.$dominio
sed -i "s/NS	.*/NS	server./g" forward.$dominio
echo "@	IN	A	$ip1.$ip2.$ip3.$ip4" >> forward.$dominio
sed -i "s/SOA	.*/SOA	server.$dominio. root.$dominio. (/g" reverse.$dominio
sed -i "s/NS	.*/NS	server./" reverse.$dominio
echo "@	IN	PTR	$ip1.$ip2.$ip3.$ip4" >> reverse.$dominio
echo "$ip4	IN	PTR	server." >> reverse.$dominio
echo "Quantos forwarders pretende?"
read forwarders
linhas=$forwarders
while [ $forwarders -gt 0 ]
do
echo "Qual o IP de forwarder?"
read dns_ip
total_ip="$total_ip\t$dns_ip;\n"
((forwarders--))
done
sed -i "/forwarders {/,+"$((linhas+1))"c\	forwarders {\n"$total_ip"\n};" named.conf.options 
cd /
systemctl restart bind9
systemctl status bind9
cd /
nslookup $dominio
ping $dominio
exec bash
}
function asterisk(){
#!/bin/bash
echo "*********************************************************"
echo "*********************************************************"
echo "***********************ASTERISK**************************"
echo "*********************************************************"
echo "*********************************************************"
echo "Quantas placas de rede tem ligadas?"
read placas
if [ $placas == 1 ]
then
echo "Qual o nome da placa"
read placa_1
ip link set $placa_1 up
sleep 2
elif [ $placas == 2 ]
then
echo "Qual o nome da placa NAT"
read placa_nat
echo "Qual o nome da placa internal"
read placa_internal
ip link set $placa_nat up
ip link set $placa_internal down
fi
apt-get install -y asterisk
if [ $placas == 1 ]
then
ip link set $placa_1 up
elif [ $placas == 2 ]
then
ip link set $placa_nat down
ip link set $placa_internal up
fi
cd /etc/asterisk
sed -i "/flow to the remote device./,+50d" sip.conf
echo "                                ; then UDPTL will flow to the remote device." >> sip.conf
sed -i "/cid_number = 6000/,+50d" users.conf
echo ";cid_number = 6000" >> users.conf
sed -i "/from-internal/,+50d" extensions.conf
echo "Quantos utilizadores quer que tenham acesso a extensão telefónica"
read extensoes
echo "[from-internal]" >> extensions.conf
regcontext=100
echo "Qual o nome que pretende dar à chamada geral?"
read geral
for((c=0;c<$extensoes;c++))
do
echo "Introduza o nome do utilizador"
read user
echo "Introduza a sua password"
read -s password
echo "Pretende que seja associado voicemail?"
echo "S(SIM) ou N(NÃO)"
read opcao
((regcontext++))
echo "
[$user]
type=friend
port=5060
username=$user
nat=yes
qualify=yes
regcontext=$regcontext
context=from-internal" >> sip.conf
echo "
[$user]
full name = $user
secret = $password
hassip = yes
context = from-internal
host = dynamic" >> users.conf
echo "
exten=>$user,1,Dial(SIP/$user,10)" >> extensions.conf
if [ $opcao == "S" ] || [ $opcao == "s" ] || [ $opcao == "SIM" ] || [ $opcao == "sim" ]
then
echo "exten=>$user,2,Playback(vm-nobodyavail)" >> extensions.conf
else
echo "O utilizador não pretende voicemail"
fi
if [ $c == "0" ]
then
total="SIP/$user"
else
total="$total&SIP/$user"
fi
done
if [ $extensoes -gt 1 ]
then
echo "exten=>$geral,1,Dial($total,10)" >> extensions.conf
fi
systemctl restart asterisk
systemctl status asterisk
exec bash
}
function postfix(){
#!/bin/bash
echo "********************************************************************************"
echo "********************************************************************************"
echo "***********************************POSTFIX**************************************"
echo "********************************************************************************"
echo "********************************************************************************"
echo " 1 - Estamos a configurar servidor de email POSTFIX usando modo interactivo"
echo " 2 - Estamos a configurar servidor de email POSTFIX não usando modo interactivo"
echo " 3 - Estamos a configurar um cliente"
read opcao
case $opcao in 
"1")
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa internal"
read placa_internal
echo "Qual o nome da placa NAT"
read placa_nat
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y postfix courier-imap mailutils
ip link set $placa_nat down
ip link set $placa_internal up
dpkg-reconfigure postfix
echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf
maildirmake /etc/skel/Maildir
echo "Pretende criar utilizadores locais"
read resposta
if [ $resposta == "sim" ] || [ $resposta == "SIM" ] || [ $resposta == "S" ] || [ $resposta == "s" ]
then
echo "Quantos utilizadores pretende criar?"
read numero
for((c=0;c<$numero;c++))
do
echo "Introduza o nome do utilizador que pretende criar"
read nome_user
adduser $nome_user
done
fi
/etc/init.d/courier-imap restart
/etc/init.d/courier-authdaemon restart
/etc/init.d/postfix restart
service postfix status
;;
"2")
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa NAT"
read placa_nat
echo "Qual o nome da placa Internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
cd /
DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
DEBIAN_FRONTEND=noninteractive apt-get install -y courier-imap
DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils
ip link set $placa_nat down
ip link set $placa_internal up
sleep 3
cd /etc/postfix
sed -i "/myhostname =.*/,+50d" main.cf
echo "Qual o domínio"
read dominio
echo "Qual o hostname da máquina local"
read hostname
cd /
echo "myhostname = $hostname.$dominio" >> /etc/postfix/main.cf
echo "alias_maps = hash:/etc/alias" >> /etc/postfix/main.cf
echo "alias_database = hash:/etc/aliases" >> /etc/postfix/main.cf
echo "mydestination = $dominio" >> /etc/postfix/main.cf
echo "relay host = " >> /etc/postfix/main.cf
echo "Quantas redes deseja que tenham acesso ao serviço de email"
read numero_redes
for((c=0;c<$numero_redes;c++))
do
echo "Insira o IP da rede que pretende adicionar"
echo "Só o IP sem a máscara de rede"
echo "Exemplo: 192.168.1.0"
read ip_rede
echo "Introduza a máscara de rede"
echo "Exemplo: 255.255.255.0 = 24"
read netmask
network="$ip_rede/$netmask"
networks="$networks $network"
done
echo "mynetworks = $networks" >> /etc/postfix/main.cf
echo "mailbox_size_limit = 0" >> /etc/postfix/main.cf
echo "recipient_limit = +" >> /etc/postfix/main.cf
echo "inet_interfaces = all" >> /etc/postfix/main.cf
echo "Está a trabalhar com ipv4 ou ipv6"
echo "Exemplo: ipv4 ou ipv6"
read resposta
if [ $resposta == "ipv4" ]
then
echo "inet_protocols = $resposta" >> /etc/postfix/main.cf
else
echo "inet_protocols = $resposta" >> /etc/postfix/main.cf
fi
echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf
maildirmake /etc/skel/Maildir
echo "Deseja criar utilizadores locais?"
echo "1.Sim"
echo "2.Não"
read alternativa
if [ $alternativa == "1" ]
then
echo "Quantos utilizadores deseja criar"
read n_users
for((i=0;i<$n_users;i++))
do
echo "Introduza o nome do utilizador que deseja criar"
read nome
adduser $nome
done
else
echo "Optou por não criar utilizadores locais"
fi
/etc/init.d/courier-imap restart
/etc/init.d/courier-authdaemon restart
/etc/init.d/postfix restart
/etc/init.d/postfix status
;;
"3")
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa internal"
read placa_internal
echo "Qual o nome da placa NAT"
read placa_nat
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y thunderbird
ip link set $placa_nat down
ip link set $placa_internal up
esac
exec bash
}
function rsyslog(){
#!/bin/bash
echo "***********************************************************************"
echo "***********************************************************************"
echo "********************************RSYSLOG********************************"
echo "***********************************************************************"
echo "***********************************************************************"
echo " 1 - Estamos a configurar um servidor Rsyslog"
echo " 2 - Estamos a configurar um cliente Rsyslog"
echo " Introduza a opção que pretende"
cd /
read opcao
case $opcao in 
"1")
echo "Quantas placas tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa NAT"
read placa_nat
echo "Qual o nome da placa internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y rsyslog
ip link set $placa_nat down
ip link set $placa_internal up
cd /etc/
sed -i "17s/#//" rsyslog.conf
sed -i "18s/#//" rsyslog.conf
sed -i "21s/#//" rsyslog.conf
sed -i "22s/#//" rsyslog.conf
echo "Quantas redes existem?"
read numero_redes
for((c=0;c<$numero_redes;c++))
do
echo "Qual o IP da rede"
read ip
echo "Qual a máscara de rede"
echo "Exemplo: 255.255.255.0 = /24"
read mask
ip_total="$ip/$mask"
ip_redes="$ip_redes, $ip_total"
done
sed -i '/$AllowedSender TCP,.*/,+20d' rsyslog.conf
echo "$""AllowedSender TCP, 127.0.0.1$ip_redes" >> rsyslog.conf
echo "$""template remote-incoming-logs, "'"/var/log/%HOSTNAME%/%PROGRAMNAME%.log"' >> rsyslog.conf
echo "*.* ?remote-incoming-logs" >> rsyslog.conf
echo "& ~" >> rsyslog.conf
ss -tunelp | grep 514
ufw allow 514/tcp
ufw allow 514/udp
service rsyslog restart
service rsyslog status
cd /var/log
ls
exec bash
;;
"2")
cd /
echo "Quantas placas de rede existem na máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa NAT"
read placa_nat
echo "Qual o nome da placa internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y rsyslog
ip link set $placa_nat down
ip link set $placa_internal up
echo "Qual o IP do Servidor Rsyslog"
echo "Sem a máscara de rede"
read ip
cd /etc/
sed -i '/PreserveFQDN,.*/,+20d' rsyslog.conf
echo "$""PreserveFQDN on" >> rsyslog.conf
echo "*.* @$ip:514" >> rsyslog.conf
echo "$""ActionQueueFileName queue" >> rsyslog.conf
echo "$""ActionQueueMaxSpace 1g" >> rsyslog.conf
echo "$""ActionQueueSaveOnShutdown on" >> rsyslog.conf
echo "$""ActionQueueType LinkedList" >> rsyslog.conf
echo "$""ActionResumeRetryCount -1" >> rsyslog.conf
systemctl restart rsyslog
systemctl status rsyslog
cd /var/log
ls
;;
esac
exec bash
}
function openfire(){
#!/bin/bash
echo "*****************************************************************"
echo "*****************************************************************"
echo "**************************OPENFIRE*******************************"
echo "*****************************************************************"
echo "*****************************************************************"
cd /
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa de rede NAT"
read placa_nat
echo "Qual o nome da placa de rede Internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
sleep 3
echo "A máquina local já tem java instalado?"
echo "Sim ou Não"
read resposta
if [ $resposta == "SIM" ] || [ $resposta == "S" ] || [ $resposta == "s" ] || [ $resposta == "sim" ]
then
java -version
else
apt-get install -y default-jre
fi
echo "A máquina local já tem o mysql instalado?"
read resposta
if [ $resposta == "SIM" ] || [ $resposta == "S" ] || [ $resposta == "s" ] || [ $resposta == "sim" ]
then
echo "O package já se encontra instalado na máquina local"
else
echo "Vamos instalar o mysql-server"
apt-get install -y mysql-server
fi
echo "Qual o utilizador que pretende criar no servidor mysql"
read mysql_user
echo "Qual a passowrd que pretende associar a esse utilizador"
read -s mysql_passwd
echo "Qual o nome da base de dados que pretende criar no mysql"
read mysql_database
echo "create database $mysql_database;\nCREATE USER '$mysql_user'@'localhost'IDENTIFIED BY '$mysql_passwd';\nGRANT ALL PRIVILEGES ON $mysql_database.* TO '$mysql_user'@'localhost';\nflush privileges;" | mysql -u root
rm -r openfire.*
wget -O openfire.deb https://igniterealtime.org/downloadServlet?filename=openfire/openfire_4.5.3_all.deb
dpkg -i openfire.deb
ip link set $placa_nat down
ip link set $placa_internal up
systemctl restart openfire
echo "use $mysql_database;\nsource /usr/share/openfire/resources/database/openfire_mysql.sql;" | mysql -u root
echo "A porta por default do serviço openfire é 9090"
echo "Pretende mudar a porta do serviço?"
echo "1 - SIM"
echo "2 - Não"
read resposta
case $resposta in 
"1")
echo "Vai alterar a porta do serviço openfire"
echo "Qual a porta que pretende que corra o serviço openfire"
read nova_porta
cd /etc/openfire
sed -i "s#<port>.*#<port>$nova_porta</port>#g" openfire.xml
sed -i "s#<securePort>.*#<securePort>$((nova_porta+1))</securePort>#g" openfire.xml
for i in $nova_porta $((nova_porta+1)) 5222 7777 ; do sudo ufw allow $i ; done
;;
"2")
cd /etc/openfire
default_port=9090
default_sec_port=9091
sed -i "s#<port>.*#<port>$default_port</port>#g" openfire.xml
sed -i "s#<securePort>.*#<securePort>$default_sec_port</securePort>#g" openfire.xml
for i in $default_port $default_sec_port 5222 7777 ; do sudo ufw allow $i ; done
;;
esac
service openfire restart
service openfire status
exec bash
}
function samba(){
#!/bin/bash
echo -e "\e[96m *******************************************************"
echo -e "\e[96m *******************************************************"
echo -e "\e[96m *******************************************************"
echo -e "\e[96m *************************SAMBA*************************"
echo -e "\e[96m *******************************************************"
echo -e "\e[96m *******************************************************"
echo -e "\e[96m *******************************************************"
echo "Introduza o nome do utilizador que pretende criar"
read user
adduser $user
echo "Quantas placas de rede existem na máquina local?"
read numero_placas
if [ $numero_placas == 1 ]
then
echo "Qual é o nome da placa"
read nome_placa
ip link set $nome_placa up
fi
if [ $numero_placas == 2 ]
then
echo "Qual o nome da placa internal"
read placa_internal
echo "Qual o nome da placa nat"
read placa_nat
ip link set $placa_internal down
ip link set $placa_nat up
fi
apt-get install -y samba
cd /home/$user
echo "Quantas pastas pretende criar?"
read num_pastas
for((c=0;c<$num_pastas;c++))
do
echo "Introduza o nome da pasta"
read pasta
mkdir $pasta
echo "Quais as permissões que pretende dar à pasta?"
echo "1 - Leitura"
echo "2 - Escrita"
read option
case $option in 
"1")
chmod a=rx $pasta
;;
"2")
chmod a=rxw $pasta
;;
esac
echo "
[$pasta]
comment = Samba
path = /home/$user/$pasta" >> /etc/samba/smb.conf
if [ $option == "1" ]
then
echo "guest ok = yes" >> /etc/samba/smb.conf
else
echo "writeable = yes" >> /etc/samba/smb.conf
fi
echo "Existem utilizadores que não podem ter acesso à pasta?"
echo "S-SIM ou N-NÃO"
read resposta
if [ $resposta == "SIM" ] || [ $resposta == "s" ] || [ $resposta == "sim" ] || [ $resposta == "SIM" ]
then
echo "Quantos utilizadores não podem ter acesso"
read numero_users
if [ $numero_users == "1" ]
then
echo "Qual o nome do utilizador que não pode ter acesso à pasta?"
read nome_user
echo "invalid users = $nome_user" >> /etc/samba/smb.conf
else
echo "Insira o nome do utilizador"
read nome_user
total=$nome_user
for((i=0;i<$numero_users-1;i++))
do
echo "Introduza o nome do utilizador"
read nome_user
total="$total, $nome_user"
done
echo "invalid users = $total" >> /etc/samba/smb.conf
fi
else
echo "Não introduziu nenhum utilizador"
fi
done
echo "Quantos utilizadores pretende que tenham acesso às pastas"
read users
for((i=0;i<$users;i++))
do
echo "Introduza o nome do utilizador"
read user
smbpasswd -a $user
done
echo "Quantos utilizadores não irão ver as pastas?"
read invalidos
for((i=0;i<$invalidos;i++))
do
echo "Introduza o nome do utilizador"
read user
smbpasswd -d $user
done
systemctl restart smbd
systemctl restart nmbd
systemctl status smbd
systemctl status nmbd
exec bash
}
function ftp(){
#!/bin/bash
echo "***********************************************************"
echo "***********************************************************"
echo "*************************FTP*******************************"
echo "***********************************************************"
echo "***********************************************************"
echo " 1 - Estamos a configurar um servidor FTP"
echo " 2 - Estamos a configurar um cliente FTP"
echo " Introduza a opção que pretende"
read opcao
case $opcao in
"1")
cd /
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa internal"
read placa_internal
echo "Qual o nome da placa NAT"
read placa_nat
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y vsftpd
ip link set $placa_nat down
ip link set $placa_internal up
cd /etc/
sed -i "31s/#//" vsftpd.conf
sed -i "99s/#//" vsftpd.conf
sed -i "100s/#//" vsftpd.conf
sed -i "122s/#//" vsftpd.conf
sed -i "123s/#//" vsftpd.conf
sed -i "125s/#//" vsftpd.conf
sed -i "131s/#//" vsftpd.conf
sed -i "/local_root=public_html/,+10d" vsftpd.conf
echo "local_root=public_html
seccomp_sandbox=NO" >> vsftpd.conf
echo "Quantos utilizadores quer que tenham acesso ao serviço FTP"
read numero
while [ $numero -gt 0 ]
do
echo "Qual o nome do utilizador"
read nome
FILE=/etc/vsftpd.chroot_list
aux=1
while [ $aux -eq 1 ]
do
if grep -q $nome "$FILE"
then
echo "Já existe um utilizador com esse nome"
aux=1
break
else
echo "$nome" >> vsftpd.chroot_list
((numero--))
aux=0
fi
done
done
systemctl restart vsftpd
systemctl status vsftpd
;;
"2")
cd /
echo "Quantas placas tem a máquina local?"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa nat"
read placa_nat
echo "Qual o nome da placa internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get -y install filezilla
ip link set $placa_nat down
ip link set $placa_internal up
filezilla
;;
esac
exec bash
}
function nfs(){
#!/bin/bash
echo "*********************************************************************"
echo "*********************************************************************"
echo "*********************************NFS*********************************"
echo "*********************************************************************"
echo "*********************************************************************"
echo " 1 - Estamos a configurar o servidor NFS"
echo " 2 - Estamos a configurar o cliente NFS"
echo "Introduza a opção que pretende"
read opcao
case $opcao in 
"1")
echo "Quantas placas de rede tem a máquina local?"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa NAT"
read placa_nat
echo "Qual o nome da placa Internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y nfs-kernel-server
ip link set $placa_nat down
ip link set $placa_internal up
echo "Qual o utilizador que está logado neste momento na máquina local"
read user
cd /home/$user
sed -i '11,$d' /etc/exports
echo "Quantas pastas pretende partilhar?"
read num_pastas
for((i=0;i<$num_pastas;i++))
do
echo "Qual o nome da pasta"
read nome_pasta
mkdir -m 777 $nome_pasta
echo "Quantas redes existem?"
read num_redes
for((c=0;c<$num_redes;c++))
do
echo "Qual o ip de rede"
echo "Exemplo: 192.168.1.0"
echo "Sem a máscara de rede"
read redes
echo "Indique a máscara de rede"
echo "Exemplo: 255.255.255.0 = /24"
read mask
echo "Quais as permissões da pasta"
echo "Exemplo: ro (read only) ou rw (read and write)"
read permissoes
echo "Pretende incluir na partilha as subpastas?"
read resposta
if [ $resposta == "SIM" ] || [ $resposta == "sim" ] || [ $resposta == "S" ] || [ $resposta == "s" ]
then
echo "/home/$user/$nome_pasta		$redes/$mask($permissoes,subtree_check,sync)" >> /etc/exports
else
echo "/home/$user/$nome_pasta		$redes/$mask($permissoes,no_subtree_check,sync) " >> /etc/exports
fi
cd /home/$user/$nome_pasta
echo "Pretende criar ficheiros para serem vistos pelos clientes da rede?"
read resposta
if [ $resposta == "SIM" ] || [ $resposta == "sim" ] || [ $resposta == "S" ] || [ $resposta == "s" ]
then
echo "Quantos ficheiros"
read numero
for((k=0;k<$numero;k++))
do
echo "Qual o nome do ficheiro?"
read nome_ficheiro
touch $nome_ficheiro$k.txt
done
else
echo "Vamos partilhar somente a pasta"
fi
cd /home/$user
done
done
exportfs -av
exportfs
/etc/init.d/nfs-kernel-server restart
;;
"2")
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa internal"
read placa_internal
echo "Qual o nome da placa NAT"
read placa_nat
fi
ip link set $placa_nat up
ip link set $placa_internal down
sleep 3
apt-get install -y nfs-common
ip link set $placa_nat down
ip link set $placa_internal up
echo "Qual o IP do servidor NFS ou entrada de DNS"
echo "Exemplo: IP  ou  nfs.dominio"
read nome
showmount -e $nome
mount -t nfs $nome:/ /mnt
mount
cd /mnt
esac
exec bash
}
function apache(){
#!/bin/bash
echo "***************************************************"
echo "***************************************************"
echo "***********************APACHE**********************"
echo "***************************************************"
echo "***************************************************"
cd /
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa de rede NAT"
read placa_nat
echo "Qual o nome da placa de rede Internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y apache2
cd /var/www/html
echo "Introduza o link da imagem que pretende fazer o download"
read link
wget $link
echo "Qual a extensão da imagem?"
echo "Exemplo: jpg ; jpeg ; png"
read extensao
echo "Qual o nome que pretende dar à imagem"
read nome_imagem
mv *.$extensao $nome_imagem.$extensao
ip link set $placa_nat down
ip link set $placa_internal up
sed -i '1,$d' index.html
echo "Qual o título que pretende dar ao separador da página HTML"
read titulo_separador
echo "Qual o título que pretende dar à página HTML"
read titulo_pagina
echo "
<html>
     <head>
          <title>$titulo_separador</title>
	  <style type>"text/css" media="screen">
          </style>
     </head>
     <body>
          <div class="main page">
            <div class="page_header floating element">
            <img src="$nome_imagem.$extensao">
            <span class="floating_element">
                    $titulo_pagina
            </span>
            </div>
            </div>
     </body>
</html>
" >> index.html
cd /etc/apache2
echo "Pretende alterar a porta onde corre o serviço Apache2?"
echo "O serviço Apache2 corre por defeito na porta 80"
echo "1 - SIM"
echo "2 - Não"
porta_default=80
read resposta
if [ $resposta == 1 ]
then
echo "Qual a porta que pretende utilizador para o serviço Apache2"
read nova_porta
sed -i "5s/Listen.*/Listen $nova_porta/" ports.conf
else
echo "Optou por não alterar a porta do serviço Apache2"
sed -i "5s/Listen.*/Listen $porta_default/" ports.conf
fi
service apache2 restart
service apache2 status
exec bash
}
function cockpit(){
#!/bin/bash
echo "**********************************************************************************"
echo "**********************************************************************************"
echo "************************************COCKPIT***************************************"
echo "**********************************************************************************"
echo "**********************************************************************************"
cd /
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa de rede NAT"
read placa_nat
echo "Qual o nome da placa de rede internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y cockpit
ip link set $placa_nat down
ip link set $placa_internal up
echo "O serviço cockpit corre na porta por default 9090"
echo "Pretende mudar a porta do serviço"
read resposta
default_port=9090
if [ $resposta == "Sim" ] || [ $resposta == "sim" ] || [ $resposta == "S" ] || [ $resposta == "s" ]
then
echo "Qual a porta que pretende utilizar"
read porta
echo "Qual o Ip do servidor onde está alojado o serviço cockpit"
read ip
cd /etc/systemd/system
rm -r cockpit.socket.d
mkdir cockpit.socket.d
cd cockpit.socket.d
touch listen.conf
echo "[Socket]" >> listen.conf
echo "ListenStream=" >> listen.conf
echo "ListenStream=$ip:$porta" >> listen.conf
else
echo "O serviço irá funcionar na porta por default 9090"
echo "Qual o IP do servidor onde está alojado o serviço cockpit"
read ip
cd /etc/systemd/system
rm -r cockpit.socket.d
mkdir cockpit.socket.d
touch listen.conf
echo "[Socket]">> listen.conf
echo "ListenStream=" >> listen.conf
echo "ListenStream=$ip:$default_port" >> listen.conf
fi
systemctl daemon-reload
systemctl restart cockpit.socket
service cockpit restart
service cockpit status
exec bash
}
function vnc(){
#!/bin/bash
echo "*********************************************************************"
echo "*********************************************************************"
echo "******************************VNC************************************"
echo "*********************************************************************"
echo "*********************************************************************"
cd /
echo "1 - Estamos a configurar o Servidor VNC"
echo "2 - Estamos a configurar o Cliente VNC"
echo "Introduza a opção que pretende"
read opcao
case $opcao in
"1")
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa de rede NAT"
read placa_nat
echo "Qual o nome da placa de rede Internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
sleep 3
apt-get install -y tightvncserver xfce4 xfce4-goodies
ip link set $placa_nat down
ip link set $placa_internal up
vncpasswd 
cd /root/.vnc
rm -r xstartup
touch xstartup
echo " #!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
" >> xstartup
chmod +x xstartup
cd /
vncserver
echo "Vamos verificar qual a porta em que está a correr o serviço"
echo "Verificar se é a 5901, 5902, 5903..."
ss -ltn | more
echo "Qual a porta onde está a correr o serviço"
read porta
sudo ufw allow from any to any port $porta proto tcp
;;
"2")
cd /
echo "Quantas placas de rede tem a máquina local"
read placas
if [ $placas == "1" ]
then
echo "Qual o nome da placa de rede"
read placa
ip link set $placa up
fi
if [ $placas == "2" ]
then
echo "Qual o nome da placa de rede NAT"
read placa_nat
echo "Qual o nome da placa de rede Internal"
read placa_internal
fi
ip link set $placa_nat up
ip link set $placa_internal down
apt-get install -y xtightvncviewer ssh
ip link set $placa_nat down
ip link set $placa_internal up
echo "Pretende fazer a ligação VNC por ssh?"
echo "1 - Nao"
echo "2 - SIM"
read resposta
if [ $resposta == "1" ]
then
echo "Qual o IP do servidor de VNC"
read ip
ss -ltn |more
echo "Qual a porta onde corre o serviço VNC"
read porta
vncviewer $ip:$porta
else
echo "Optou por usar ssh para fazer a ligação VNC"
echo "Qual a porta onde está a correr o serviço"
read porta
echo "Qual o utilizador que pretende usar a ligação VNC"
read user
echo "Qual o IP do servidor VNC"
read ip
ssh -L $porta:127.0.0.1:$porta -N -f -l $user $ip
vncviewer localhost:$porta
fi
;;
esac
exec bash
}
function failover(){
#!/bin/bash
#- Run as root, of course
#- Initial check
printf "
       *************************************************************************\n
       *************************************************************************\n
       ** NAME: LOAD BALANCING                                          **\n
       **Deion:  made to do load balancing between Windows & Linux**\n
       **Author: SysAdmin                                                     **\n
       **Email: Administrator@ciseg.pt                                        **\n
       *************************************************************************\n
       *************************************************************************\n 
\n" >> /var/log/failover.log
# - Loop check
while true
do
if ping -c 1 172.20.27.1 &> /dev/null
then
printf "\n\n-----------------------------------------\n\nRemote Server ON\n\n Services turn down: DHCP & DNS\n\n Date: `date +\"%d-%m-%Y %T"`\n" >> /var/log/failover.log
echo "Deu"
systemctl stop isc-dhcp-server
systemctl stop bind9
else
printf "\n\n-----------------------------------------\n\nRemote Server OFF\n\n Services turn up: DHCP & DNS\n\n Date: `date +\"%d-%m-%Y %T\"`\n" >> /var/log/failover.log
echo "Não deu"
systemctl restart isc-dhcp-server
systemctl restart bind9
fi
sleep 1
done
}
menu_option=16
while [ $menu_option != 0 ]
do
echo "#################################################################"
echo "##		     1 - IP ESTÁTICO		             ##"
echo "##		     2 - SSH  				     ##"
echo "##	             3 - DOMINIO                             ##"
echo "##                     4 - DHCP                                ##" 
echo "##	             5 - DNS                                 ##"
echo "##                     6 - ASTERISK                            ##"
echo "##                     7 - POSTFIX                             ##"
echo "##                     8 - RSYSLOG                             ##"
echo "##                     9 - OPENFIRE                            ##"
echo "##                     10 - SAMBA                              ##"
echo "##                     11 - FTP                                ##"
echo "##                     12 - NFS                                ##"
echo "##                     13 - APACHE                             ##"
echo "##                     14 - COCKPIT                            ##"
echo "##                     15 - VNC                                ##"
echo "##                     16 - FAILOVER                           ##"
echo "#################################################################"
echo " 		      CHOOSE A SERVICE TO INSTALL                      "
echo "#################################################################"
echo "                 PRESS 0 TO EXIT THE                       "
echo "#################################################################"
echo "Enter the option you want"
read menu_option
clear
case $menu_option in
"1")
ip_estatico
;;
"2")
ssh
;;
"3")
dominio
;;
"4")
dhcp
;;
"5")
dns
;;
"6")
asterisk
;;
"7")
postfix
;;
"8")
rsyslog
;;
"9")
openfire
;;
"10")
samba
;;
"11")
ftp
;;
"12")
nfs
;;
"13")
apache
;;
"14")
cockpit
;;
"15")
vnc
;;
"16")
failover
;;
esac
done
echo "Goodbye"
exec bash
