#include <iostream>
#include "libuv-v1.0.1/include/uv.h"
#include <boost/function.hpp>
#include <boost/extension/shared_library.hpp>

using namespace std;

typedef void(*debug_main_func)();

int main(int argc, char* argv[])
{
	cout << "Hello World!" << endl;

	const string dll_libuv = "C:/Users/rcnlee/AppData/Local/Julia-0.3.2/bin/libuv-11.dll";
	boost::extensions::shared_library libuv(dll_libuv, true);

	if (!libuv.open())
	{
		cout << "Library failed to open: " << dll_libuv << endl;
		getchar();
		return 0;
	}

	cout << "libuv open:" << endl;
	boost::function<int (const char*, uv_lib_t*)> uv_dlopen(libuv.get<int, const char*, uv_lib_t*>("uv_dlopen"));
	boost::function<int (uv_lib_t*, const char*, void**)> uv_dlsym(libuv.get<int, uv_lib_t*, const char*, void**>("uv_dlsym"));
	boost::function<void (uv_lib_t*)> uv_dlclose(libuv.get<void, uv_lib_t*>("uv_dlclose"));
	boost::function<const char* (const uv_lib_t*)> uv_dlerror(libuv.get<const char*, const uv_lib_t*>("uv_dlerror"));

	const char* dll_libccas = "../../../lib/libccas.dll";

	uv_lib_t* libccas = (uv_lib_t*)malloc(sizeof(uv_lib_t));
	if (uv_dlopen(dll_libccas, libccas))
	{
		cout << "Library failed to open: " << dll_libccas << endl;
		getchar();
		return 0;
	}

	debug_main_func debug_main;
	uv_dlsym(libccas, "debug_main", (void**)&debug_main);

	debug_main();

	getchar();
	return 0;
}
