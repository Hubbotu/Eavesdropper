# Copyright The Eavesdropper Authors
# SPDX-License-Identifier: GPL-3.0-or-later

libdir := "Libs"
packager_url := "https://raw.githubusercontent.com/BigWigsMods/packager/eca4e176cd6ae5404c66bef5c11c08200a458400/release.sh"
schema_url := "https://raw.githubusercontent.com/Gethe/wow-ui-source/refs/heads/live/Interface/AddOns/Blizzard_SharedXML/UI.xsd"
schema_file := "Types/UI.xsd"

# Build the distributable addon package.
all: dist

# Run the full pre-commit check suite.
check:
    pre-commit run --all-files

# Build a distributable package using the packager script.
dist:
    curl -s {{ packager_url }} | bash -s -- -d

# Download and install packaged libraries.
libs:
    curl -s {{ packager_url }} | bash -s -- -cdlz
    cp -aTv .release/Eavesdropper/{{ libdir }} {{ libdir }}

# Refresh the vendored Blizzard UI schema.
schema:
    curl -s {{ schema_url }} -o {{ schema_file }}
