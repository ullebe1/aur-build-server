# Buildserver for a custom repo of AUR packages for Arch archlinux
Some manual setup still required.

Add packages with: 
```bash
docker exec --tty -u build ulrepo-stuff_aur-builder_1 aur sync -d ulrepo --root /var/cache/pacman/ulrepo -ncT --noview <package-name(s)>
```

Remove packages with:
```
docker exec --tty -u build ulrepo-stuff_aur-builder_1 repo-remove /var/cache/pacman/ulrepo/ulrepo.db.tar <package-name(s)>
```

## Requirements
The host must run kernel version 3.15 or higher, see: https://bbs.archlinux.org/viewtopic.php?id=232682
