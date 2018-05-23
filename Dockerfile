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
CMD ["init"]
