#!/bin/bash

#set localtime
#ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime

#####################
### Configuration ###
#####################
VPN_Owner='My VPN';
VPN_Name='MyVPN';
Filename_alias='myvpn';

### Added Server ports
Socks_port='80';
SSH_viaAuto='666';
Socks2_port='667';
Socks3_port='668';

### Default Server ports, Please dont change this area
OpenVPN_TCP_Port='110';
OpenVPN_UDP_Port='25222';
OpenVPN_TCP_EC='25980';
OpenVPN_UDP_EC='25985';
OpenVPN_TCP_OHP='8087';
OpenVPN_OHP_EC='8088';
Dropbear_OHP='8085';
SSH_viaOHP='8086';
SSH_Extra_Port='22';
SSH_Extra_Port='225';
Squid_Proxy_1='8000';
Squid_Proxy_2='8080';
SSL_viaOpenSSH1='443';
SSL_viaOpenSSH2='444';
Dropbear_Port1='550';
Dropbear_Port2='555';

### MySQL Remote Server side
DatabaseHost='67.211.218.75';
DatabaseName='rawterxy_rawter';
DatabaseUser='rawterxy_rawter1';
DatabasePass='d=PykXu0-B3T';
DatabasePort='3306';
#####################
#####################

function ip_address(){
  local IP="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( curl -4 -s ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( curl -4 -s ipinfo.io/ip )"
  [ ! -z "${IP}" ] && echo "${IP}" || echo
} 
MYIP=$(ip_address)

mkdir /etc/openvpn/script
chmod -R 755 /etc/openvpn/script
mkdir /var/www/html/stat
chmod -R 755 /var/www/html/stat

clear
echo -e "
                                                         
";
echo -e " To exit the script, kindly Press \e[1;32mCRTL\e[0m key together with \e[1;32mC\e[0m"
echo -e ""
echo -e " Are You Sure You Want To Install?:"
echo -e " [1] Yes"
until [[ "$opts" =~ ^[1]$ ]]; do
read -rp " Choose from [1]: " -e opts
done

#installing important files
dpkg --configure -a
apt install php sudo -y
apt install php-mysql mariadb-server apache2 -y
apt install php-cli net-tools curl cron php-fpm php-json php-pdo php-zip php-gd  php-mbstring php-curl php-xml php-bcmath php-json -y

#creating auth file
cat << EOF > /etc/openvpn/script/config.sh
#!/bin/bash
##Dababase Server
HOST='174.138.183.242'
USER='unexpect_anyplus'
PASS='unexpect_anyplus'
DB='unexpect_anyplus'
PORT='3306'
EOF

sed -i "s|DatabaseHost|$DatabaseHost|g" /etc/openvpn/script/config.sh
sed -i "s|DatabaseName|$DatabaseName|g" /etc/openvpn/script/config.sh
sed -i "s|DatabaseUser|$DatabaseUser|g" /etc/openvpn/script/config.sh
sed -i "s|DatabasePass|$DatabasePass|g" /etc/openvpn/script/config.sh
sed -i "s|DatabasePort|$DatabasePort|g" /etc/openvpn/script/config.sh

chmod +x /etc/openvpn/script/config.sh

case $opts in
 1)

#Modifying TCP Config
cat <<'LENZ01' >/etc/openvpn/server/server_tcp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_TCP_Port
dev tun
proto tcp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
client-to-client
auth-user-pass-verify "/etc/openvpn/script/premium.sh" via-env
client-connect /etc/openvpn/script/connectpremium.sh
client-disconnect /etc/openvpn/script/disconnectpremium.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.0.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /var/www/html/stat/tcp.txt
log /etc/openvpn/tcp.log
verb 2
script-security 3
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ01
sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" /etc/openvpn/server/server_tcp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/server_tcp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/server_tcp.conf

#Modifying UDP Config
cat <<'LENZ02' >/etc/openvpn/server/server_udp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_UDP_Port
dev tun
proto udp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
float
fast-io
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/premium.sh" via-env
client-connect /etc/openvpn/script/connectpremium.sh
client-disconnect /etc/openvpn/script/disconnectpremium.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.16.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /var/www/html/stat/udp.txt
log /etc/openvpn/udp.log
verb 2
script-security 3
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ02
sed -i "s|OpenVPN_UDP_Port|$OpenVPN_UDP_Port|g" /etc/openvpn/server/server_udp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/server_udp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/server_udp.conf

#Modifying TCP EC Config
cat <<'LENZ03' >/etc/openvpn/server/ec_server_tcp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_TCP_EC
proto tcp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/premium.sh" via-env
client-connect /etc/openvpn/script/connectpremium.sh
client-disconnect /etc/openvpn/script/disconnectpremium.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.32.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/tcp.txt
log /etc/openvpn/ec_tcp.log
verb 2
script-security 3
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ03
sed -i "s|OpenVPN_TCP_EC|$OpenVPN_TCP_EC|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_tcp.conf

#Modifying UDP EC Config
cat <<'LENZ04' >/etc/openvpn/server/ec_server_udp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_UDP_EC
proto udp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
float
fast-io
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/premium.sh" via-env
client-connect /etc/openvpn/script/connectpremium.sh
client-disconnect /etc/openvpn/script/disconnectpremium.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.48.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/udp.txt
log /etc/openvpn/ec_udp.log
verb 2
script-security 3
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ04
sed -i "s|OpenVPN_UDP_EC|$OpenVPN_UDP_EC|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_udp.conf

#client-connect file
cat <<'LENZ05' >/etc/openvpn/script/connectpremium.sh
#!/bin/bash

tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

##set status online to user connected
bandwidth_check=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "SELECT bandwidth_logs.username FROM bandwidth_logs WHERE bandwidth_logs.username='$common_name' AND bandwidth_logs.category='premium' AND bandwidth_logs.status='online'"`
if [ "$bandwidth_check" == 1 ]; then
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwith_logs SET server_ip='$local_1', server_port='$trusted_port', timestamp='$timestamp', ipaddress='$trusted_ip:$trusted_port', username='$common_name', time_in='$tm', since_connected='$time_ascii', bytes_received='$bytes_received', bytes_sent='$bytes_sent' WHERE username='$common_name' AND status='online' AND category='premium' "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=1 WHERE user_name='$common_name' "
else
mysql -u $USER -p$PASS -D $DB -h $HOST -e "INSERT INTO bandwidth_logs (server_ip, server_port, timestamp, ipaddress, since_connected, username, bytes_received, bytes_sent, time_in, status, time, category) VALUES ('$local_1','$trusted_port','$timestamp','$trusted_ip:$trusted_port','$time_ascii','$common_name','$bytes_received','$bytes_sent','$dt','online','$tm','premium') "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=1 WHERE user_name='$common_name' "
fi

LENZ05

#TCP client-disconnect file
cat <<'LENZ06' >/etc/openvpn/script/disconnectpremium.sh
#!/bin/bash
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online' AND category='premium' "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=0 WHERE user_name='$common_name' "

LENZ06

#client auth file
cat <<'LENZ07' >/etc/openvpn/script/premium.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
  
##PREMIUM##
PRE="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.duration > 0"
  
##VIP##
VIP="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.vip_duration > 0"
  
##PRIVATE##
PRIV="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.private_duration > 0"
  
Query="SELECT users.user_name FROM users WHERE $PRE OR $VIP OR $PRIV"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "$Query"`
  
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1

