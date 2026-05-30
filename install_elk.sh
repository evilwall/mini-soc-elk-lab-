#!/bin/bash

set -e

echo "==================================="
echo "ELK Stack 8.x Installation Script"
echo "För Ubuntu Server 24.04 (SOC Setup, med HTTPS på Kibana)"
echo "==================================="

if [ "$EUID" -ne 0 ]; then
    echo "Detta script måste köras som root eller med sudo"
    exit 1
fi

echo "Uppdaterar systemet..."
apt update && apt upgrade -y

echo "Installerar nödvändiga paket..."
apt install -y gnupg2 apt-transport-https curl wget openssl

echo "Lägger till Elastic GPG-nyckel..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
  gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

echo "Lägger till Elastic repository..."
cat >/etc/apt/sources.list.d/elastic-8.x.list <<EOF
deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main
EOF

echo "Uppdaterar paketlistan..."
apt update

echo "Installerar Elasticsearch..."
apt install -y elasticsearch > /tmp/elasticsearch_install.log 2>&1

echo ""
echo "==================================="
echo "VIKTIGT: Spara detta lösenord!"
echo "==================================="
grep "generated password" /tmp/elasticsearch_install.log || echo "Lösenord finns i /tmp/elasticsearch_install.log"
echo "==================================="
echo ""
sleep 5

echo "Installerar Kibana..."
apt install -y kibana

echo "Installerar Logstash (valfritt)..."
apt install -y logstash

echo ""
echo "Konfigurerar Elasticsearch för single-node..."
# Backup original config
cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak

# discovery.type single-node
if ! grep -q "^discovery.type:" /etc/elasticsearch/elasticsearch.yml; then
    echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
fi

# Bind till alla interfaces (OBS: bara vettigt i labb/DMZ)
if ! grep -q "^network.host:" /etc/elasticsearch/elasticsearch.yml; then
    echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
fi

# Kommentera bort cluster.initial_master_nodes om single-node
if grep -q "^discovery.type: single-node" /etc/elasticsearch/elasticsearch.yml; then
    sed -i 's/^cluster.initial_master_nodes:/#cluster.initial_master_nodes:/' /etc/elasticsearch/elasticsearch.yml
    echo "Kommenterade bort cluster.initial_master_nodes (ej kompatibel med single-node)"
fi

echo "Konfigurerar Kibana..."
cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak

# Lägg till server.host och server.port om de saknas
if ! grep -q "^server.host:" /etc/kibana/kibana.yml; then
    cat >> /etc/kibana/kibana.yml << 'KIBANA_CONF'

# Kibana Server Configuration
server.host: "0.0.0.0"
server.port: 5601

KIBANA_CONF
fi

# Generera encryption keys bara om de inte redan finns
if ! grep -q "xpack.encryptedSavedObjects.encryptionKey" /etc/kibana/kibana.yml; then
    echo "Genererar krypteringsnycklar för Kibana..."
    /usr/share/kibana/bin/kibana-encryption-keys generate -q > /tmp/kibana_keys.txt

    {
        echo ""
        echo "# Encryption keys generated $(date)"
        cat /tmp/kibana_keys.txt
    } >> /etc/kibana/kibana.yml

    rm -f /tmp/kibana_keys.txt
    echo "Krypteringsnycklar har lagts till i kibana.yml"
else
    echo "Krypteringsnycklar finns redan, hoppar över."
fi

echo "Skapar self-signed cert för Kibana HTTPS under /usr/share/kibana/certs..."

KIBANA_CERT_DIR="/usr/share/kibana/certs"
KIBANA_CERT="${KIBANA_CERT_DIR}/kibana.crt"
KIBANA_KEY="${KIBANA_CERT_DIR}/kibana.key"

mkdir -p "${KIBANA_CERT_DIR}"

# Skapa self-signed cert om det inte redan finns
if [ ! -f "${KIBANA_CERT}" ] || [ ! -f "${KIBANA_KEY}" ]; then
    # CN sätts till hostens FQDN, duger fint i labb
    openssl req -x509 -nodes -newkey rsa:4096 \
        -keyout "${KIBANA_KEY}" \
        -out "${KIBANA_CERT}" \
        -days 365 \
        -subj "/C=SE/ST=Stockholm/L=Stockholm/O=Lab/OU=SOC/CN=$(hostname -f)"

    echo "Self-signed cert skapat:"
    echo "  Cert: ${KIBANA_CERT}"
    echo "  Nyckel: ${KIBANA_KEY}"
else
    echo "Cert/nyckel för Kibana finns redan, hoppar över generering."
fi

# Sätt rätt ägare & rättigheter så Kibana kan läsa dem
chown -R kibana:kibana "${KIBANA_CERT_DIR}"
chmod 640 "${KIBANA_KEY}"
chmod 644 "${KIBANA_CERT}"

echo "Aktiverar HTTPS i Kibana med self-signed cert..."

