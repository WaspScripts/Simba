unit simba.script_importutil;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  lpcompiler,
  simba.target, simba.image, simba.httpclient;

// Note: Lape objects internally are just dynarray of byte.
// We declare these objects as such:
//   object
//     Instance: Pointer;
//     DontManage: Boolean;
//   end;

type
  TLapeObject = array of Byte;
  PLapeObject = ^TLapeObject;

type
  PLapeObjectHTTPClient = ^PSimbaHTTPClient;

operator := (Target: TSimbaTarget): TLapeObject;
operator := (Image: TSimbaImage): TLapeObject;

function IsManaging(Obj: PLapeObject): Boolean;
procedure SetManaging(Obj: PLapeObject; Value: Boolean);

procedure LapeObjectImport(Compiler: TLapeCompiler; Name: String);
procedure LapeObjectDestroy(Obj: PLapeObject);

implementation

type
  PSimbaTarget = ^TSimbaTarget;
  PSimbaImage = ^TSimbaImage;

operator := (Target: TSimbaTarget): TLapeObject;
begin
  SetLength(Result, SizeOf(Pointer) + SizeOf(Boolean));
  PSimbaTarget(@Result[0])^ := Target;
end;

operator := (Image: TSimbaImage): TLapeObject;
begin
  SetLength(Result, SizeOf(Pointer) + SizeOf(Boolean));
  PSimbaImage(@Result[0])^ := Image;
end;

function IsManaging(Obj: PLapeObject): Boolean;
begin
  Result := not PBoolean(@Obj^[SizeOf(Pointer)])^;
end;

procedure SetManaging(Obj: PLapeObject; Value: Boolean);
begin
  PBoolean(@Obj^[SizeOf(Pointer)])^ := not Value;
end;

procedure LapeObjectImport(Compiler: TLapeCompiler; Name: String);
begin
  Compiler.addGlobalType('object {%CODETOOLS OFF} Instance: Pointer; DontManage: Boolean; {%CODETOOLS ON} end;', Name);
end;

procedure LapeObjectDestroy(Obj: PLapeObject);
type
  PObject = ^TObject;
  PPObject = ^PObject;
begin
  if IsManaging(Obj) and Assigned(PPObject(Obj)^^) then
    FreeAndNil(PPObject(Obj)^^);
end;

end.