LENZ07

#### Setting up SSH CRON jobs for panel
cat <<'CronPanel1' > "/etc/$Filename_alias.cron.php"
<?php
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '1');

$DB_host = 'DatabaseHost';
$DB_user = 'DatabaseUser';
$DB_pass = 'DatabasePass';
$DB_name = 'DatabaseName';

$mysqli = new MySQLi($DB_host,$DB_user,$DB_pass,$DB_name);
if ($mysqli->connect_error) {
    die('Error : ('. $mysqli->connect_errno .') '. $mysqli->connect_error);
}

function encrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $encryptedPassword=encryptPaswd($paswd,$mykey);
	  return $encryptedPassword;
	}
	 
	// function to get the decrypted user password
	function decrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $decryptedPassword=decryptPaswd($paswd,$mykey);
	  return $decryptedPassword;
	}
	 
	function getEncryptKey()
	{
		$secret_key = md5('eugcar');
		$secret_iv = md5('sanchez');
		$keys = $secret_key . $secret_iv;
		return encryptor('encrypt', $keys);
	}
	function encryptPaswd($string, $key)
	{
	  $result = '';
	  for($i=0; $i<strlen ($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)+ord($keychar));
		$result.=$char;
	  }
		return base64_encode($result);
	}
	 
	function decryptPaswd($string, $key)
	{
	  $result = '';
	  $string = base64_decode($string);
	  for($i=0; $i<strlen($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)-ord($keychar));
		$result.=$char;
	  }
	 
		return $result;
	}
	
	function encryptor($action, $string) {
		$output = false;

		$encrypt_method = "AES-256-CBC";
		//pls set your unique hashing key
		$secret_key = md5('eugcar sanchez');
		$secret_iv = md5('sanchez eugcar');

		// hash
		$key = hash('sha256', $secret_key);
		
		// iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
		$iv = substr(hash('sha256', $secret_iv), 0, 16);

		//do the encyption given text/string/number
		if( $action == 'encrypt' ) {
			$output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
			$output = base64_encode($output);
		}
		else if( $action == 'decrypt' ){
			//decrypt the given text/string/number
			$output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);
		}

		return $output;
	}

$data = '';
$query = $mysqli->query("SELECT * FROM users
WHERE duration > 0 AND is_freeze = 0 OR is_freeze = 0 AND vip_duration > 0 OR is_freeze = 0 AND private_duration > 0 ORDER by user_id DESC");

if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$data .= '';
		$username = $row['user_name'];
		$password = decrypt_key($row['user_pass']);
		$password = encryptor('decrypt',$password);		
		$data .= '/usr/sbin/useradd -p $(openssl passwd -1 '.$password.') -s /bin/false -M '.$username.' &> /dev/null;'.PHP_EOL;
	}
}
$location = '/etc/openvpn/active.sh';
$fp = fopen($location, 'w');
fwrite($fp, $data) or die("Unable to open file!");
fclose($fp);


#In-Active and Invalid Accounts
$data2 = '';
$premium_deactived = "duration <= 0";
$vip_deactived = "vip_duration <= 0";
$private_deactived = "private_duration <= 0";
$is_validated = "is_validated=0";
$is_activate = "is_active=0";
$freeze = "is_freeze=1";
$pass = "is_passchange=1";
//$suspend = "suspend=1";

