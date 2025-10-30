#!/bin/bash

# Script per eseguire HandyShots e vedere i log

APP_PATH="build/HandyShots.app/Contents/MacOS/HandyShots"

if [ ! -f "$APP_PATH" ]; then
    echo "❌ App non trovata in $APP_PATH"
    echo "Esegui prima: ./Scripts/build.sh"
    exit 1
fi

echo "🚀 Avvio HandyShots da terminale..."
echo "→ Vedrai i log dell'app qui sotto"
echo "→ Premi Ctrl+C per terminare"
echo ""
echo "================================"

# Esegui l'app e mostra output
"$APP_PATH"
