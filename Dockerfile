FROM archlinux/archlinux:base-devel

USER root

RUN pacman -Syu --noconfirm --noprogressbar --quiet base base-devel bash git jq pacutils pacman aria2 devtools expac parallel repose vifm diffstat wget pacman-contrib signify
RUN useradd --create-home build
RUN usermod -g wheel build

# Build aurutils
USER build
WORKDIR /home/build
RUN mkdir -p /home/build/.gnupg/
RUN echo "keyserver-options auto-key-retrieve" >> /home/build/.gnupg/gpg.conf
RUN echo "keyserver ha.pool.sks-keyservers.net" >> /home/build/.gnupg/gpg.conf
RUN git clone https://aur.archlinux.org/aurutils.git
WORKDIR aurutils
RUN makepkg

# Install aurtils
USER root
RUN pacman -U *.pkg.tar.zst --noconfirm

# Set autoretrieve keys when building
RUN mkdir -p /var/lib/aurbuild/x86_64/root/etc/skel/.gnupg/
RUN echo "keyserver-options auto-key-retrieve" >> /var/lib/aurbuild/x86_64/root/etc/skel/.gnupg/gpg.conf
RUN echo "keyserver ha.pool.sks-keyservers.net" >> /var/lib/aurbuild/x86_64/root/etc/skel/.gnupg/gpg.conf

# Setup configs
STOPSIGNAL SIGRTMIN+3
ENV container docker
RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/ulrepo" >> /etc/pacman.conf
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "build ALL = NOPASSWD: /usr/sbin/pacsync" >> /etc/sudoers
COPY ulrepo /etc/pacman.d/ulrepo
RUN cat /usr/share/devtools/pacman-multilib.conf /etc/pacman.d/ulrepo > /etc/aurutils/pacman-ulrepo.conf
RUN echo "MAKEFLAGS=\"-j\$((\$(nproc) - 1))\"" >> /etc/makepkg.conf
RUN install -d /var/cache/pacman/ulrepo
RUN chown build /var/cache/pacman/ulrepo
RUN systemctl enable paccache.timer

# Copy service for rebuild
COPY ulrepo-build.service /etc/systemd/system/ulrepo-build.service
COPY ulrepo-build.timer /etc/systemd/system/ulrepo-build.timer
RUN systemctl enable ulrepo-build.timer
RUN systemctl enable paccache.timer
RUN echo "ForwardToConsole=yes" >> /etc/systemd/journald.conf

USER root
CMD ["init"]
