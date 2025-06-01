#!/bin/bash

# 📁 Datei- oder Ordnerpfad über Argument übergeben
TARGET="$1"

# 🚨 Kein Pfad übergeben?
if [ -z "$TARGET" ]; then
  echo "❌ Bitte gib einen Dateipfad an: ./secure_delete.sh /Pfad/zur/Datei"
  exit 1
fi

# ❓ Datei existiert?
if [ ! -e "$TARGET" ]; then
  echo "❌ Datei nicht gefunden: $TARGET"
  exit 1
fi

# 🔍 Dateisystem prüfen
VOLUME=$(df "$TARGET" | tail -1 | awk '{print $1}')
FSTYPE=$(diskutil info "$VOLUME" | grep "Type (Bundle)" | awk -F: '{print $2}' | xargs)

# ⚠️ Warnung bei APFS
if [[ "$FSTYPE" == "apfs" ]]; then
  echo "⚠️  Dein Dateisystem ist APFS – sicheres Überschreiben ist technisch nicht garantiert!"
fi

# 🔐 Optional verschlüsseln vor Löschung
read -p "🔐 Möchtest du die Datei vor dem Löschen mit AES256 verschlüsseln (y/n)? " ENCRYPT

if [[ "$ENCRYPT" == "y" ]]; then
  openssl enc -aes-256-cbc -salt -in "$TARGET" -out "${TARGET}.enc"
  echo "✅ Verschlüsselte Kopie erstellt: ${TARGET}.enc"
fi

# 🧨 Löschen mit srm oder Fallback auf rm
if command -v srm &> /dev/null; then
  echo "🗑 Sicheres Löschen mit srm..."
  srm -vsm "$TARGET"
else
  echo "⚠️  srm ist nicht installiert – lösche mit rm (nicht sicher)"
  rm -f "$TARGET"
fi

echo "✅ Datei wurde gelöscht: $TARGET"
