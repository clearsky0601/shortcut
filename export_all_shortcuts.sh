#!/bin/bash

DB="$HOME/Library/Shortcuts/Shortcuts.sqlite"
OUTPUT_DIR="$PWD/exported_shortcuts"

mkdir -p "$OUTPUT_DIR"

sqlite3 "$DB" "SELECT Z_PK, ZNAME FROM ZSHORTCUT WHERE ZNAME IS NOT NULL;" | while IFS='|' read -r pk name; do
    safe_name=$(echo "$name" | tr '/' '_' | tr ' ' '_')
    sqlite3 "$DB" "SELECT hex(ZDATA) FROM ZSHORTCUTACTIONS WHERE Z_PK = $pk;" | xxd -r -p > "/tmp/tmp_$pk.bin"
    plutil -convert json "/tmp/tmp_$pk.bin" -o "$OUTPUT_DIR/${safe_name}.json" 2>/dev/null
    rm "/tmp/tmp_$pk.bin"
    echo "Exported: $name -> ${safe_name}.json"
done

echo "All shortcuts exported to: $OUTPUT_DIR"

