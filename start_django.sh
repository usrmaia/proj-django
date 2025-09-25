#!/bin/bash

# Script de inicialização para Django + Gunicorn
# Uso: ./start_django.sh

echo "🚀 Iniciando Django com Gunicorn..."

# Verificar se virtual environment existe
if [ -d "venv" ]; then
    echo "📦 Ativando virtual environment..."
    source venv/bin/activate
fi

# Aplicar migrações
echo "📊 Aplicando migrações..."
python manage.py migrate --noinput

# Coletar arquivos estáticos
echo "🎨 Coletando arquivos estáticos..."
python manage.py collectstatic --noinput

# Iniciar Gunicorn com configuração correta para VPS
echo "🌐 Iniciando Gunicorn em 0.0.0.0:8000..."
exec gunicorn \
    --bind 0.0.0.0:8000 \
    --workers 3 \
    --worker-class sync \
    --worker-connections 1000 \
    --timeout 30 \
    --keepalive 2 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    --capture-output \
    app.wsgi:application