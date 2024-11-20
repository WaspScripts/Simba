unit simba.import_debugimage;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base, simba.script, simba.image;

procedure ImportDebugImage(Script: TSimbaScript);

implementation

uses
  lptypes;

(*
Debug Image
===========
| The debug image is a simba sided window which can be drawn on to visually debug.
| As the window is simba sided the image will remain after the script terminates.
*)

(*
Show
----
```
procedure Show(Matrix: TIntegerMatrix);
```
*)

(*
Show
----
```
procedure Show(Matrix: TSingleMatrix; ColorMapID: Integer = 0);
```
*)

(*
Show
----
```
procedure Show(Boxes: TBoxArray; Filled: Boolean = False);
```
*)

(*
Show
----
```
procedure Show(Box: TBox; Filled: Boolean = False);
```
*)

(*
Show
----
```
procedure Show(Quads: TQuadArray; Filled: Boolean = False);
```
*)

(*
Show
----
```
procedure Show(Quad: TQuad; Filled: Boolean = False);
```
*)

(*
Show
----
```
procedure Show(TPA: TPointArray; Color: Integer = $0000FF);
```
*)

(*
Show
----
```
procedure Show(ATPA: T2DPointArray);
```
*)

(*
ShowOnClient
------------
```
procedure ShowOnClient(Boxes: TBoxArray; Filled: Boolean = False);
```
*)

(*
ShowOnClient
------------
```
procedure ShowOnClient(Box: TBox; Filled: Boolean = False);
```
*)

(*
ShowOnClient
------------
```
procedure ShowOnClient(Quads: TQuadArray; Filled: Boolean = False);
```
*)

(*
ShowOnClient
------------
```
procedure ShowOnClient(Quad: TQuad; Filled: Boolean = False);
```
*)

(*
ShowOnClient
------------
```
procedure ShowOnClient(TPA: TPointArray);
```
*)

(*
ShowOnClient
------------
```
procedure ShowOnClient(ATPA: T2DPointArray);
```
*)