$query2 = $mysqli->query("SELECT * FROM users 
WHERE ".$pass." OR ".$freeze." OR ".$premium_deactived." AND ".$vip_deactived ." AND ".$private_deactived." OR ".$is_activate."
");
if($query2->num_rows > 0)
{
	while($row2 = $query2->fetch_assoc())
	{
		$data2 .= '';
		$toadd = $row2['user_name'];	
		$data2 .= '/usr/sbin/userdel -r -f '.$toadd.' &> /dev/null;'.PHP_EOL;
	}
}
$location2 = '/etc/openvpn/inactive.sh';
$fp = fopen($location2, 'w');
fwrite($fp, $data2) or die("Unable to open file!");
fclose($fp);

#Deleted Accounts
$data3 = '';

$query3 = $mysqli->query("SELECT * FROM users_delete 
WHERE id>0
");
if($query3->num_rows > 0)
{
	while($row3 = $query3->fetch_assoc())
	{
		$data3 .= '';
		$todel = $row3['user_name'];	
		$data3 .= '/usr/sbin/userdel -r -f '.$todel.' &> /dev/null;'.PHP_EOL;
	}
}
$location3 = '/etc/openvpn/deleted.sh';
$fp = fopen($location3, 'w');
fwrite($fp, $data3) or die("Unable to open file!");
fclose($fp);

$mysqli->close();
?>
CronPanel1

sed -i "s|DatabaseHost|$DatabaseHost|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseName|$DatabaseName|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseUser|$DatabaseUser|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabasePass|$DatabasePass|g" "/etc/$Filename_alias.cron.php"

chmod +x "/etc/$Filename_alias.cron.php"

#setting permissions
chmod +x /etc/openvpn/script/premium.sh
chmod +x /etc/openvpn/script/connectpremium.sh
chmod +x /etc/openvpn/script/disconnectpremium.sh

######################################################################################
######################################################################################
######################################################################################

 ;;
 2)
 
#Modifying TCP Config
cat <<'LENZ01' >/etc/openvpn/server/server_tcp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_TCP_Port
dev tun
proto tcp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
client-to-client
auth-user-pass-verify "/etc/openvpn/script/vip.sh" via-env
client-connect /etc/openvpn/script/connectvip.sh
client-disconnect /etc/openvpn/script/disconnectvip.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.0.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /var/www/html/stat/tcp.txt
log /etc/openvpn/tcp.log
verb 2
script-security 3
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ01
sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" /etc/openvpn/server/server_tcp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/server_tcp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/server_tcp.conf

#Modifying UDP Config
cat <<'LENZ02' >/etc/openvpn/server/server_udp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_UDP_Port
dev tun
proto udp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
float
fast-io
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/vip.sh" via-env
client-connect /etc/openvpn/script/connectvip.sh
client-disconnect /etc/openvpn/script/disconnectvip.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.16.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /var/www/html/stat/udp.txt
log /etc/openvpn/udp.log
verb 2
script-security 3
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ02
sed -i "s|OpenVPN_UDP_Port|$OpenVPN_UDP_Port|g" /etc/openvpn/server/server_udp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/server_udp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/server_udp.conf

#Modifying TCP EC Config
cat <<'LENZ03' >/etc/openvpn/server/ec_server_tcp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_TCP_EC
proto tcp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/vip.sh" via-env
client-connect /etc/openvpn/script/connectvip.sh
client-disconnect /etc/openvpn/script/disconnectvip.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.32.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/tcp.txt
log /etc/openvpn/ec_tcp.log
verb 2
script-security 3
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ03
sed -i "s|OpenVPN_TCP_EC|$OpenVPN_TCP_EC|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_tcp.conf

#Modifying UDP EC Config
cat <<'LENZ04' >/etc/openvpn/server/ec_server_udp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_UDP_EC
proto udp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
float
fast-io
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/vip.sh" via-env
client-connect /etc/openvpn/script/connectvip.sh
client-disconnect /etc/openvpn/script/disconnectvip.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.48.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/udp.txt
log /etc/openvpn/ec_udp.log
verb 2
script-security 3
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ04
sed -i "s|OpenVPN_UDP_EC|$OpenVPN_UDP_EC|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_udp.conf

#client-connect file
cat <<'LENZ05' >/etc/openvpn/script/connectvip.sh
#!/bin/bash

tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

##set status online to user connected
bandwidth_check=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "SELECT bandwidth_logs.username FROM bandwidth_logs WHERE bandwidth_logs.username='$common_name' AND bandwidth_logs.category='vip' AND bandwidth_logs.status='online'"`
if [ "$bandwidth_check" == 1 ]; then
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwith_logs SET server_ip='$local_1', server_port='$trusted_port', timestamp='$timestamp', ipaddress='$trusted_ip:$trusted_port', username='$common_name', time_in='$tm', since_connected='$time_ascii', bytes_received='$bytes_received', bytes_sent='$bytes_sent' WHERE username='$common_name' AND status='online' AND category='vip' "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=1 WHERE user_name='$common_name' "
else
mysql -u $USER -p$PASS -D $DB -h $HOST -e "INSERT INTO bandwidth_logs (server_ip, server_port, timestamp, ipaddress, since_connected, username, bytes_received, bytes_sent, time_in, status, time, category) VALUES ('$local_1','$trusted_port','$timestamp','$trusted_ip:$trusted_port','$time_ascii','$common_name','$bytes_received','$bytes_sent','$dt','online','$tm','vip') "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=1 WHERE user_name='$common_name' "
fi

LENZ05

#TCP client-disconnect file
cat <<'LENZ06' >/etc/openvpn/script/disconnectvip.sh
#!/bin/bash
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online' AND category='vip' "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=0 WHERE user_name='$common_name' "

LENZ06

#client auth file
cat <<'LENZ07' >/etc/openvpn/script/vip.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
  
##PREMIUM##
PRE="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.duration > 0"
  
##VIP##
VIP="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.vip_duration > 0"
  
##PRIVATE##
PRIV="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.private_duration > 0"
  
Query="SELECT users.user_name FROM users WHERE $VIP OR $PRIV"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "$Query"`
  
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1

LENZ07

#### Setting up SSH CRON jobs for panel
cat <<'CronPanel2' > "/etc/$Filename_alias.cron.php"
<?php
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '1');

$DB_host = 'DatabaseHost';
$DB_user = 'DatabaseUser';
$DB_pass = 'DatabasePass';
$DB_name = 'DatabaseName';

$mysqli = new MySQLi($DB_host,$DB_user,$DB_pass,$DB_name);
if ($mysqli->connect_error) {
    die('Error : ('. $mysqli->connect_errno .') '. $mysqli->connect_error);
}

function encrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $encryptedPassword=encryptPaswd($paswd,$mykey);
	  return $encryptedPassword;
	}
	 
	// function to get the decrypted user password
	function decrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $decryptedPassword=decryptPaswd($paswd,$mykey);
	  return $decryptedPassword;
	}
	 
	function getEncryptKey()
	{
		$secret_key = md5('eugcar');
		$secret_iv = md5('sanchez');
		$keys = $secret_key . $secret_iv;
		return encryptor('encrypt', $keys);
	}
	function encryptPaswd($string, $key)
	{
	  $result = '';
	  for($i=0; $i<strlen ($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)+ord($keychar));
		$result.=$char;
	  }
		return base64_encode($result);
	}
	 
	function decryptPaswd($string, $key)
	{
	  $result = '';
	  $string = base64_decode($string);
	  for($i=0; $i<strlen($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)-ord($keychar));
		$result.=$char;
	  }
	 
		return $result;
	}
	
	function encryptor($action, $string) {
		$output = false;

		$encrypt_method = "AES-256-CBC";
		//pls set your unique hashing key
		$secret_key = md5('eugcar sanchez');
		$secret_iv = md5('sanchez eugcar');

		// hash
		$key = hash('sha256', $secret_key);
		
		// iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
		$iv = substr(hash('sha256', $secret_iv), 0, 16);

		//do the encyption given text/string/number
		if( $action == 'encrypt' ) {
			$output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
			$output = base64_encode($output);
		}
		else if( $action == 'decrypt' ){
			//decrypt the given text/string/number
			$output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);
		}

		return $output;
	}

$data = '';
$query = $mysqli->query("SELECT * FROM users
WHERE is_freeze = 0 AND vip_duration > 0 OR is_freeze = 0 AND private_duration > 0 ORDER by user_id DESC");

if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$data .= '';
		$username = $row['user_name'];
		$password = decrypt_key($row['user_pass']);
		$password = encryptor('decrypt',$password);		
		$data .= '/usr/sbin/useradd -p $(openssl passwd -1 '.$password.') -s /bin/false -M '.$username.' &> /dev/null;'.PHP_EOL;
	}
}
$location = '/etc/openvpn/active.sh';
$fp = fopen($location, 'w');
fwrite($fp, $data) or die("Unable to open file!");
fclose($fp);


#In-Active and Invalid Accounts
$data2 = '';
$premium_deactived = "duration <= 0";
$vip_deactived = "vip_duration <= 0";
$private_deactived = "private_duration <= 0";
$is_validated = "is_validated=0";
$is_activate = "is_active=0";
$freeze = "is_freeze=1";
$pass = "is_passchange=1";
//$suspend = "suspend=1";

