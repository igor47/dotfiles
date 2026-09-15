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
cd "/home/igor47/repos/mailograf"
/home/igor47/.asdf/installs/python/3.8.9/bin/poetry run mailograf report
