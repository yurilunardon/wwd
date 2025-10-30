# Screenshot Monitor 📸

Una semplice menu bar app per macOS che monitora e mostra gli screenshot recenti.

## Caratteristiche

- 🎯 **Menu Bar App**: Si integra nella barra dei menu di macOS
- 📊 **Griglia Screenshot**: Visualizza gli screenshot degli ultimi X minuti in una griglia
- ⚙️ **Configurabile**: Scegli la cartella da monitorare e i minuti da tracciare
- 🔔 **Rilevamento Automatico**: Rileva automaticamente quando cambia la cartella screenshot del sistema
- 🎨 **Animazioni**: Video di benvenuto animato e UI fluida
- 🔓 **No Sandbox**: Nessuna restrizione sandbox per massima compatibilità

## Requisiti

- macOS 12.0 (Monterey) o superiore
- Xcode Command Line Tools (per compilare)
- Full Disk Access permission

## Installazione

### 1. Compila l'app

```bash
cd MacScreensApp
./Scripts/build.sh
```

### 2. Installa l'app

```bash
cp -r build/Screenshot\ Monitor.app /Applications/
```

### 3. Concedi i permessi

1. Apri **Preferenze di Sistema** → **Sicurezza e Privacy** → **Privacy**
2. Seleziona **Accesso completo al disco**
3. Clicca sul lucchetto per apportare modifiche
4. Clicca **+** e aggiungi **Screenshot Monitor.app**

### 4. Avvia l'app

```bash
open /Applications/Screenshot\ Monitor.app
```

## Utilizzo

### Primo Avvio

1. L'app richiederà i permessi Full Disk Access
2. Dopo aver concesso i permessi, vedrai un video di benvenuto animato
3. L'app rileverà automaticamente la cartella degli screenshot
4. Configura i minuti da monitorare (default: 5 minuti)

### Funzionalità

- **Click sull'icona**: Apre/chiude la griglia degli screenshot
- **Click su screenshot**: Apre lo screenshot nell'app predefinita
- **Tasto destro → Settings**: Apri le impostazioni
  - Cambia cartella da monitorare
  - Modifica minuti da tracciare
  - Reset configurazione
- **Tasto destro → Quit**: Chiudi l'app

### Rilevamento Cartella

Se il sistema cambia la cartella dove salva gli screenshot, l'app mostrerà automaticamente un messaggio overlay con la possibilità di:
- **Accettare** la nuova cartella
- **Ignorare** il cambiamento

## Comandi Script

Lo script `build.sh` supporta diversi comandi:

```bash
# Compila l'app
./Scripts/build.sh

# Resetta le impostazioni dell'app
./Scripts/build.sh reset

# Pulisce i file di build
./Scripts/build.sh clean

# Mostra aiuto
./Scripts/build.sh help
```

## Reset Completo

Per tornare allo stato iniziale dell'app:

```bash
# Resetta impostazioni
./Scripts/build.sh reset

# Oppure usa le Settings nell'app
# Click sull'icona → Settings → Reset Configurazione
```

## Struttura Progetto

```
MacScreensApp/
├── Sources/
│   ├── ScreenshotMonitorApp.swift      # App principale e AppDelegate
│   ├── WelcomeView.swift               # Video di benvenuto e configurazione
│   ├── PermissionRequestView.swift     # Richiesta permessi
│   ├── MainScreenshotGridView.swift    # Griglia screenshot principale
│   └── SettingsView.swift              # Finestra impostazioni
├── Scripts/
│   └── build.sh                        # Script di build e reset
├── Info.plist                          # Configurazione bundle
├── ScreenshotMonitor.entitlements      # Entitlements (no sandbox)
└── README.md                           # Questo file
```

## Note Tecniche

### Permessi

L'app richiede **Full Disk Access** per:
- Leggere gli screenshot dalla cartella configurata
- Monitorare cambiamenti nella cartella
- Generare thumbnail degli screenshot

### Storage

Le impostazioni sono salvate in `UserDefaults`:
- `hasCompletedSetup`: Bool per tracciare se il setup è completato
- `screenshotFolder`: Path della cartella da monitorare
- `monitorMinutes`: Numero di minuti da tracciare

### Sicurezza

⚠️ **Attenzione**: Questa app NON usa sandbox e ha accesso completo al disco. È pensata per uso personale e tra amici. Il codice è open source per trasparenza.

## Troubleshooting

### L'app non parte

1. Verifica di aver concesso i permessi Full Disk Access
2. Controlla la console per eventuali errori: `Console.app`

### Non vedo screenshot

1. Verifica che la cartella configurata sia corretta
2. Prova a scattare un nuovo screenshot
3. Controlla che i minuti configurati siano sufficienti

### L'app non rileva nuovi screenshot

1. L'app controlla ogni 2 secondi per nuovi file
2. Verifica i permessi Full Disk Access
3. Riavvia l'app

## Sviluppo

### Compilazione Manuale

```bash
# Compila tutti i file Swift
swiftc Sources/*.swift \
    -o build/ScreenshotMonitor \
    -framework Cocoa \
    -framework SwiftUI \
    -framework AppKit \
    -sdk "$(xcrun --show-sdk-path)" \
    -target "$(uname -m)-apple-macosx12.0"
```

### Debug

Per vedere i log dell'app:

```bash
# Esegui da terminale per vedere l'output
./build/Screenshot\ Monitor.app/Contents/MacOS/ScreenshotMonitor
```

## License

Open Source - Usa come vuoi! 🎉

## Autore

Creato con Claude Code 🤖