$query2 = $mysqli->query("SELECT * FROM users 
WHERE ".$pass." OR ".$freeze." OR ".$premium_deactived." AND ".$vip_deactived ." AND ".$private_deactived." OR ".$is_activate."
");
if($query2->num_rows > 0)
{
	while($row2 = $query2->fetch_assoc())
	{
		$data2 .= '';
		$toadd = $row2['user_name'];	
		$data2 .= '/usr/sbin/userdel -r -f '.$toadd.' &> /dev/null;'.PHP_EOL;
	}
}
$location2 = '/etc/openvpn/inactive.sh';
$fp = fopen($location2, 'w');
fwrite($fp, $data2) or die("Unable to open file!");
fclose($fp);

#Deleted Accounts
$data3 = '';

$query3 = $mysqli->query("SELECT * FROM users_delete 
WHERE id>0
");
if($query3->num_rows > 0)
{
	while($row3 = $query3->fetch_assoc())
	{
		$data3 .= '';
		$todel = $row3['user_name'];	
		$data3 .= '/usr/sbin/userdel -r -f '.$todel.' &> /dev/null;'.PHP_EOL;
	}
}
$location3 = '/etc/openvpn/deleted.sh';
$fp = fopen($location3, 'w');
fwrite($fp, $data3) or die("Unable to open file!");
fclose($fp);

$mysqli->close();
?>
CronPanel2

sed -i "s|DatabaseHost|$DatabaseHost|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseName|$DatabaseName|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseUser|$DatabaseUser|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabasePass|$DatabasePass|g" "/etc/$Filename_alias.cron.php"

chmod +x "/etc/$Filename_alias.cron.php"

#setting permissions
chmod +x /etc/openvpn/script/vip.sh
chmod +x /etc/openvpn/script/connectvip.sh
chmod +x /etc/openvpn/script/disconnectvip.sh

######################################################################################
######################################################################################
######################################################################################

 ;;
 3)
 
#Modifying TCP Config
cat <<'LENZ01' >/etc/openvpn/server/server_tcp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_TCP_Port
dev tun
proto tcp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
reneg-sec 0
client-to-client
auth-user-pass-verify "/etc/openvpn/script/private.sh" via-env
client-connect /etc/openvpn/script/connectprivate.sh
client-disconnect /etc/openvpn/script/disconnectprivate.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.0.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /var/www/html/stat/tcp.txt
log /etc/openvpn/tcp.log
verb 2
script-security 3
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ01
sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" /etc/openvpn/server/server_tcp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/server_tcp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/server_tcp.conf

#Modifying UDP Config
cat <<'LENZ02' >/etc/openvpn/server/server_udp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_UDP_Port
dev tun
proto udp
ca /etc/openvpn/ca.crt
cert /etc/openvpn/bonvscripts.crt
key /etc/openvpn/bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
comp-lzo
tun-mtu 1500
float
fast-io
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/private.sh" via-env
client-connect /etc/openvpn/script/connectprivate.sh
client-disconnect /etc/openvpn/script/disconnectprivate.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.16.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
status /var/www/html/stat/udp.txt
log /etc/openvpn/udp.log
verb 2
script-security 3
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ02
sed -i "s|OpenVPN_UDP_Port|$OpenVPN_UDP_Port|g" /etc/openvpn/server/server_udp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/server_udp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/server_udp.conf

#Modifying TCP EC Config
cat <<'LENZ03' >/etc/openvpn/server/ec_server_tcp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_TCP_EC
proto tcp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/private.sh" via-env
client-connect /etc/openvpn/script/connectprivate.sh
client-disconnect /etc/openvpn/script/disconnectprivate.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.32.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/tcp.txt
log /etc/openvpn/ec_tcp.log
verb 2
script-security 3
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ03
sed -i "s|OpenVPN_TCP_EC|$OpenVPN_TCP_EC|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_tcp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_tcp.conf

#Modifying UDP EC Config
cat <<'LENZ04' >/etc/openvpn/server/ec_server_udp.conf
# VPN_Name Server
# Server by VPN_Owner

port OpenVPN_UDP_EC
proto udp
dev tun
ca /etc/openvpn/ec_ca.crt
cert /etc/openvpn/ec_bonvscripts.crt
key /etc/openvpn/ec_bonvscripts.key
dh none
persist-tun
persist-key
persist-remote-ip
#duplicate-cn
cipher none
ncp-disable
auth none
compress lz4
push "compress lz4"
tun-mtu 1500
float
fast-io
reneg-sec 0
auth-user-pass-verify "/etc/openvpn/script/private.sh" via-env
client-connect /etc/openvpn/script/connectprivate.sh
client-disconnect /etc/openvpn/script/disconnectprivate.sh
verify-client-cert none
username-as-common-name
max-clients 4080
topology subnet
server 172.29.48.0 255.255.240.0
push "redirect-gateway def1"
keepalive 5 30
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
status /var/www/html/stat/udp.txt
log /etc/openvpn/ec_udp.log
verb 2
script-security 3
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
status-version 1

LENZ04
sed -i "s|OpenVPN_UDP_EC|$OpenVPN_UDP_EC|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Name|$VPN_Name|g" /etc/openvpn/server/ec_server_udp.conf
sed -i "s|VPN_Owner|$VPN_Owner|g" /etc/openvpn/server/ec_server_udp.conf

#client-connect file
cat <<'LENZ05' >/etc/openvpn/script/connectprivate.sh
#!/bin/bash

tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

##set status online to user connected
bandwidth_check=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "SELECT bandwidth_logs.username FROM bandwidth_logs WHERE bandwidth_logs.username='$common_name' AND bandwidth_logs.category='private' AND bandwidth_logs.status='online'"`
if [ "$bandwidth_check" == 1 ]; then
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwith_logs SET server_ip='$local_1', server_port='$trusted_port', timestamp='$timestamp', ipaddress='$trusted_ip:$trusted_port', username='$common_name', time_in='$tm', since_connected='$time_ascii', bytes_received='$bytes_received', bytes_sent='$bytes_sent' WHERE username='$common_name' AND status='online' AND category='private' "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=1 WHERE user_name='$common_name' "
else
mysql -u $USER -p$PASS -D $DB -h $HOST -e "INSERT INTO bandwidth_logs (server_ip, server_port, timestamp, ipaddress, since_connected, username, bytes_received, bytes_sent, time_in, status, time, category) VALUES ('$local_1','$trusted_port','$timestamp','$trusted_ip:$trusted_port','$time_ascii','$common_name','$bytes_received','$bytes_sent','$dt','online','$tm','private') "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=1 WHERE user_name='$common_name' "
fi

LENZ05

#TCP client-disconnect file
cat <<'LENZ06' >/etc/openvpn/script/disconnectprivate.sh
#!/bin/bash
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

. /etc/openvpn/script/config.sh

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online' AND category='private' "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=0 WHERE user_name='$common_name' "

LENZ06

#client auth file
cat <<'LENZ07' >/etc/openvpn/script/private.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
  
##PREMIUM##
PRE="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.duration > 0"
  
##VIP##
VIP="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.vip_duration > 0"
  
##PRIVATE##
PRIV="users.user_name='$username' AND users.auth_vpn=md5('$password') AND users.is_validated=1 AND users.is_freeze=0 AND users.is_active=1 AND users.is_ban=0 AND users.private_duration > 0"
  
Query="SELECT users.user_name FROM users WHERE $PRIV"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "$Query"`
  
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1

LENZ07

#### Setting up SSH CRON jobs for panel
cat <<'CronPanel1' > "/etc/$Filename_alias.cron.php"
<?php
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '1');

