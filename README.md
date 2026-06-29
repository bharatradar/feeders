# BharatRadar Feeders

Public scripts for setting up and managing a BharatRadar ADS-B/MLAT feeder on a Raspberry Pi.

## Quick Start

```bash
curl -Ls https://raw.githubusercontent.com/bharatradar/feeders/main/bharatradar-feeder | sudo bash
```

This auto-detects your SDR, installs readsb + mlat-client, and connects to `feed.bharatradar.com`.

## Scripts

| Script | Purpose |
|--------|---------|
| `bharatradar-feeder` | Main one-liner installer — detects SDR, installs readsb + mlat-client, configures systemd services |
| `feeder-self-register.sh` | Look up your feeder's personalized map URL by UUID |
| `bharatradar-cleanup` | Disk cleanup utility — keeps your Pi from filling up (automatic via systemd timer) |

## Documentation

Full documentation: https://bharatradar.com/docs/get-started/become-a-feeder/
