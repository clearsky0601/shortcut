#!/bin/bash

JSON_FILE="$1"
NAME="$2"

if [ -z "$JSON_FILE" ] || [ -z "$NAME" ]; then
    echo "Usage: $0 <json_file> <shortcut_name>"
    exit 1
fi

DB="$HOME/Library/Shortcuts/Shortcuts.sqlite"
TMP_BIN="/tmp/shortcut_actions_$$.bin"

plutil -convert binary1 "$JSON_FILE" -o "$TMP_BIN"

sqlite3 "$DB" <<EOF
BEGIN TRANSACTION;

INSERT OR REPLACE INTO ZSHORTCUT (
    ZNAME, 
    ZMODIFICATIONDATE, 
    ZCREATIONDATE,
    ZACTIONCOUNT,
    ZSHOWINSEARCH
) VALUES (
    '$NAME',
    $(date +%s),
    $(date +%s),
    1,
    1
);

DELETE FROM ZSHORTCUTACTIONS WHERE ZSHORTCUT = (SELECT Z_PK FROM ZSHORTCUT WHERE ZNAME = '$NAME');

INSERT INTO ZSHORTCUTACTIONS (ZSHORTCUT, ZDATA)
VALUES (
    (SELECT Z_PK FROM ZSHORTCUT WHERE ZNAME = '$NAME'),
    readfile('$TMP_BIN')
);

COMMIT;
EOF

rm "$TMP_BIN"
echo "✓ 已导入: $NAME"
echo "请重启"快捷指令"应用以查看更改"

