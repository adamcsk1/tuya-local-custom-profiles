# Custom Tuya Local device profiles + startup restore

A vendor-neutral collection of custom [Tuya Local](https://github.com/make-all/tuya-local) device profiles for [Home Assistant](https://www.home-assistant.io/). Add profiles for any brand in `custom_profiles/`; a single script copies all `*.yaml` files into Tuya Local's `devices/` directory. No script changes are needed when adding more devices.

## Included profiles

| Device | File |
| --- | --- |
| AlecoAir D12/D16 ECO dehumidifier | `alecoair_d12_d16_eco_dehumidifier.yaml` |
| AlecoAir D13 TRADITIO dehumidifier | `alecoair_d13_traditio.yaml` |

These profiles are community-provided and have not been independently schema-validated against every Tuya Local release. Check functionality, especially lock and mode controls, before relying on automations. **Do not commit local keys, individual device IDs, credentials, or private IP addresses.** Tuya product IDs in profiles are shared model identifiers, not per-device credentials.

## Install (Home Assistant OS / Container)

1. Install Tuya Local (`make-all/tuya-local`) and locate the Home Assistant configuration directory (`/config` *inside the HA runtime*).
2. Copy this package's `custom_profiles/` directory and `restore_profiles.sh` to:

   ```text
   /config/tuya-local-custom-profiles/
   ├── custom_profiles/
   │   ├── alecoair_d12_d16_eco_dehumidifier.yaml
   │   └── alecoair_d13_traditio.yaml
   └── restore_profiles.sh
   ```

3. Merge `configuration_snippet.yaml` into `/config/configuration.yaml` (if `shell_command:` already exists, **add the command under the existing key**, don't create a duplicate):

   ```yaml
   shell_command:
     restore_tuya_local_custom_profiles: "sh /config/tuya-local-custom-profiles/restore_profiles.sh"
   ```

4. Add the list item in `automation.yaml` to `/config/automations.yaml`, assuming your `configuration.yaml` includes `automation: !include automations.yaml`. Alternatively create the equivalent startup automation using the Home Assistant UI. Back up `automations.yaml` if it is UI-managed.
5. Check the HA configuration and restart Home Assistant to load the new command and automation.
6. **Run `shell_command.restore_tuya_local_custom_profiles` once manually** in **Developer Tools → Actions**, then restart Home Assistant **again** so Tuya Local can discover the new device types. Select the appropriate profile when adding each device.

If Tuya Local has not been installed, its `devices/` folder will be missing and the script exits with an error. On Core or custom installations, adjust the absolute `/config` paths to the actual configuration directory. The HA runtime needs filesystem write access to `custom_components/tuya_local/devices/` and an available `sh` command.

## Adding other brands later

Put any new Tuya Local-compatible YAML device profile into:

```text
/config/tuya-local-custom-profiles/custom_profiles/<your_device>.yaml
```

Run `shell_command.restore_tuya_local_custom_profiles` in **Developer Tools → Actions**, then restart Home Assistant to load it. The restore script automatically handles every `*.yaml` in that directory, regardless of manufacturer. It **copies changed or missing files only**, does not delete other integration profiles, and does not recurse into subfolders. Use unique filenames to avoid overwriting an existing built-in profile.

## What happens after HACS updates?

HACS may replace files under `/config/custom_components/tuya_local/devices/`. The persistent source directory under `/config/tuya-local-custom-profiles/` is outside that managed integration directory.

On every Home Assistant startup, the automation runs the restore script and copies any missing or changed YAML files back. **Timing limitation:** this runs *after* Home Assistant has started initializing integrations. If Tuya Local fails to load a missing profile first, a **second restart or successful integration reload may be required**. This is a restore-on-start strategy, not a pre-start hook or a zero-downtime guarantee. If you require the profiles to be present before the first integration load, arrange a host/container pre-start copy instead.

For a more durable upstream solution, consider submitting verified device profiles to Tuya Local itself.

## Files

- `custom_profiles/*.yaml`: persistent, vendor-independent profile collection (initially AlecoAir).
- `restore_profiles.sh`: generic, idempotent shell restore script.
- `configuration_snippet.yaml`: Home Assistant `shell_command` configuration.
- `automation.yaml`: Home Assistant startup automation.