# Ta bort ev gamla server.ssl-rader för att undvika dubletter
sed -i '/^server\.ssl\./d' /etc/kibana/kibana.yml

cat >> /etc/kibana/kibana.yml <<EOF

# ===== TLS/HTTPS (self-signed) =====
server.ssl.enabled: true
server.ssl.certificate: "${KIBANA_CERT}"
server.ssl.key: "${KIBANA_KEY}"
# Valfritt: om du vill att Kibana skriver rätt URL i länkar:
# server.publicBaseUrl: "https://$(hostname -I | awk '{print $1}'):5601"
EOF

echo "Kibana konfigurerad för HTTPS (self-signed cert)."

echo ""
echo "Startar Elasticsearch..."
systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch

echo "Väntar på att Elasticsearch ska starta (30 sekunder)..."
sleep 30

# Verifiera att Elasticsearch är uppe (TLS är default i 8.x)
if curl -k -s https://localhost:9200 > /dev/null 2>&1; then
    echo "✓ Elasticsearch är uppe och kör (TLS aktiverat)!"
else
    echo "⚠ Varning: Elasticsearch svarar inte ännu. Kontrollera med 'sudo journalctl -u elasticsearch'"
fi

echo ""
echo "Startar Kibana..."
systemctl enable kibana
systemctl restart kibana

echo "Startar Logstash..."
systemctl enable logstash
systemctl start logstash

echo ""
echo "Väntar på att Kibana ska starta (60 sekunder)..."
sleep 60

echo ""
echo "Kontrollerar tjänsternas status..."
systemctl status elasticsearch --no-pager -l | head -20
echo ""
systemctl status kibana --no-pager -l | head -20

# Försök hämta IP-adress
SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "==================================="
echo "✓ Installation klar!"
echo "==================================="
echo ""
echo "TJÄNSTER:"
echo "  Elasticsearch: https://localhost:9200       (TLS med auto-genererat cert, Elastic 8.x default)"
echo "  Kibana:        https://${SERVER_IP}:5601    (TLS med self-signed cert – webbläsaren varnar)"
echo ""
echo "==================================="
echo "NÄSTA STEG 1: SÄKERHET"
echo "==================================="
echo ""
echo "1. Hämta/återställ elastic-lösenord:"
echo ""
echo "   sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic"
echo ""
echo "2. Generera Kibana enrollment token:"
echo ""
echo "   sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana"
echo ""
echo "3. Öppna Kibana i webbläsaren (HTTPS, self-signed – acceptera varningen):"
echo ""
echo "   https://${SERVER_IP}:5601"
echo ""
echo "4. Klistra in enrollment token och logga in med:"
echo "   Användare: elastic"
echo "   Lösenord: [från steg 1]"
echo ""
echo "==================================="
echo "NÄSTA STEG 2: FLEET SERVER (för SOC)"
echo "==================================="
echo ""
echo "När du är inloggad i Kibana:"
echo ""
echo "1. Gå till: Management → Fleet"
echo "2. Klicka 'Add Fleet Server' → 'Quick Start'"
echo "3. Kör kommandot på denna server (Fleet Server):"
echo ""
echo "   sudo elastic-agent install \\"
echo "     --url=https://${SERVER_IP}:8220 \\"
echo "     --enrollment-token=TOKEN_FRÅN_KIBANA \\"
echo "     --fleet-server-es=https://localhost:9200 \\"
echo "     --fleet-server-service-token=SERVICE_TOKEN \\"
echo "     --fleet-server-policy=fleet-server-policy"
echo ""
echo "==================================="
echo "BRANDVÄGG (om ufw är aktivt)"
echo "==================================="
echo ""
if command -v ufw &> /dev/null; then
    echo "Öppna portar med:"
    echo ""
    echo "  sudo ufw allow 9200/tcp   # Elasticsearch (om du verkligen vill exponera den)"
    echo "  sudo ufw allow 5601/tcp   # Kibana (HTTPS)"
    echo "  sudo ufw allow 8220/tcp   # Fleet Server"
    echo "  sudo ufw reload"
else
    echo "ufw är inte installerat - inga brandväggsregler satta automatiskt."
fi
echo ""
echo "==================================="
echo "FELSÖKNING"
echo "==================================="
echo ""
echo "Elasticsearch-loggar:"
echo "  sudo journalctl -u elasticsearch -f"
echo ""
echo "Kibana-loggar:"
echo "  sudo journalctl -u kibana -f"
echo ""
echo "Testa Elasticsearch:"
echo "  curl -k -u elastic:LÖSENORD https://localhost:9200"
echo ""
echo "Testa Kibana status (från servern):"
echo "  curl -k https://localhost:5601/status"
echo ""
echo "Konfigurationsfiler:"
echo "  /etc/elasticsearch/elasticsearch.yml"
echo "  /etc/kibana/kibana.yml"
echo ""
echo "Installationsloggar:"
echo "  /tmp/elasticsearch_install.log"
echo ""
echo "==================================="
echo ""
