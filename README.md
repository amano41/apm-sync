APM Sync
========

A wrapper script for apm that provides better functionality to manage stars and packages. This script allows you to skip already installed packages when installing starred packages, while uninstalling non-starred packages. You can also star installed packages only if they are not starred, or unstar packages if they are not locally installed.

## Sync

### Remote to Local

Update local environment.
Install missing starred packages and uninstall non-starred packages.

```
apm-sync.sh pull
```

### Local to Remote

Update stars on atom.io.
Star all installed packages and unstar non-installed packages.

```
apm-sync.sh push
```

## Commands

### Install

Install starred packages only if they aren't already installed.

```
apm-sync.sh install
```

### Uninstall

Uninstall installed but not starred packages.

```
apm-sync.sh uninstall
```

### Star

Star installed packages only if they aren't already starred.

```
apm-sync.sh star
```

### Unstar

Unstar starred but not installed packages

```
apm-sync.sh unstar
```
