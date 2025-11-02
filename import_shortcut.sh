#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <json_file> <shortcut_name>"
    exit 1
fi

JSON_FILE="$1"
NAME="$2"
DB="$HOME/Library/Shortcuts/Shortcuts.sqlite"

# Convert JSON to binary plist
plutil -convert binary1 "$JSON_FILE" -o /tmp/tmp_actions.bin

# Insert into database
sqlite3 "$DB" << EOF
INSERT INTO ZSHORTCUT (ZNAME, ZMODIFICATIONDATE, ZCREATIONDATE)
VALUES ('$NAME', $(date +%s), $(date +%s));

INSERT INTO ZSHORTCUTACTIONS (ZSHORTCUT, ZDATA)
VALUES ((SELECT Z_PK FROM ZSHORTCUT WHERE ZNAME = '$NAME'), readfile('/tmp/tmp_actions.bin'));
EOF

rm /tmp/tmp_actions.bin
echo "Imported: $NAME"

