FROM archimg/base-devel

USER root

RUN pacman -Syu --noconfirm --noprogressbar --quiet git jq pacutils pacman aria2 devtools expac parallel repose vifm
RUN useradd --create-home build

USER build

# Build aurutils
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/aurutils.git
WORKDIR aurutils
RUN makepkg -si

# Build aurto
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/aurto.git
WORKDIR aurto
RUN makepkg -si