$DB_host = 'DatabaseHost';
$DB_user = 'DatabaseUser';
$DB_pass = 'DatabasePass';
$DB_name = 'DatabaseName';

$mysqli = new MySQLi($DB_host,$DB_user,$DB_pass,$DB_name);
if ($mysqli->connect_error) {
    die('Error : ('. $mysqli->connect_errno .') '. $mysqli->connect_error);
}

function encrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $encryptedPassword=encryptPaswd($paswd,$mykey);
	  return $encryptedPassword;
	}
	 
	// function to get the decrypted user password
	function decrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $decryptedPassword=decryptPaswd($paswd,$mykey);
	  return $decryptedPassword;
	}
	 
	function getEncryptKey()
	{
		$secret_key = md5('eugcar');
		$secret_iv = md5('sanchez');
		$keys = $secret_key . $secret_iv;
		return encryptor('encrypt', $keys);
	}
	function encryptPaswd($string, $key)
	{
	  $result = '';
	  for($i=0; $i<strlen ($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)+ord($keychar));
		$result.=$char;
	  }
		return base64_encode($result);
	}
	 
	function decryptPaswd($string, $key)
	{
	  $result = '';
	  $string = base64_decode($string);
	  for($i=0; $i<strlen($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)-ord($keychar));
		$result.=$char;
	  }
	 
		return $result;
	}
	
	function encryptor($action, $string) {
		$output = false;

		$encrypt_method = "AES-256-CBC";
		//pls set your unique hashing key
		$secret_key = md5('eugcar sanchez');
		$secret_iv = md5('sanchez eugcar');

		// hash
		$key = hash('sha256', $secret_key);
		
		// iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
		$iv = substr(hash('sha256', $secret_iv), 0, 16);

		//do the encyption given text/string/number
		if( $action == 'encrypt' ) {
			$output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
			$output = base64_encode($output);
		}
		else if( $action == 'decrypt' ){
			//decrypt the given text/string/number
			$output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);
		}

		return $output;
	}

$data = '';
$query = $mysqli->query("SELECT * FROM users
WHERE is_freeze = 0 AND private_duration > 0 ORDER by user_id DESC");

if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$data .= '';
		$username = $row['user_name'];
		$password = decrypt_key($row['user_pass']);
		$password = encryptor('decrypt',$password);		
		$data .= '/usr/sbin/useradd -p $(openssl passwd -1 '.$password.') -s /bin/false -M '.$username.' &> /dev/null;'.PHP_EOL;
	}
}
$location = '/etc/openvpn/active.sh';
$fp = fopen($location, 'w');
fwrite($fp, $data) or die("Unable to open file!");
fclose($fp);


#In-Active and Invalid Accounts
$data2 = '';
$premium_deactived = "duration <= 0";
$vip_deactived = "vip_duration <= 0";
$private_deactived = "private_duration <= 0";
$is_validated = "is_validated=0";
$is_activate = "is_active=0";
$freeze = "is_freeze=1";
$pass = "is_passchange=1";
//$suspend = "suspend=1";

