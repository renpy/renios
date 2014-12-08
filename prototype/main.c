#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <SDL.h>
#include "Python.h"


int start_python(char *argv0) {
	char *bundle = strdup(dirname(argv0));
	char main[1024];
    char *args[] = { "python", NULL };
    FILE *f;

    Py_SetProgramName(argv0);
    Py_SetPythonHome(bundle);
    Py_Initialize();

    snprintf(main, 1024, "%s/base/main.pyo", bundle);
    f = fopen(main, "r");

    if (!f) {
        snprintf(main, 1024, "%s/base/main.py", bundle);
        f = fopen(main, "r");
    }

    printf("running %s\n", main);

    args[0] = main;
    PySys_SetArgv(1, args);

    PyRun_SimpleFileEx(f, main, 1);

    if (PyErr_Occurred() != NULL) {
        PyErr_Print();
        if (Py_FlushLine())
			PyErr_Clear();
        return 1;
    }

    return 0;
}

int
main(int argc, char *argv[])
{
	SDL_Window *window;
	SDL_Surface *surface;

	SDL_Init(SDL_INIT_EVERYTHING);
	window = SDL_CreateWindow("ios window", 0, 0, 800, 600, 0);
	surface = SDL_GetWindowSurface(window);
	SDL_FillRect(surface, NULL, SDL_MapRGB(surface->format, 0, 0x80, 0));
	SDL_UpdateWindowSurface(window);
	SDL_DestroyWindow(window);

	return start_python(argv[0]);
}
