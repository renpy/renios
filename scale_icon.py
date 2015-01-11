#!/usr/bin/env python

import pygame_sdl2
pygame_sdl2.import_as_pygame()

import pygame
import argparse

def smooth_down(src, size):
    while True:
        w, h = src.get_size()

        if w <= size * 2:
            break

        src = pygame.transform.smoothscale(src, (w // 2, w // 2))

    return pygame.transform.smoothscale(src, (size, size))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("dest")
    args = ap.parse_args()


    src = pygame.image.load(args.source)

    for size in [ 29, 40, 60, 76 ]:
        for scale in [ 1, 2, 3 ]:
            img = smooth_down(src, size * scale)
            pygame.image.save(img, "{}-{}@{}.png".format(args.dest, size, scale))


if __name__ == "__main__":
    main()

