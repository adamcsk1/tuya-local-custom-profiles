#!/bin/sh
# Copy any custom Tuya Local device profiles into the integration directory.
set -eu
SOURCE="/config/tuya-local-custom-profiles/custom_profiles"
TARGET="/config/custom_components/tuya_local/devices"

if [ ! -d "$SOURCE" ]; then
  echo "Source directory missing: $SOURCE" >&2
  exit 1
fi
if [ ! -d "$TARGET" ]; then
  echo "Tuya Local devices directory missing: $TARGET" >&2
  exit 1
fi

found=0
changed=0
for file in "$SOURCE"/*.yaml; do
  [ -f "$file" ] || continue
  found=1
  name=${file##*/}
  if [ ! -f "$TARGET/$name" ] || ! cmp -s "$file" "$TARGET/$name"; then
    cp "$file" "$TARGET/$name"
    echo "Installed/updated: $name"
    changed=1
  fi
done
[ "$found" -eq 1 ] || echo "No YAML profiles found in $SOURCE"
[ "$changed" -eq 1 ] || echo "All custom Tuya Local profiles already present and identical"
