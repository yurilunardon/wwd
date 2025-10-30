# Changelog

Tutte le modifiche notevoli a questo progetto saranno documentate in questo file.

## [1.0.0] - 2025-10-30

### Aggiunto
- 🎯 Menu bar app per monitorare screenshot
- 📊 Griglia interattiva per visualizzare screenshot recenti
- ⚙️ Sistema di configurazione con cartella e minuti personalizzabili
- 🎨 Animazioni di benvenuto
- 🔒 Gestione permessi Full Disk Access
- 🔔 Rilevamento automatico cambio cartella screenshot
- ⚡ Aggiornamento real-time (ogni 2 secondi)
- 🖱️ Menu contestuale con tasto destro (Settings, Quit)
- 💾 Persistenza impostazioni con UserDefaults
- 🔄 Funzione reset configurazione
- 📝 Script di build completo con comandi:
  - `build`: Compila l'app
  - `reset`: Resetta impostazioni
  - `clean`: Pulisce build
- 📖 Documentazione completa

### Caratteristiche Tecniche
- Supporto macOS 12.0+
- SwiftUI per UI moderna
- AppKit per integrazioni sistema
- Nessuna sandbox (come richiesto)
- Open source con licenza MIT

### Known Issues
- L'app richiede riavvio dopo aver concesso Full Disk Access
- Su alcuni sistemi il rilevamento cartella potrebbe richiedere alcuni secondi
