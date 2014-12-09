import iosembed
iosembed.close_window()

import pygame_sdl2 as pygame

pygame.init()

screen = pygame.display.set_mode((0, 0))
screen.fill((0xaa, 0xee, 0xbb, 0xff))

import os
base = os.path.dirname(__file__)
print "base = ", base

img = pygame.image.load(os.path.join(base, "image.png"))

sw, sh = screen.get_size()
iw, ih = img.get_size()

screen.blit(img, ((sw-iw) / 2, (sh-ih)/2))
pygame.display.update()

while True:
    ev = pygame.event.wait()
    print ev
    