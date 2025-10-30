#!/bin/bash

# Screenshot Monitor - Build & Reset Script
# Questo script compila l'app e può resettare le impostazioni

set -e

APP_NAME="Screenshot Monitor"
BUNDLE_ID="com.yourname.screenshotmonitor"
EXECUTABLE_NAME="ScreenshotMonitor"
BUILD_DIR="build"
SOURCES_DIR="Sources"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

function show_help() {
    echo "Screenshot Monitor - Build & Reset Script"
    echo ""
    echo "Uso:"
    echo "  ./build.sh              - Compila l'app"
    echo "  ./build.sh reset        - Resetta le impostazioni dell'app"
    echo "  ./build.sh clean        - Pulisce i file di build"
    echo "  ./build.sh help         - Mostra questo messaggio"
    echo ""
}

function reset_app() {
    print_header "Reset Impostazioni App"

    print_info "Rimozione impostazioni UserDefaults..."
    defaults delete "$BUNDLE_ID" 2>/dev/null || true
    print_success "Impostazioni resettate"

    print_info "Rimozione cache app..."
    rm -rf ~/Library/Caches/"$BUNDLE_ID" 2>/dev/null || true
    print_success "Cache rimossa"

    print_success "App resettata allo stato iniziale!"
}

function clean_build() {
    print_header "Pulizia Build"

    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
        print_success "Directory build pulita"
    else
        print_info "Nessun file da pulire"
    fi
}

function build_app() {
    print_header "Compilazione Screenshot Monitor"

    # Verifica di essere nella directory corretta
    if [ ! -d "$SOURCES_DIR" ]; then
        print_error "Errore: directory Sources non trovata!"
        echo "Assicurati di eseguire lo script dalla directory MacScreensApp/"
        exit 1
    fi

    # Crea directory build
    print_info "Creazione directory build..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    # Compila i file Swift
    print_info "Compilazione codice Swift..."

    SOURCES=$(find "$SOURCES_DIR" -name "*.swift" | tr '\n' ' ')

    swiftc $SOURCES \
        -o "$BUILD_DIR/$EXECUTABLE_NAME" \
        -framework Cocoa \
        -framework SwiftUI \
        -framework AppKit \
        -sdk "$(xcrun --show-sdk-path)" \
        -target "$(uname -m)-apple-macosx12.0"

    if [ $? -ne 0 ]; then
        print_error "Errore durante la compilazione!"
        exit 1
    fi

    print_success "Compilazione completata"

    # Crea struttura .app bundle
    print_info "Creazione bundle applicazione..."

    APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
    CONTENTS_DIR="$APP_BUNDLE/Contents"
    MACOS_DIR="$CONTENTS_DIR/MacOS"
    RESOURCES_DIR="$CONTENTS_DIR/Resources"

    mkdir -p "$MACOS_DIR"
    mkdir -p "$RESOURCES_DIR"

    # Copia eseguibile
    cp "$BUILD_DIR/$EXECUTABLE_NAME" "$MACOS_DIR/"
    chmod +x "$MACOS_DIR/$EXECUTABLE_NAME"

    # Copia Info.plist
    cp Info.plist "$CONTENTS_DIR/"

    # Copia entitlements (per riferimento)
    cp ScreenshotMonitor.entitlements "$RESOURCES_DIR/"

    print_success "Bundle applicazione creato"

    # Crea icona placeholder (opzionale)
    print_info "Generazione icona..."
    # Per ora saltiamo la generazione icona, può essere aggiunta dopo

    print_success "Build completata!"
    echo ""
    print_success "App creata in: $APP_BUNDLE"
    echo ""
    print_info "Per installare l'app:"
    echo "  cp -r '$APP_BUNDLE' /Applications/"
    echo ""
    print_info "Per eseguire l'app:"
    echo "  open '$APP_BUNDLE'"
    echo ""
}

# Main script
case "${1:-build}" in
    build)
        build_app
        ;;
    reset)
        reset_app
        ;;
    clean)
        clean_build
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Comando non riconosciuto: $1"
        show_help
        exit 1
        ;;
esac
