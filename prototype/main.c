#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <SDL.h>
#include <SDL_image.h>
#include "Python.h"

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

    PyRun_SimpleString("import iossupport");
    PyRun_SimpleFileEx(f, main, 1);

    if (PyErr_Occurred() != NULL) {
        PyErr_Print();
        if (Py_FlushLine())
			PyErr_Clear();
        return 1;
    }

    return 0;
}


int main(int argc, char *argv[]) {
	return start_python(argv[0]);
}
