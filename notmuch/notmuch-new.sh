#!/bin/bash

notmuch new
notmuch tag --batch << EOF
+spam -inbox -- folder:spam
+archive -inbox -- folder:archive
+sent -inbox -- folder:sent-mail
-inbox -- tag:inbox NOT (path:cur OR path:new)
EOF
