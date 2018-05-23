FROM archimg/base-devel

USER root

RUN pacman -Syu --noconfirm --noprogressbar --quiet git jq pacutils pacman aria2 devtools expac parallel repose vifm
RUN useradd --create-home build

# Build aurutils
USER build
RUN gpg --recv-keys 6BC26A17B9B7018A
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/aurutils.git
WORKDIR aurutils
RUN makepkg

# Install aurtils
USER root
RUN pacman -U *.pkg.tar.xz --noconfirm


# Build aurto
USER build
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/aurto.git
WORKDIR aurto
RUN makepkg

# Install aurto
USER root
RUN pacman -U *.pkg.tar.xz --noconfirm

STOPSIGNAL SIGRTMIN+3
ENV container docker
RUN systemctl enable update-aurto.timer
RUN systemctl enable check-aurto-git-trigger.timer
RUN echo "build" > /lib/aurto/user
RUN echo "Include = /etc/pacman.d/aurto" >> /etc/pacman.conf
COPY aurto /etc/pacman.d/aurto
RUN install -d /var/cache/pacman/aurto -o build

USER build
RUN repo-add /var/cache/pacman/aurto/aurto.db.tar

CMD ["init"]
