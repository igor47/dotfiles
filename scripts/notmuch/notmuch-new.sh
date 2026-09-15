#!/bin/bash

echo "looking for new mail to index..."
notmuch new

echo "updating tags..."
notmuch tag --batch << EOF
+spam -inbox -- folder:spam
+archive -inbox -- folder:archive
+sent -inbox -- folder:sent-mail
-spam -- tag:spam NOT folder:spam
EOF

echo "reporting mail stats..."
# venv made with: python3.8 -m venv .venv && .venv/bin/pip install -e .
"$HOME/repos/mailograf/.venv/bin/mailograf" report
