#!/bin/bash
source .env
BASE="https://api.cloudflare.com/client/v4/accounts/$ACCOUNT"
WORKER="ventory-worker"
echo "🎮 VENTORY — Deploy completo..."
METADATA=$(cat << 'METAEOF'
{
  "main_module": "worker.js",
  "compatibility_date": "2024-09-23",
  "bindings": [
    {"type":"d1","name":"D1","database_id":"1d45241d-3a0e-4242-8b66-d872350c1c37"},
    {"type":"durable_object_namespace","name":"SALA","class_name":"SalaPartida"},
    {"type":"durable_object_namespace","name":"FILA","class_name":"FilaManager"}
  ],
  "migrations": {"tag":"v2","new_sqlite_classes":["SalaPartida","FilaManager"]}
}
METAEOF
)
RESULT=$(curl -s -X PUT "$BASE/workers/scripts/$WORKER" \
  -H "Authorization: Bearer $TOKEN" \
  -F "metadata=$METADATA;type=application/json" \
  -F "worker.js=@worker.js;type=application/javascript+module")
echo $RESULT | grep -q '"success":true' && echo "✅ Worker deployado!" || echo "❌ Erro: $RESULT"
curl -s -X POST "$BASE/workers/scripts/$WORKER/subdomain" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"enabled":true}' > /dev/null
echo "🎮 Ventory: https://$WORKER.daitonaer.workers.dev"
