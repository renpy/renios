#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <SDL.h>
#include <SDL_image.h>
#include "Python.h"

SDL_Window *window = NULL;;

static PyObject *close_window(PyObject *self, PyObject *args) {
    if (!PyArg_ParseTuple(args, "")) {
        return NULL;
    }

    if (window) {
		SDL_DestroyWindow(window);
		window = NULL;
    }

    Py_RETURN_NONE;
}

static PyMethodDef iosembed_methods[] = {
	{"close_window", close_window, METH_VARARGS, "Close the initial window."},
    {NULL, NULL, 0, NULL}
};

static PyMODINIT_FUNC initiosembed(void) {
    (void) Py_InitModule("iosembed", iosembed_methods);
}

void renios_extend_inittab(void);

static int start_python(char *argv0) {
	char *bundle = strdup(dirname(argv0));
	char main[1024];
    char pythonpath[1024];
	char *args[] = { "python", NULL };
    FILE *f;

    /* This would be how we would initialize the python modules if
     * python supported builtin submodules inside a non-built-in package.
     *
     * Since it doesn't seem to, this just serves to ensure that the various
     * module init functions exist in the final linked binary, so dlysym can
     * find them.
     */
    if (getenv("THIS SHOULD NEVER BE SET")) {
    	renios_extend_inittab();
    }

    snprintf(pythonpath, 1024, "%s/ios-python", bundle);

    // setenv("PYTHONVERBOSE", "2", 1);
    setenv("PYTHONPATH", pythonpath, 1);
    setenv("PYTHONOPTIMIZE", "2", 1);
    setenv("PYTHONDONTWRITEBYTECODE", "1", 1);
    setenv("RENPY_IOS", "1", 1);
    setenv("PYGAME_IOS", "1", 1);
    setenv("RENPY_RENDERER", "gl", 1);

    PyImport_AppendInittab("iosembed", initiosembed);

    if (getenv("THIS SHOULD NEVER BE SET")) {
    	renios_extend_inittab();
    }

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

extern C_LINKAGE void SDL_premain(int argc, char **argv);

void SDL_premain(int argc, char **argv) {
	SDL_Surface *surface;
	SDL_RWops *rwops = NULL;
	SDL_Surface *presplash = NULL;
	SDL_Surface *presplash2 = NULL;
	SDL_Rect pos;
	Uint32 pixel;

	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) < 0) {
		printf("Error in init: %s\n", SDL_GetError());
		return;
	}

	IMG_Init(IMG_INIT_JPG|IMG_INIT_PNG);

	window = SDL_CreateWindow("pygame_sdl2 starting...", 0, 0, 0, 0, SDL_WINDOW_SHOWN);
	surface = SDL_GetWindowSurface(window);
	pixel = SDL_MapRGB(surface->format, 128, 128, 128);

	rwops = SDL_RWFromFile("base/ios-presplash.png", "r");

	if (!rwops) {
		rwops = SDL_RWFromFile("base/ios-presplash.jpg", "r");
	}

	if (!rwops) {
		rwops = SDL_RWFromFile("ios-presplash.png", "r");
	}

	if (!rwops) goto done;

	presplash = IMG_Load_RW(rwops, 1);
	if (!presplash) goto done;

	presplash2 = SDL_ConvertSurfaceFormat(presplash, SDL_PIXELFORMAT_RGB888, 0);
	Uint8 *pp = (Uint8 *) presplash2->pixels;

#if SDL_BYTEORDER == SDL_LIL_ENDIAN
	pixel = SDL_MapRGB(surface->format, pp[2], pp[1], pp[0]);
#else
	pixel = SDL_MapRGB(surface->format, pp[0], pp[1], pp[2]);
#endif

	SDL_FreeSurface(presplash2);

done:

	SDL_FillRect(surface, NULL, pixel);

	if (presplash) {
		pos.x = (surface->w - presplash->w) / 2;
		pos.y = (surface->h - presplash->h) / 2;
		SDL_BlitSurface(presplash, NULL, surface, &pos);
		SDL_FreeSurface(presplash);
	}

	SDL_UpdateWindowSurface(window);
	SDL_PumpEvents();

	SDL_GL_MakeCurrent(NULL, NULL);
}


int main(int argc, char *argv[]) {
	return start_python(argv[0]);
}
