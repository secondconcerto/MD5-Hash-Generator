#include <Windows.h>
#include <tchar.h>
#include <string>
#include <iostream>
#include <time.h>
#include <iomanip>
#include <ctime>
#include <ratio>
#include <chrono>
#pragma warning(disable : 4996)

using namespace std;
typedef unsigned char uint1;
typedef void (_stdcall* _MD5)(uint1[], char*, int);

int _tmain(int argc, _TCHAR* argv[])
{
	HINSTANCE mojadll = LoadLibraryA("LibraryDll");
	_MD5 proc = (_MD5)GetProcAddress(mojadll, "_MD5");
	
	string buffer;
	uint1 digest[16];
	std::cout << "Put your message below: " << std::endl ;
	getline(cin, buffer);
	char* cstr = new char[buffer.length() + 1];
	strcpy(cstr, buffer.c_str());
	unsigned int len = strlen(cstr);
	
	auto begin = chrono::high_resolution_clock::now();
	
	proc(digest, cstr, len);
	
	auto end = chrono::high_resolution_clock::now();
	
	cout << endl;
	cout << "Time of execution: "<< chrono::duration_cast<chrono::nanoseconds>(end - begin).count() << "ns" << endl;

	
	unsigned int i;
	cout << endl;
	cout << "Hashed message: " << endl;
	for (i = 0; i < 16; i++)
		printf("%02x", digest[i]);
	cout << endl;

	return 0;
}