(*
DebugImageMaxSize
-----------------
```
procedure DebugImageMaxSize(MaxWidth, MaxHeight: Integer);
```
*)
procedure _LapeDebugImage_MaxSize(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with TSimbaScript(Params^[0]) do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_SetMaxSize(PInteger(Params^[1])^, PInteger(Params^[2])^);
  end;
end;

(*
DebugImageShow
--------------
```
procedure DebugImageShow(Image: TImage; EnsureVisible: Boolean = True);
```
*)
procedure _LapeDebugImage_Show(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with TSimbaScript(Params^[0]) do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Show(PSimbaImage(Params^[1])^, PBoolean(Params^[2])^);
  end;
end;

(*
DebugImageUpdate
----------------
```
procedure DebugImageUpdate(Bitmap: TSimbaImage);
```
*)
procedure _LapeDebugImage_Update(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with TSimbaScript(Params^[0]) do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Update(PSimbaImage(Params^[1])^);
  end;
end;

(*
DebugImageClose
---------------
```
procedure DebugImageClose;
```
*)
procedure _LapeDebugImage_Close(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with TSimbaScript(Params^[0]) do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Hide();
  end;
end;

(*
DebugImageDisplay
-----------------
```
procedure DebugImageDisplay(Width, Height: Integer);
```
*)
procedure _LapeDebugImage_Display1(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with TSimbaScript(Params^[0]) do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Display(PInteger(Params^[1])^, PInteger(Params^[2])^);
  end;
end;

(*
DebugImageDisplay
-----------------
```
procedure DebugImageDisplay(X, Y,Width, Height: Integer);
```
*)
procedure _LapeDebugImage_Display2(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with TSimbaScript(Params^[0]) do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Display(PInteger(Params^[1])^, PInteger(Params^[2])^, PInteger(Params^[3])^, PInteger(Params^[4])^);
  end;
end;

procedure ImportDebugImage(Script: TSimbaScript);
begin
  with Script.Compiler do
  begin
    DumpSection := 'Debug Image';

    addGlobalMethod('procedure DebugImageSetMaxSize(MaxWidth, MaxHeight: Integer);', @_LapeDebugImage_MaxSize, Script);
    addGlobalMethod('procedure DebugImageDisplay(Width, Height: Integer); overload', @_LapeDebugImage_Display1, Script);
    addGlobalMethod('procedure DebugImageDisplay(X, Y, Width, Height: Integer); overload', @_LapeDebugImage_Display2, Script);
    addGlobalMethod('procedure DebugImageClose', @_LapeDebugImage_Close, Script);
    addGlobalMethod('procedure DebugImageUpdate(Image: TImage)', @_LapeDebugImage_Update, Script);
    addGlobalMethod('procedure DebugImageShow(Image: TImage; EnsureVisible: Boolean = True)', @_LapeDebugImage_Show, Script);

    DumpSection := 'Image';

    addGlobalFunc(
      'procedure TImage.Show(EnsureVisible: Boolean = True);', [
      'begin',
      '  DebugImageShow(Self, EnsureVisible);',
      'end;'
    ]);

    DumpSection := 'Debug Image';

    addGlobalFunc(
      'procedure Show(Matrix: TIntegerMatrix); overload;', [
      'begin',
      '  with TImage.CreateFromMatrix(Matrix) do',
      '  try',
      '    Show();',
      '  finally',
      '    Free();',
      '  end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure Show(Matrix: TSingleMatrix; ColorMapType: Integer = 0); overload;', [
      'begin',
      '  with TImage.CreateFromMatrix(Matrix, ColorMapType) do',
      '  try',
      '    Show();',
      '  finally',
      '    Free();',
      '  end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure Show(Boxes: TBoxArray; Filled: Boolean = False); overload;', [
      'begin',
      '  with Boxes.Merge() do',
      '    with TImage.Create(X1+X2+1, Y1+Y2+1) do',
      '    try',
      '      DrawBoxArray(Boxes, Filled);',
      '      Show();',
      '    finally',
      '      Free();',
      '    end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure Show(Box: TBox; Filled: Boolean = False); overload;', [
      'begin',
      '  Show(TBoxArray([Box]), Filled);',
      'end;'
    ]);

    addGlobalFunc(
      'procedure Show(TPA: TPointArray); overload;', [
      'begin',
      '  with TPA.Bounds() do',
      '    with TImage.Create(X1+X2+1, Y1+Y2+1) do',
      '    try',
      '      DrawTPA(TPA);',
      '      Show();',
      '    finally',
      '      Free();',
      '    end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure Show(ATPA: T2DPointArray); overload;', [
      'begin',
      '  with ATPA.Bounds() do',
      '    with TImage.Create(X1+X2+1, Y1+Y2+1) do',
      '    try',
      '      DrawATPA(ATPA);',
      '      Show();',
      '    finally',
      '      Free();',
      '    end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure Show(Quads: TQuadArray; Filled: Boolean = False); overload;', [
      'var',
      '  Boxes: TBoxArray;',
      '  Quad: TQuad;',
      'begin',
      '  for Quad in Quads do',
      '    Boxes += Quad.Bounds;',
      '',
      '  with Boxes.Merge() do',
      '    with TImage.Create(X1+X2+1, Y1+Y2+1) do',
      '    try',
      '      DrawQuadArray(Quads, Filled);',
      '      Show();',
      '    finally',
      '      Free();',
      '    end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure Show(Quad: TQuad; Filled: Boolean = False); overload;', [
      'begin',
      '  Show(TQuadArray([Quad]), Filled);',
      'end;'
    ]);

    addGlobalFunc(
      'procedure ShowOnClient(Quads: TQuadArray; Filled: Boolean = False); overload;', [
      'begin',
      '  with TImage.CreateFromTarget() do',
      '  try',
      '    DrawQuadArray(Quads, Filled);',
      '    Show();',
      '  finally',
      '    Free();',
      '  end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure ShowOnClient(Quad: TQuad; Filled: Boolean = False); overload;', [
      'begin',
      '  ShowOnClient(TQuadArray([Quad]), Filled);',
      'end;'
    ]);

    addGlobalFunc(
      'procedure ShowOnClient(Boxes: TBoxArray; Filled: Boolean = False); overload;', [
      'begin',
      '  with TImage.CreateFromTarget() do',
      '  try',
      '    DrawBoxArray(Boxes, Filled);',
      '    Show();',
      '  finally',
      '    Free();',
      '  end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure ShowOnClient(Box: TBox; Filled: Boolean = False); overload;', [
      'begin',
      '  ShowOnClient(TBoxArray([Box]), Filled);',
      'end;'
    ]);

    addGlobalFunc(
      'procedure ShowOnClient(TPA: TPointArray); overload;', [
      'begin',
      '  with TImage.CreateFromTarget() do',
      '  try',
      '    DrawTPA(TPA);',
      '    Show();',
      '  finally',
      '    Free();',
      '  end;',
      'end;'
    ]);

    addGlobalFunc(
      'procedure ShowOnClient(ATPA: T2DPointArray); overload;', [
      'begin',
      '  with TImage.CreateFromTarget() do',
      '  try',
      '    DrawATPA(ATPA);',
      '    Show();',
      '  finally',
      '    Free();',
      '  end;',
      'end;'
    ]);

    DumpSection := '';
  end;
end;

end.
