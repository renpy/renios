#!/usr/bin/env python

import pygame_sdl2
pygame_sdl2.import_as_pygame()

import pygame
import argparse

sizes = [
    (1242, 2208),
    (750, 1334),
    (2208, 1242),
    (640, 960),
    (640, 1136),
    (800, 600),
    (768, 1024),
    (1536, 2048),
    (1024, 768),
    (2048, 1536),
    ]

def scale(src, size):
    w, h = size
    sw, sh = src.get_size()

    factor = min(1.0 * w / sw, 1.0 * h / sh)

    tw = int(sw * factor)
    th = int(sh * factor)

    src = pygame.transform.smoothscale(src, (tw, th))

    rv = pygame.Surface(size)
    rv.fill((0, 0, 0, 255))
    rv.blit(src, ( (w - tw) / 2, (h - th) / 2 ))

    return rv


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("dest")
    args = ap.parse_args()


    src = pygame.image.load(args.source)

    for i in sizes:
        img = scale(src, i)
        pygame.image.save(img, "{}-{}x{}.png".format(args.dest, i[0], i[1]))


if __name__ == "__main__":
    main()

