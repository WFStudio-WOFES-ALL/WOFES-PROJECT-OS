name: Build WOFES OS

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 60
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y debootstrap squashfs-tools xorriso \
            isolinux grub-pc-bin grub-efi-amd64-bin mtools

      - name: Build ISO
        run: |
          chmod +x build.sh
          ./build.sh

      - name: Upload ISO
        uses: actions/upload-artifact@v4
        with:
          name: wofes-os
          path: wofes-os.iso
          retention-days: 7
          compression-level: 0
