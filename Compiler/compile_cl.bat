@copy "C:\Program Files\Microsoft Visual Studio 8\Common7\IDE\mspdb80.dll" mspdb80.dll
"C:\Program Files\Microsoft Visual Studio 8\VC\bin\"cl.exe  /I"C:\Program Files\Microsoft Visual Studio 8\VC\PlatformSDK\Include" /I"C:\Program Files\Microsoft Visual Studio 8\VC\include" /Zc:forScope  %*  /EHsc /link /LIBPATH:"C:\Program Files\Microsoft Visual Studio 8\VC\lib" /LIBPATH:"C:\Program Files\Microsoft Visual Studio 8\VC\PlatformSDK\lib"
@erase mspdb80.dll
