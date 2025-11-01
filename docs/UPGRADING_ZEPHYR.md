# Oppgradering av Zephyr RTOS

Denne guiden forklarar korleis du held Zephyr RTOS oppdatert i zephyr-meta prosjekt.

## 📊 Sjekk noverande versjon

```bash
./scripts/check-zephyr-version.sh
```

**Output:**
```
=== Zephyr Version Check ===

Template:
  v3.7.1

Board prosjekt:
  arduino-nano: v3.7.1 (installed: v3.7.1)
  nrf52840: v3.7.1 (installed: v3.7.1)

Latest Zephyr releases:
  Visit: https://github.com/zephyrproject-rtos/zephyr/releases
  Current stable: v4.2.1 (October 2024)
  LTS: v3.7.1 (July 2024)
```

## 🔍 Finn nye Zephyr-versjonar

### Manuelt:
- GitHub: https://github.com/zephyrproject-rtos/zephyr/releases
- Zephyr docs: https://docs.zephyrproject.org/latest/releases/index.html

### Automatisk (via gh CLI):
```bash
gh release list --repo zephyrproject-rtos/zephyr --limit 5
```

## 🔄 Oppdateringsstrategiar

### 1. **LTS (Long Term Support)** - Anbefalt for produksjon
- Støtta i 2-3 år
- Berre bugfixes og security updates
- Noverande LTS: **v3.7.x**

### 2. **Stable Release** - Anbefalt for utvikling
- Nye features
- Støtta til neste major release
- Noverande stable: **v4.2.1**

### 3. **Bleeding Edge** - Ikkje anbefalt
- `revision: main`
- Ustabil, daglige endringar

## 📦 Oppgradering

### Steg 1: Test på eit enkelt prosjekt først

```bash
# Rediger west.yml
cd boards/arduino-nano
nano west.yml  # Endre revision: v3.7.1 til v4.2.1

# Oppdater Zephyr
west update

# Test bygg
west build -p auto -b arduino_nano_33_iot app

# Sjekk warnings og errors
```

### Steg 2: Oppdater template (for nye prosjekt)

```bash
./scripts/update-zephyr-version.sh v4.2.1 --template-only
```

### Steg 3: Oppdater alle eksisterande prosjekt

```bash
./scripts/update-zephyr-version.sh v4.2.1 --all
```

Dette vil:
1. ✅ Oppdatere `templates/west.yml`
2. ✅ Oppdatere `boards/*/west.yml`
3. ✅ Køyre `west update` i alle prosjekt

### Steg 4: Test alle prosjekt

```bash
./scripts/build-all.sh
```

### Steg 5: Commit og push

```bash
# Meta-repo
git add templates/west.yml
git commit -m "Update Zephyr template to v4.2.1"
git push

# Kvart board-prosjekt (submodule)
cd boards/arduino-nano
git add west.yml
git commit -m "Update Zephyr to v4.2.1"
git push
cd ../..

cd boards/nrf52840
git add west.yml
git commit -m "Update Zephyr to v4.2.1"
git push
cd ../..

# Oppdater submodule-referanser i meta-repo
git submodule update --remote --merge
git add boards/
git commit -m "Update submodules to latest (Zephyr v4.2.1)"
git push
```

## 🚨 Breaking Changes og Migration

### v3.7 → v4.0 Major Changes

**API-endringar:**
- Nye logging API-er
- Device tree binding changes
- Deprecated APIs fjerna

**Sjekk migration guide:**
- https://docs.zephyrproject.org/latest/releases/migration-guide-4.0.html

### Vanlige problem

#### 1. **Build errors etter oppgradering**

```bash
# Clean build
west build -t clean
rm -rf build/
west build -p auto -b <board> app
```

#### 2. **Deprecated API warnings**

Sjå Zephyr migration guide for kvar versjon:
- v3.7 → v4.0: https://docs.zephyrproject.org/latest/releases/migration-guide-4.0.html
- v4.0 → v4.1: https://docs.zephyrproject.org/latest/releases/migration-guide-4.1.html

#### 3. **Board support endra**

Nokre boards kan ha endra namn eller blitt flytta. Sjekk:
```bash
west boards | grep <ditt_board>
```

#### 4. **Kconfig options endra**

```bash
# Sjekk kva options som ikkje lenger finst
west build -t menuconfig
```

## 📋 Checklist for Oppgradering

- [ ] Sjekk Zephyr release notes
- [ ] Les migration guide
- [ ] Backup prosjekt (git commit)
- [ ] Test på eit prosjekt først
- [ ] Oppdater template
- [ ] Oppdater alle prosjekt
- [ ] Test bygg alle prosjekt
- [ ] Test flash til hardware
- [ ] Oppdater dokumentasjon
- [ ] Commit og push

## 🔔 Automatisk varsling

### GitHub Watch
Sett opp notifications for nye Zephyr releases:
1. Gå til https://github.com/zephyrproject-rtos/zephyr
2. Klikk "Watch" → "Custom" → "Releases"

### RSS Feed
```
https://github.com/zephyrproject-rtos/zephyr/releases.atom
```

### Slack/Discord Webhook (valgfritt)
Bruk GitHub webhooks til å få beskjed om nye releases.

## 📚 Versjonsstrategi

### Anbefaling for ulike miljø

| Miljø | Versjonsstrategi | Eksempel |
|-------|------------------|----------|
| **Produksjon** | LTS, fast versjon | `v3.7.1` |
| **Staging** | Latest stable | `v4.2.1` |
| **Utvikling** | Latest stable eller branch | `v4.2.1` |
| **Eksperiment** | Main branch | `main` |

### Prosjekt-spesifikke versjonar

Ulike prosjekt kan bruke ulike versjonar:
```
boards/arduino-nano/west.yml  → v3.7.1 (LTS, produksjon)
boards/nrf52840/west.yml      → v4.2.1 (ny utvikling)
boards/esp32/west.yml         → main (eksperiment)
```

## 🛡️ Rollback

Hvis oppgraderinga feiler:

```bash
# Gå tilbake til tidlegare versjon
cd boards/<project>
git checkout HEAD~1 west.yml
west update

# Eller manuelt rediger west.yml
nano west.yml  # Endre tilbake til gammal versjon
west update
```

## 📖 Ressursar

- [Zephyr Releases](https://github.com/zephyrproject-rtos/zephyr/releases)
- [Zephyr Documentation](https://docs.zephyrproject.org/)
- [Migration Guides](https://docs.zephyrproject.org/latest/releases/index.html)
- [West Tool](https://docs.zephyrproject.org/latest/develop/west/index.html)
- [Zephyr Mailing List](https://lists.zephyrproject.org/)
