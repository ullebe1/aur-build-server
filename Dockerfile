FROM archimg/base-devel

USER root

RUN pacman -Syu --noconfirm --noprogressbar --quiet git jq pacutils pacman aria2 devtools expac parallel repose vifm
RUN useradd --create-home build
RUN usermod -g wheel build

# Build aurutils
USER build
WORKDIR /home/build
RUN mkdir -p /home/build/.gnupg/
RUN echo "keyserver-options auto-key-retrieve" >> /home/build/.gnupg/gpg.conf
RUN git clone https://aur.archlinux.org/aurutils.git
WORKDIR aurutils
RUN makepkg

# Install aurtils
USER root
RUN pacman -U *.pkg.tar.xz --noconfirm

# Setup configs
STOPSIGNAL SIGRTMIN+3
ENV container docker
RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/ulrepo" >> /etc/pacman.conf
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "build ALL = NOPASSWD: /usr/sbin/pacsync" >> /etc/sudoers
COPY ulrepo /etc/pacman.d/ulrepo
RUN install -d /var/cache/pacman/ulrepo
RUN chown build /var/cache/pacman/ulrepo

# Copy service for rebuild
COPY ulrepo-build.service /etc/systemd/system/ulrepo-build.service
COPY ulrepo-build.timer /etc/systemd/system/ulrepo-build.timer
RUN systemctl enable ulrepo-build.timer

USER root
CMD ["init"]
