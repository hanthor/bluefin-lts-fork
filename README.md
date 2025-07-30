# Bluefin LTS
*Achillobator giganticus*

[![Build Bluefin LTS](https://github.com/ublue-os/bluefin-lts/actions/workflows/build-regular.yml/badge.svg)](https://github.com/ublue-os/bluefin-lts/actions/workflows/build-regular.yml)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/13d42ded3cf54250a71ad05aca7d5961)](https://app.codacy.com/gh/ublue-os/bluefin-lts/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/10098/badge)](https://www.bestpractices.dev/projects/10098)
[![Bluefin LTS on ArtifactHub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/bluefin)](https://artifacthub.io/packages/container/bluefin/bluefin)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ublue-os/bluefin-lts)

Larger, more lethal [Bluefin](https://projectbluefin.io). `bluefin:lts` is built on CentOS Stream10.

![image](https://github.com/user-attachments/assets/2e160934-44e6-4aee-b2b8-accb3bcf0a41)

## Instructions

Check [the documentation](https://docs.projectbluefin.io/lts) for the latest instructions.

## ISO Builds

This repository now supports building bootable ISO images using GitHub Actions:

- **Manual ISO Build**: Go to Actions → "Build Bluefin LTS ISO" → "Run workflow"
- **Scheduled Build**: ISOs are automatically built every Tuesday at 2am UTC
- **Cloudflare Upload**: Built ISOs are automatically uploaded to Cloudflare R2 storage

The ISO configuration is defined in `iso.toml` and uses the `osbuild/bootc-image-builder-action`.

## Metrics

![Alt](https://repobeats.axiom.co/api/embed/3e29c59ccd003fe1939ce0bdfccdee2b14203541.svg "Repobeats analytics image")
