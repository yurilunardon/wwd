# 🚀 Quick Start

Guida rapida per iniziare con HandyShots.

## ⚡ Setup Veloce (3 passi)

### 1. Compila
```bash
cd MacScreensApp
./Scripts/build.sh
```

### 2. Installa
```bash
cp -r build/Screenshot\ Monitor.app /Applications/
```

### 3. Configura Permessi
1. Apri l'app: `open /Applications/Screenshot\ Monitor.app`
2. Quando richiesto, vai in **Preferenze di Sistema** → **Sicurezza e Privacy** → **Privacy** → **Accesso completo al disco**
3. Aggiungi HandyShots
4. Riapri l'app

✅ Fatto! L'app è pronta.

## 🎯 Uso Base

- **Click sinistro** sull'icona: Apri/chiudi griglia screenshot
- **Click destro** sull'icona: Menu (Settings, Quit)
- **Click su screenshot**: Apri il file

## 🔧 Comandi Utili

```bash
# Build
./Scripts/build.sh

# Reset impostazioni
./Scripts/build.sh reset

# Pulisci build
./Scripts/build.sh clean
```

## ❓ Problemi?

Leggi il [README completo](README.md) per troubleshooting e dettagli.
