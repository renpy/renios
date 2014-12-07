#include <stdio.h>
#include <SDL.h>
#include "Python.h"

int start_python() {
    printf("In start_python.\n");
    
    char *cwd = getcwd(NULL, 0);
    printf("CWD is %s.\n", cwd);

    Py_SetProgramName(cwd);
    Py_SetPythonHome(cwd);
    Py_Initialize();

    return 0;
}
//
//
////    const char *launcherFilename = "launcher";
////
////    char *launcherRelativePath = "/launcher.py";
////    char *launcherAbsolutePath = malloc(strlen(scriptsPath) + strlen(launcherRelativePath) + 1);
////    strncpy(launcherAbsolutePath, scriptsPath, strlen(scriptsPath) + 1);
////    strncat(launcherAbsolutePath, launcherRelativePath, strlen(launcherRelativePath) + 1);
////    printf("launcherAbsolutePath: %s", launcherAbsolutePath);
////
////
////    FILE *launcherFile = fopen(launcherAbsolutePath, "r");
////    if (launcherFile == NULL) {
////        printf("Couldn't open script file.");
////    }
//
//    //    setenv("RENPY_SCALE_FACTOR", "2", 1);
//
////    setenv("RENPY_RENDERER", "gl", 1);
////    setenv("RENPY_GL_ENVIRON", "shader_es", 1);
////    setenv("RENPY_GL_RTT", "fbo", 1);
////
////    setenv("RENPY_VARIANT", RENIOS_ScreenVariant(), 1);
//
//    Py_SetProgramName(cwd);
//    Py_SetPythonHome(cwd);
//    Py_Initialize();
//
//    char **argv = { "launcher" };
//    PySys_SetArgv(1, argv);
//
//    PyEval_InitThreads();
//
//    PyRun_SimpleString("print 'Python says hello.'");
//
//    Py_Finalize();
//
//    free(cwd);
//    return 0;
//}


int
main(int argc, char *argv[])
{
	SDL_Window *window;
	SDL_Surface *surface;

	printf("Hello, world.\n");
	printf("How are we doing today?\n");

	SDL_Init(SDL_INIT_EVERYTHING);
	window = SDL_CreateWindow("ios window", 0, 0, 800, 600, 0);
	surface = SDL_GetWindowSurface(window);
	SDL_FillRect(surface, NULL, SDL_MapRGB(surface->format, 0, 0x80, 0));
	SDL_UpdateWindowSurface(window);

	printf("window = %p, surface = %p\n", window, surface);
	printf("w = %d, h = %d\n", surface->w, surface->h);

	return start_python();
}
