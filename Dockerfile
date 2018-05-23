FROM archimg/base-devel

USER root

RUN pacman -Syu --noconfirm --noprogressbar --quiet git jq pacutils pacman aria2 devtools expac parallel repose vifm
RUN useradd --create-home build

USER build

# Build aurutils
RUN git clone https://aur.archlinux.org/aurutils.git
RUN cd aurutils && makepkg -si

# Build aurto
RUN git clone https://aur.archlinux.org/aurto.git
RUN cd aurto && makepkg -si
