#######################
Preprocessor directives
#######################

Simba 2.0 has much improved preprocessor directives allowing constant expressions and useful macros.

----

Basic expressions

.. code-block::

  {$DEFINE TEST}

  const XYZ = 100;

  begin
    {$IF XYZ = 100}
    WriteLn('XYZ = 100');
    {$ENDIF}

    {$IF XYZ*2+1 > 200}
    WriteLn('XYZ*2 > 200');
    {$ENDIF}  

    {$IF DECLARED(XYZ) and DEFINED(TEST)}
    WriteLn('True');
    {$ELSE}
    WriteLn('False');
    {$ENDIF}

    {$UNDEF TEST}

    {$IF DECLARED(XYZ) and DEFINED(TEST)}
    WriteLn('True');
    {$ELSE}
    WriteLn('False');
    {$ENDIF} 
  end;

----

File

.. code-block::

  {$IF FILEEXISTS(Data\settings.ini)}
  WriteLn('Settings file exists');
  {$ELSE}
  WriteLn('Settings file does not exist');
  {$ENDIF} 

----

Plugins

.. code-block::

  {$IF FINDLIB(libremoteinput)}
    {$loadlib libremoteinput}
  {$ELSE}
    WriteLn('Cannot find libremoteinput!);
  {$ENDIF}

  {$IF LOADEDLIB(libremoteinput)}
    WriteLn('libremoteinput is loaded');
  {$ELSE}
    WriteLn('libremoteinput is *not* loaded');
  {$ENDIF}

----

Macros which are inserted constants at compile time.

.. code-block::

  procedure Test;
  begin
    WriteLn('Func=', {$MACRO FUNC}); // current function name
  end;

  begin
    Test();
  end;

.. code-block::

  begin
    WriteLn {$MACRO LINE}; // The line number
    WriteLn {$MACRO TICKCOUNT}; // GetTickCount
    WriteLn {$MACRO NOW}; // TDateTime.Now()
    WriteLn {$MACRO FILE}; // current file
    WriteLn {$MACRO DIR}; // directory the current file is in
    WriteLn {$MACRO ENV(USERPROFILE)}; // environment variable
    WriteLn {$MACRO INCLUDEDFILES}; // all included files (as a TStringArray)

    WriteLn {$MACRO LOADEDLIB(libremoteinput)}; // if lib "libremoteinput" is loaded, return the filename of the lib.
    WriteLn {$MACRO LOADEDLIBS}; // all loaded libs (as a TStringArray)
    WriteLn {$MACRO FINDLIB(libremoteinput)}; // try to find a lib, returning the path
  end; 