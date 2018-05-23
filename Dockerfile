FROM nubs/arch-build

USER root

#RUN pacman --sync --noconfirm --noprogressbar --quiet php

USER build

# Build aurutils
RUN git clone https://aur.archlinux.org/aurutils.git
RUN cd aurutils
RUN makepkg -si
RUN cd

# Build aurto
RUN git clone https://aur.archlinux.org/aurto.git
RUN cd aurto
RUN makepkg -si
