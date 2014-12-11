#include <iostream>
#include <boost/function.hpp>
#include <boost/extension/shared_library.hpp>

using namespace std;

int main(int argc, char* argv[])
{
	cout << "Hello World!" << endl;

	const string dll_path = "../../../lib/libccas.dll";

	boost::extensions::shared_library lib(dll_path, true);
	if (lib.open()) 
	{
		cout << "Calling debug_main()" << endl;

		boost::function<void (void)> debug_main(lib.get<void>("debug_main"));
		debug_main();
	}
	else
	{
		cout << "Library failed to open: " << dll_path << std::endl;
	}

	getchar();
	return 0;
}
