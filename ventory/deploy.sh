#!/bin/bash
source .env

BASE="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT"
WORKER="ventory-worker"

echo "🎮 VENTORY — iniciando deploy..."

METADATA=$(cat << 'METAEOF'
{
  "main_module": "worker.js",
  "compatibility_date": "2024-09-23",
  "bindings": [
    {
      "type": "d1",
      "name": "D1",
      "database_id": "1d45241d-3a0e-4242-8b66-d872350c1c37"
    },
    {
      "type": "durable_object_namespace",
      "name": "SALA",
      "class_name": "Sala"
    }
  ],
  "migrations": {
    "tag": "v1",
    "new_sqlite_classes": ["Sala"]
  }
}
METAEOF
)

echo "🚀 Deployando Worker..."
RESULT=$(curl -s -X PUT "$BASE/workers/scripts/$WORKER" \
  -H "Authorization: Bearer $TOKEN" \
  -F "metadata=$METADATA;type=application/json" \
  -F "worker.js=@worker.js;type=application/javascript+module")

echo $RESULT | grep -q '"success":true' && echo "✅ Worker deployado!" || echo "❌ Erro: $RESULT"

echo "🌐 Ativando subdomínio..."
curl -s -X POST "$BASE/workers/scripts/$WORKER/subdomain" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"enabled":true}' > /dev/null

echo ""
echo "🎮 Ventory online: https://$WORKER.daitonaer.workers.dev"
echo "   GET  /ping"
echo "   POST /register"
echo "   POST /login"
echo "   WS   /sala"