$query2 = $mysqli->query("SELECT * FROM users 
WHERE ".$pass." OR ".$freeze." OR ".$premium_deactived." AND ".$vip_deactived ." AND ".$private_deactived." OR ".$is_activate."
");
if($query2->num_rows > 0)
{
	while($row2 = $query2->fetch_assoc())
	{
		$data2 .= '';
		$toadd = $row2['user_name'];	
		$data2 .= '/usr/sbin/userdel -r -f '.$toadd.' &> /dev/null;'.PHP_EOL;
	}
}
$location2 = '/etc/openvpn/inactive.sh';
$fp = fopen($location2, 'w');
fwrite($fp, $data2) or die("Unable to open file!");
fclose($fp);

#Deleted Accounts
$data3 = '';

$query3 = $mysqli->query("SELECT * FROM users_delete 
WHERE id>0
");
if($query3->num_rows > 0)
{
	while($row3 = $query3->fetch_assoc())
	{
		$data3 .= '';
		$todel = $row3['user_name'];	
		$data3 .= '/usr/sbin/userdel -r -f '.$todel.' &> /dev/null;'.PHP_EOL;
	}
}
$location3 = '/etc/openvpn/deleted.sh';
$fp = fopen($location3, 'w');
fwrite($fp, $data3) or die("Unable to open file!");
fclose($fp);

$mysqli->close();
?>
CronPanel1

sed -i "s|DatabaseHost|$DatabaseHost|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseName|$DatabaseName|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabaseUser|$DatabaseUser|g" "/etc/$Filename_alias.cron.php"
sed -i "s|DatabasePass|$DatabasePass|g" "/etc/$Filename_alias.cron.php"

chmod +x "/etc/$Filename_alias.cron.php"

#setting permissions
chmod +x /etc/openvpn/script/private.sh
chmod +x /etc/openvpn/script/connectprivate.sh
chmod +x /etc/openvpn/script/disconnectprivate.sh

 ;;
esac

echo -e "* *\t* * *\troot\t php -q /etc/$Filename_alias.cron.php" > "/etc/cron.d/$Filename_alias"
echo -e "* *\t* * *\troot\t bash /etc/openvpn/active.sh" >> "/etc/cron.d/$Filename_alias"
echo -e "* *\t* * *\troot\t bash /etc/openvpn/inactive.sh" >> "/etc/cron.d/$Filename_alias"
echo -e "* *\t* * *\troot\t bash /etc/openvpn/deleted.sh" >> "/etc/cron.d/$Filename_alias"

#installing ohp
wget https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohpserver-linux32.zip
unzip ohpserver-linux32.zip
chmod 755 ohpserver
sudo mv ohpserver /usr/local/bin/

#Adding Socks
wget -O /home/proxydirect.py "http://firenetvpn.net/files/socks1"

sed -i "s|Socks_port|$Socks_port|g" "/home/proxydirect.py"
sed -i "s|SSH_Extra_Port|$SSH_Extra_Port|g" "/home/proxydirect.py"
sed -i "s|VPN_Name|$VPN_Name|g" "/home/proxydirect.py"
sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" "/home/proxydirect.py"

#Adding Autorecon Socks 
wget -O /home/proxydirect2.py "http://firenetvpn.net/files/socks2"

sed -i "s|Socks2_port|$Socks2_port|g" "/home/proxydirect2.py"
sed -i "s|SSH_Extra_Port|$SSH_Extra_Port|g" "/home/proxydirect2.py"
sed -i "s|VPN_Name|$VPN_Name|g" "/home/proxydirect2.py"
sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" "/home/proxydirect2.py"

#Adding OVPN Autorecon Socks 
wget -O /home/proxydirect3.py "http://firenetvpn.net/files/socks3"

sed -i "s|Socks3_port|$Socks3_port|g" "/home/proxydirect3.py"
sed -i "s|SSH_Extra_Port|$SSH_Extra_Port|g" "/home/proxydirect3.py"
sed -i "s|VPN_Name|$VPN_Name|g" "/home/proxydirect3.py"
sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" "/home/proxydirect3.py"

cat <<'socks' > /etc/systemd/system/socks.service
[Unit]
Description=Daemonize socks

[Service]
Type=simple
ExecStart=/usr/bin/python /home/proxydirect.py

[Install]
WantedBy=multi-user.target
socks

#adding autorecon
cat <<'ohpssh2' > /etc/systemd/system/ohplenz.service
[Unit]
Description=Daemonize OpenHTTP Puncher Autorecon
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port SSH_viaAuto -proxy 127.0.0.1:Squid_Proxy_2 -tunnel IP-ADDRESS:SSH_Extra_Port
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
ohpssh2

sed -i "s|SSH_viaAuto|$SSH_viaAuto|g" "/etc/systemd/system/ohplenz.service"
sed -i "s|Squid_Proxy_2|$Squid_Proxy_2|g" "/etc/systemd/system/ohplenz.service"
sed -i "s|IP-ADDRESS|$MYIP|g" "/etc/systemd/system/ohplenz.service"
sed -i "s|SSH_Extra_Port|$SSH_Extra_Port|g" "/etc/systemd/system/ohplenz.service"

#adding autorecon socks
cat <<'socks1' > /etc/systemd/system/sockslenz.service
[Unit]
Description=Daemonize Socks Autorecon
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/bin/python /home/proxydirect2.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
socks1

#adding ovpn autorecon socks
cat <<'socks2' > /etc/systemd/system/sockslenz2.service
[Unit]
Description=Daemonize Socks Autorecon
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/bin/python /home/proxydirect3.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
socks2

systemctl daemon-reload
systemctl start socks
systemctl enable socks
systemctl start ohplenz
systemctl enable ohplenz
systemctl start sockslenz
systemctl enable sockslenz
systemctl start sockslenz2
systemctl enable sockslenz2

#creating autorecon script
cat <<'autorecon' > /home/lenz
sudo systemctl restart ohplenz
sudo systemctl restart sockslenz
sudo systemctl restart sockslenz2
sleep 60
sudo systemctl restart ohplenz
sudo systemctl restart sockslenz
sudo systemctl restart sockslenz2

autorecon

#adding autorecon cron
cat <<'autorecon2' > /etc/cron.d/autorecon
*/2 *   * * *   root    bash /home/lenz
autorecon2

cat <<'Ovpn01' > "/var/www/openvpn/tcp-default.ovpn"
## VPN_Name Server
## Config by VPN_Owner

client
dev tun
persist-tun
proto tcp
remote IP-ADDRESS OpenVPN_TCP_Port
http-proxy IP-ADDRESS Squid_Proxy_1
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
auth-user-pass
Ovpn01

sed -i "s|VPN_Name|$VPN_Name|g" "/var/www/openvpn/tcp-default.ovpn"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/var/www/openvpn/tcp-default.ovpn"
sed -i "s|IP-ADDRESS|$MYIP|g" "/var/www/openvpn/tcp-default.ovpn"
sed -i "s|OpenVPN_TCP_Port|$OpenVPN_TCP_Port|g" "/var/www/openvpn/tcp-default.ovpn"
sed -i "s|Squid_Proxy_1|$Squid_Proxy_1|g" "/var/www/openvpn/tcp-default.ovpn"
echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> "/var/www/openvpn/tcp-default.ovpn"

cat <<'Ovpn02' > "/var/www/openvpn/tcp-ec.ovpn"
## VPN_Name Server
## Config by VPN_Owner

client
dev tun
persist-tun
proto tcp
remote IP-ADDRESS OpenVPN_TCP_EC
http-proxy IP-ADDRESS Squid_Proxy_1
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
auth-user-pass
Ovpn02

sed -i "s|VPN_Name|$VPN_Name|g" "/var/www/openvpn/tcp-ec.ovpn"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/var/www/openvpn/tcp-ec.ovpn"
sed -i "s|IP-ADDRESS|$MYIP|g" "/var/www/openvpn/tcp-ec.ovpn"
sed -i "s|OpenVPN_TCP_EC|$OpenVPN_TCP_EC|g" "/var/www/openvpn/tcp-ec.ovpn"
sed -i "s|Squid_Proxy_1|$Squid_Proxy_1|g" "/var/www/openvpn/tcp-ec.ovpn"
echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> "/var/www/openvpn/tcp-ec.ovpn"

cat <<'Ovpn03' > "/var/www/openvpn/tcp-ohp.ovpn"
## VPN_Name Server
## Config by VPN_Owner

client
dev tun
persist-tun
proto tcp

# We can play this one, put any host on the line
# remote anyhost.com anyport
# remote www.google.com.ph 443
#
# We can also play with CRLFs
#remote "HEAD https://ajax.googleapis.com HTTP/1.1/r/n/r/n"
# Every types of Broken remote line setups/crlfs/payload are accepted, just put them inside of double-quotes
remote "https://www.firenetph.com"
## use this line to modify OpenVPN remote port (this will serve as our fake ovpn port)
port 443

# This proxy uses as our main forwarder for OpenVPN tunnel.
http-proxy IP-ADDRESS OpenVPN_TCP_OHP

# We can also play our request headers here, everything are accepted, put them inside of a double-quotes.
http-proxy-option VERSION 1.1
http-proxy-option CUSTOM-HEADER ""
http-proxy-option CUSTOM-HEADER "Host: www.firenetph.com%2F"
http-proxy-option CUSTOM-HEADER "X-Forwarded-Host: www.digicert.net%2F"
http-proxy-option CUSTOM-HEADER ""

persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
auth-user-pass
Ovpn03

sed -i "s|VPN_Name|$VPN_Name|g" "/var/www/openvpn/tcp-ohp.ovpn"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/var/www/openvpn/tcp-ohp.ovpn"
sed -i "s|IP-ADDRESS|$MYIP|g" "/var/www/openvpn/tcp-ohp.ovpn"
sed -i "s|OpenVPN_TCP_OHP|$OpenVPN_TCP_OHP|g" "/var/www/openvpn/tcp-ohp.ovpn"
echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> "/var/www/openvpn/tcp-ohp.ovpn"

cat <<'Ovpn04' > "/var/www/openvpn/tcp-ec-ohp.ovpn"
## VPN_Name Server
## Config by VPN_Owner

client
dev tun
persist-tun
proto tcp

# We can play this one, put any host on the line
# remote anyhost.com anyport
# remote www.google.com.ph 443
#
# We can also play with CRLFs
#remote "HEAD https://ajax.googleapis.com HTTP/1.1/r/n/r/n"
# Every types of Broken remote line setups/crlfs/payload are accepted, just put them inside of double-quotes
remote "https://www.firenetph.com"
## use this line to modify OpenVPN remote port (this will serve as our fake ovpn port)
port 443

# This proxy uses as our main forwarder for OpenVPN tunnel.
http-proxy IP-ADDRESS OpenVPN_OHP_EC

# We can also play our request headers here, everything are accepted, put them inside of a double-quotes.
http-proxy-option VERSION 1.1
http-proxy-option CUSTOM-HEADER ""
http-proxy-option CUSTOM-HEADER "Host: www.firenetph.com%2F"
http-proxy-option CUSTOM-HEADER "X-Forwarded-Host: www.digicert.net%2F"
http-proxy-option CUSTOM-HEADER ""

persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
auth-user-pass
Ovpn04

sed -i "s|VPN_Name|$VPN_Name|g" "/var/www/openvpn/tcp-ec-ohp.ovpn"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/var/www/openvpn/tcp-ec-ohp.ovpn"
sed -i "s|IP-ADDRESS|$MYIP|g" "/var/www/openvpn/tcp-ec-ohp.ovpn"
sed -i "s|OpenVPN_OHP_EC|$OpenVPN_OHP_EC|g" "/var/www/openvpn/tcp-ec-ohp.ovpn"
echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> "/var/www/openvpn/tcp-ec-ohp.ovpn"

cat <<'Ovpn05' > "/var/www/openvpn/udp-default.ovpn"
## VPN_Name Server
## Config by VPN_Owner

client
dev tun
persist-tun
proto udp
remote IP-ADDRESS OpenVPN_UDP_Port
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
float
fast-io
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
auth-user-pass
Ovpn05

sed -i "s|VPN_Name|$VPN_Name|g" "/var/www/openvpn/udp-default.ovpn"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/var/www/openvpn/udp-default.ovpn"
sed -i "s|IP-ADDRESS|$MYIP|g" "/var/www/openvpn/udp-default.ovpn"
sed -i "s|OpenVPN_UDP_Port|$OpenVPN_UDP_Port|g" "/var/www/openvpn/udp-default.ovpn"
echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> "/var/www/openvpn/udp-default.ovpn"

cat <<'Ovpn06' > "/var/www/openvpn/udp-ec.ovpn"
## VPN_Name Server
## Config by VPN_Owner

client
dev tun
persist-tun
proto udp
remote IP-ADDRESS OpenVPN_UDP_EC
persist-remote-ip
resolv-retry infinite
connect-retry 0 1
remote-cert-tls server
nobind
float
fast-io
reneg-sec 0
keysize 0
rcvbuf 0
sndbuf 0
verb 2
comp-lzo
auth none
auth-nocache
cipher none
setenv CLIENT_CERT 0
tls-client
tls-version-min 1.2
tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
auth-user-pass
Ovpn06

sed -i "s|VPN_Name|$VPN_Name|g" "/var/www/openvpn/udp-ec.ovpn"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/var/www/openvpn/udp-ec.ovpn"
sed -i "s|IP-ADDRESS|$MYIP|g" "/var/www/openvpn/udp-ec.ovpn"
sed -i "s|OpenVPN_UDP_EC|$OpenVPN_UDP_EC|g" "/var/www/openvpn/udp-ec.ovpn"
echo -e "<ca>\n$(cat /etc/openvpn/ca.crt)\n</ca>" >> "/var/www/openvpn/udp-ec.ovpn"

#Modifying Config Page
wget -O /var/www/openvpn/index.html "http://firenetvpn.net/files/download"

sed -i "s|IP-ADDRESS|$MYIP|g" "/var/www/openvpn/index.html"

#Banner, MOTD, issue
cat <<'BANNER' >/etc/banner
<br>
==========================
<br><font color=red size=7><b>WARNING</b></font>
<br>
<br><font color=red size=7><b>NOT FOLLOWING THE RULES WILL BE FREEZED/BANNED ACCOUNT INTO OUR DATABASE</b></font>
<br>
==========================
<br>
<i><font color='red'>- NO SPAMMING !!!</br></font></i>
<br><i><font color='red'>- NO DDOS !!!</br></font></i>
<br><i><font color='red'>- NO HACKING !!!</br></font></i>
<br><i><font color='red'>- NO CARDING !!!</br></font></i>
<br><i><font color='red'>- NO DUAL-LOGIN !!!</br></font></i>
<br><i><font color='red'>- NO TORRENT !!!</i></br></font></i>
<br>
==========================
<br>
<font color=red size=7><b>VPN_Owner</b></font>
<br>
==========================
<br>
BANNER

cat <<'MOTD' >/etc/motd
<br>
==========================
<br><font color=red size=7><b>WARNING</b></font>
<br>
<br><font color=red size=7><b>NOT FOLLOWING THE RULES WILL BE FREEZED/BANNED ACCOUNT INTO OUR DATABASE</b></font>
<br>
==========================
<br>
<i><font color='red'>- NO SPAMMING !!!</br></font></i>
<br><i><font color='red'>- NO DDOS !!!</br></font></i>
<br><i><font color='red'>- NO HACKING !!!</br></font></i>
<br><i><font color='red'>- NO CARDING !!!</br></font></i>
<br><i><font color='red'>- NO DUAL-LOGIN !!!</br></font></i>
<br><i><font color='red'>- NO TORRENT !!!</i></br></font></i>
<br>
==========================
<br>
<font color=red size=7><b>VPN_Owner</b></font>
<br>
==========================
<br>
MOTD

cat <<'ISSUE' >/etc/issue.net
<br>
==========================
<br><font color=red size=7><b>WARNING</b></font>
<br>
<br><font color=red size=7><b>NOT FOLLOWING THE RULES WILL BE FREEZED/BANNED ACCOUNT INTO OUR DATABASE</b></font>
<br>
==========================
<br>
<i><font color='red'>- NO SPAMMING !!!</br></font></i>
<br><i><font color='red'>- NO DDOS !!!</br></font></i>
<br><i><font color='red'>- NO HACKING !!!</br></font></i>
<br><i><font color='red'>- NO CARDING !!!</br></font></i>
<br><i><font color='red'>- NO DUAL-LOGIN !!!</br></font></i>
<br><i><font color='red'>- NO TORRENT !!!</i></br></font></i>
<br>
==========================
<br>
<font color=red size=7><b>VPN_Owner</b></font>
<br>
==========================
<br>
ISSUE

sed -i "s|VPN_Owner|$VPN_Owner|g" "/etc/banner"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/etc/motd"
sed -i "s|VPN_Owner|$VPN_Owner|g" "/etc/issue.net"

#Modifying Multilogin Script
cat <<'Multilogin' >/usr/local/sbin/set_multilogin_autokill_lib
#!/bin/bash

. /etc/openvpn/script/config.sh

clear

MAX=1
if [ -e "/var/log/auth.log" ]; then
        OS=1;
        LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
        OS=2;
        LOG="/var/log/secure";
fi

if [ $OS -eq 1 ]; then
	service ssh restart > /dev/null 2>&1;
fi
if [ $OS -eq 2 ]; then
	service sshd restart > /dev/null 2>&1;
fi
	service dropbear restart > /dev/null 2>&1;
				
if [[ ${1+x} ]]; then
        MAX=$1;
fi

        cat /etc/passwd | grep "/home/" | cut -d":" -f1 > /root/user.txt
        username1=( `cat "/root/user.txt" `);
        i="0";
        for user in "${username1[@]}"
			do
                username[$i]=`echo $user | sed 's/'\''//g'`;
                jumlah[$i]=0;
                i=$i+1;
			done
        cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/log-db.txt
        proc=( `ps aux | grep -i dropbear | awk '{print $2}'`);
        for PID in "${proc[@]}"
			do
                cat /tmp/log-db.txt | grep "dropbear\[$PID\]" > /tmp/log-db-pid.txt
                NUM=`cat /tmp/log-db-pid.txt | wc -l`;
                USERS=`cat /tmp/log-db-pid.txt | awk '{print $10}' | sed 's/'\''//g'`;
                IP=`cat /tmp/log-db-pid.txt | awk '{print $12}'`;
                if [ $NUM -eq 1 ]; then
                        i=0;
                        for user1 in "${username[@]}"
							do
                                if [ "$USERS" == "$user1" ]; then
                                        jumlah[$i]=`expr ${jumlah[$i]} + 1`;
                                        pid[$i]="${pid[$i]} $PID"
                                fi
                                i=$i+1;
							done
                fi
			done
        cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/log-db.txt
        data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);
        for PID in "${data[@]}"
			do
                cat /tmp/log-db.txt | grep "sshd\[$PID\]" > /tmp/log-db-pid.txt;
                NUM=`cat /tmp/log-db-pid.txt | wc -l`;
                USERS=`cat /tmp/log-db-pid.txt | awk '{print $9}'`;
                IP=`cat /tmp/log-db-pid.txt | awk '{print $11}'`;
                if [ $NUM -eq 1 ]; then
                        i=0;
                        for user1 in "${username[@]}"
							do
                                if [ "$USERS" == "$user1" ]; then
                                        jumlah[$i]=`expr ${jumlah[$i]} + 1`;
                                        pid[$i]="${pid[$i]} $PID"
                                fi
                                i=$i+1;
							done
                fi
        done
        j="0";
        for i in ${!username[*]}
			do
                if [ ${jumlah[$i]} -gt $MAX ]; then
                        date=`date +"%Y-%m-%d %X"`;
                        USERNAME=${username[$i]};
                        echo "$date - ${username[$i]} - ${jumlah[$i]}";
                        echo "$date - ${username[$i]} - ${jumlah[$i]}" >> /root/log-limit.txt;
                        kill ${pid[$i]};
                        pid[$i]="";
                        j=`expr $j + 1`;
                        
                fi
			done
        if [ $j -gt 0 ]; then
                if [ $OS -eq 1 ]; then
                        service ssh restart > /dev/null 2>&1;
                fi
                if [ $OS -eq 2 ]; then
                        service sshd restart > /dev/null 2>&1;
                fi
                service dropbear restart > /dev/null 2>&1;
                j=0;
		fi
Multilogin

chmod +x /usr/local/sbin/set_multilogin_autokill_lib
echo -e "* * * * *  root /usr/local/sbin/set_multilogin_autokill_lib 1" >> "/etc/cron.d/set_multilogin_autokill_lib"

#Restarting Services
service openvpn-server@ec_server_tcp restart
service openvpn-server@ec_server_udp restart
service openvpn-server@server_tcp restart
service openvpn-server@server_udp restart
service cron restart
service apache2 restart
chmod -R 755 /var/www/html/stat

echo -e "\n SSH Server: $SSH_Extra_Port\n SSH via OHP: $SSH_viaOHP\n Socks Port: $Socks_port\n SSH via OHP(Autorecon): $SSH_viaAuto\n SSL Server: $SSL_viaOpenSSH1, $SSL_viaOpenSSH2\n Dropbear Server: $Dropbear_Port1, $Dropbear_Port2\n Dropbear via OHP: $Dropbear_OHP\n OpenVPN Server (TCP): $OpenVPN_TCP_Port\n OpenVPN Server (UDP): $OpenVPN_UDP_Port\n OpenVPN Server (TCP EC): $OpenVPN_TCP_EC\n OpenVPN Server (UDP EC): $OpenVPN_UDP_EC\n OpenVPN Server (TCP OHP): $OpenVPN_TCP_OHP\n Squid Proxy Server: $Squid_Proxy_1, $Squid_Proxy_2\n OpenVPN TCP Config: http://$(curl -4s http://ipinfo.io/ip):86\n Script by: $VPN_Owner\n" > "/var/www/html/ports"

#Deleting patch file
cd
rm -rf *
clear

echo "
############################################################
# SERVER INFO:
# SSH Server: $SSH_Extra_Port                              
# SSH via OHP: $SSH_viaOHP                                 
# Socks Port: $Socks_port                                  
# Socks Port(Autorecon): $Socks2_port            
# Socks Port OVPN-TCP(Autorecon): $Socks3_port     
# SSH via OHP(Autorecon): $SSH_viaAuto                     
# SSL Server Port: $SSL_viaOpenSSH1, $SSL_viaOpenSSH2                         
# Dropbear Port: $Dropbear_Port1, $Dropbear_Port2 
# Dropbear via OHP: $Dropbear_OHP
# OpenVPN Server (TCP): $OpenVPN_TCP_Port                  
# OpenVPN Server (UDP): $OpenVPN_UDP_Port  
# OpenVPN Server (TCP EC): $OpenVPN_TCP_EC
# OpenVPN Server (UDP EC): $OpenVPN_UDP_EC
# OpenVPN Server (TCP OHP): $OpenVPN_TCP_OHP
# Squid Proxy Server: $Squid_Proxy_1, $Squid_Proxy_2       
# OpenVPN Config: http://$(curl -4s http://ipinfo.io/ip):86
#
# Michael Patch Script v1.1        
# Authentication file system                
# Setup by: Al-amin             
#
############################################################";

echo '
                                     
';

echo 'rebooting....';
sleep 5
reboot
