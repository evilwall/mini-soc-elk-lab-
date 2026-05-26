#!/bin/bash
set -e

# Lab use only.
# Do not store real passwords, enrollment tokens, service tokens, or log files with credentials in Git.

echo "==================================="
echo "ELK Stack 8.x Installation Script"
echo "For Ubuntu Server 24.04 (SOC Setup)"
echo "==================================="

if [ "$EUID" -ne 0 ]; then
  echo "Detta script måste köras som root eller med sudo"
  exit 1
fi

echo "Uppdaterar systemet..."
apt update && apt upgrade -y

echo "Installerar nödvändiga paket..."
apt install gnupg2 apt-transport-https curl wget -y

echo "Lägger till Elastic GPG-nyckel..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

echo "Lägger till Elastic repository..."
cat > /etc/apt/sources.list.d/elastic-8.x.list <<EOF
deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main
EOF

echo "Uppdaterar paketlistan..."
apt update

echo "Installerar Elasticsearch..."
apt install elasticsearch -y > /tmp/elasticsearch_install.log 2>&1

echo ""
echo "==================================="
echo "VIKTIGT: Ett lösenord kan ha genererats under installationen."
echo "Spara det säkert och publicera aldrig lösenord, tokens eller loggfiler i GitHub."
echo "==================================="
echo ""

sleep 5

echo "Installerar Kibana..."
apt install kibana -y

echo "Installerar Logstash (valfritt)..."
apt install logstash -y

echo ""
echo "Konfigurerar Elasticsearch för single-node..."

cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak

if ! grep -q "^discovery.type:" /etc/elasticsearch/elasticsearch.yml; then
  echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
fi

if ! grep -q "^network.host:" /etc/elasticsearch/elasticsearch.yml; then
  echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
fi

if grep -q "^discovery.type: single-node" /etc/elasticsearch/elasticsearch.yml; then
  sed -i 's/^cluster.initial_master_nodes:/#cluster.initial_master_nodes:/' /etc/elasticsearch/elasticsearch.yml
  echo "Kommenterade bort cluster.initial_master_nodes (ej kompatibel med single-node)"
fi

echo "Konfigurerar Kibana..."
cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak

if ! grep -q "^server.host:" /etc/kibana/kibana.yml; then
  cat >> /etc/kibana/kibana.yml <<'KIBANA_CONF'
# Kibana Server Configuration
server.host: "0.0.0.0"
server.port: 5601
KIBANA_CONF
fi

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

echo ""
echo "Startar Elasticsearch..."
systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch

echo "Väntar på att Elasticsearch ska starta (30 sekunder)..."
sleep 30

if curl -k -s https://localhost:9200 > /dev/null 2>&1; then
  echo "✓ Elasticsearch är uppe och kör!"
else
  echo "⚠ Varning: Elasticsearch svarar inte ännu. Kontrollera med 'sudo journalctl -u elasticsearch'"
fi

echo ""
echo "Startar Kibana..."
systemctl enable kibana
systemctl start kibana

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

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "==================================="
echo "✓ Installation klar!"
echo "==================================="
echo ""
echo "TJÄNSTER:"
echo " Elasticsearch: https://localhost:9200"
echo " Kibana: http://${SERVER_IP}:5601"
echo ""
echo "==================================="
echo "NÄSTA STEG 1: SÄKERHET"
echo "==================================="
echo ""
echo "1. Hämta/återställ elastic-lösenord:"
echo ""
echo " sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic"
echo ""
echo "2. Generera Kibana enrollment token:"
echo ""
echo " sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana"
echo ""
echo "3. Öppna Kibana i webbläsaren (HTTP, inte HTTPS):"
echo ""
echo " http://${SERVER_IP}:5601"
echo ""
echo "4. Klistra in enrollment token och logga in med:"
echo " Användare: elastic"
echo " Lösenord: [från steg 1]"
echo ""
echo "==================================="
echo "NÄSTA STEG 2: FLEET SERVER (för SOC)"
echo "==================================="
echo ""
echo "När du är inloggad i Kibana:"
echo ""
echo "1. Gå till: Management → Fleet"
echo ""
echo "2. Klicka 'Add Fleet Server' → 'Quick Start'"
echo ""
echo "3. Kopiera och kör det visade kommandot på denna server, ungefär:"
echo ""
echo " sudo elastic-agent install \\"
echo " --url=https://${SERVER_IP}:8220 \\"
echo " --enrollment-token=TOKEN_FRÅN_KIBANA \\"
echo " --fleet-server-es=https://localhost:9200 \\"
echo " --fleet-server-service-token=SERVICE_TOKEN \\"
echo " --fleet-server-policy=fleet-server-policy"
echo ""
echo "4. Skapa en Agent Policy för endpoints:"
echo " Fleet → Agent Policies → Create agent policy"
echo " Namn: t.ex. 'SOC-Endpoints'"
echo ""
echo "5. Lägg till integrations i policyn:"
echo " - 'System' integration (logs och metrics)"
echo " - 'Elastic Defend' integration (endpoint security/EDR)"
echo ""
echo "6. Installera Elastic Agent på dina klienter:"
echo " Fleet → Agents → Add agent"
echo " Välj din 'SOC-Endpoints' policy"
echo " Kopiera install-kommandot för Windows/Linux"
echo " Kör på varje endpoint (Kali, Windows, etc.)"
echo ""
echo "7. Verifiera endpoints:"
echo " Security → Hosts (se alla endpoints)"
echo " Security → Alerts (detections och events)"
echo ""
echo "==================================="
echo "BRANDVÄGG (om ufw är aktivt)"
echo "==================================="
echo ""

if command -v ufw &> /dev/null; then
  echo "Öppna portar med:"
  echo ""
  echo " sudo ufw allow 9200/tcp # Elasticsearch"
  echo " sudo ufw allow 5601/tcp # Kibana"
  echo " sudo ufw allow 8220/tcp # Fleet Server"
  echo " sudo ufw reload"
else
  echo "ufw är inte installerat - inga brandväggsregler behövs."
fi

echo ""
echo "==================================="
echo "FELSÖKNING"
echo "==================================="
echo ""
echo "Elasticsearch-loggar:"
echo " sudo journalctl -u elasticsearch -f"
echo ""
echo "Kibana-loggar:"
echo " sudo journalctl -u kibana -f"
echo ""
echo "Testa Elasticsearch:"
echo " curl -k -u elastic:[YOUR_PASSWORD] https://localhost:9200"
echo ""
echo "Testa Kibana:"
echo " curl http://localhost:5601/status"
echo ""
echo "Konfigurationsfiler:"
echo " /etc/elasticsearch/elasticsearch.yml"
echo " /etc/kibana/kibana.yml"
echo ""
echo "Installationsloggar:"
echo " /tmp/elasticsearch_install.log"
echo ""
echo "==================================="
echo ""
