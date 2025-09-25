#!/bin/bash

echo "=== STATUS DOS CONTAINERS ==="
docker ps

echo -e "\n=== LOGS RECENTES DO DJANGO ==="
# Ajuste o nome do container conforme necessário
docker logs --tail 50 $(docker ps --format "table {{.Names}}" | grep -E "(django|app)" | head -1) 2>/dev/null || echo "Container Django não encontrado. Liste os containers acima e ajuste o comando."

echo -e "\n=== VERIFICAR NETWORK DOS CONTAINERS ==="
echo "Network do Traefik:"
docker inspect $(docker ps --format "table {{.Names}}" | grep traefik | head -1) --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || echo "Container Traefik não encontrado"

echo "Network do Django:"
docker inspect $(docker ps --format "table {{.Names}}" | grep -E "(django|app)" | head -1) --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || echo "Container Django não encontrado"

echo -e "\n=== VERIFICAR PORTAS EM USO ==="
docker exec $(docker ps --format "table {{.Names}}" | grep -E "(django|app)" | head -1) netstat -tlnp 2>/dev/null || echo "Não foi possível executar netstat no container Django"

echo -e "\n=== TESTAR CONECTIVIDADE INTERNA ==="
echo "Testando conexão do Traefik para o Django..."
DJANGO_CONTAINER=$(docker ps --format "table {{.Names}}" | grep -E "(django|app)" | head -1)
TRAEFIK_CONTAINER=$(docker ps --format "table {{.Names}}" | grep traefik | head -1)

if [ ! -z "$DJANGO_CONTAINER" ] && [ ! -z "$TRAEFIK_CONTAINER" ]; then
    docker exec $TRAEFIK_CONTAINER wget -qO- --timeout=5 http://$DJANGO_CONTAINER:8000/ 2>&1 || echo "Falha na conexão entre Traefik e Django"
else
    echo "Containers não encontrados para teste de conectividade"
fi