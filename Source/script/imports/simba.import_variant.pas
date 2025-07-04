{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)

  Variant script imports.
}
unit simba.import_variant;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base, simba.script_compiler;

procedure ImportVariant(Script: TSimbaScript);

implementation

uses
  lptypes, variants;

(*
Variant
=======
The variant "magic" datatype can store most base types.

```
var v: Variant;
begin
  WriteLn('Should be unassigned: ', not v.IsAssigned());
  WriteLn();

  v := 'I am a string';
  Writeln('Now should *not* be unassigned: ', v.IsAssigned());
  WriteLn('And should be string:');
  WriteLn(v.VarType, ' -> ', v);
  WriteLn();

  v := Int64(123);
  WriteLn('Now should be Int64:');
  WriteLn(v.VarType, ' -> ', v);
  WriteLn();

  v := 0.123456;
  WriteLn('Now should be Double:');
  WriteLn(v.VarType, ' -> ', v);
end;
```

Note:: If curious to how the Variant datatype works, internally it's a record:

  ```
  // pseudo code
  type
    InternalVariantData = record
      VarType: EVariantType;
      Value: array[0..SizeOf(LargestDataTypeVariantCanStore)] of Byte;
    end;
  ```
*)

(*
Variant.VarType
---------------
> function Variant.VarType: EVariantVarType;

Returns the variants var type.

Example::

  if (v.VarType = EVariantVarType.Int32) then
    WriteLn('Variant contains a Int32');
*)
procedure _LapeVariantVarType(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PVariantType(Result)^ := PVariant(Params^[0])^.VarType;
end;

(*
Variant.IsNumeric
-----------------
> function Variant.IsNumeric: Boolean;

Is integer or float?
*)
procedure _LapeVariantIsNumeric(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := VarIsNumeric(PVariant(Params^[0])^);
end;

(*
Variant.IsString
----------------
> function Variant.IsString: Boolean;
*)
procedure _LapeVariantIsString(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := VarIsStr(PVariant(Params^[0])^);
end;

(*
Variant.IsInteger
-----------------
> function Variant.IsInteger: Boolean;
*)
procedure _LapeVariantIsInteger(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := VarIsOrdinal(PVariant(Params^[0])^);
end;

(*
Variant.IsFloat
---------------
> function Variant.IsFloat: Boolean;
*)
procedure _LapeVariantIsFloat(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := VarIsFloat(PVariant(Params^[0])^);
end;

(*
Variant.IsBoolean
-----------------
> function Variant.IsBoolean: Boolean;
*)
procedure _LapeVariantIsBoolean(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := VarIsBool(PVariant(Params^[0])^);
end;

(*
Variant.IsVariant
-----------------
> function Variant.IsVariant: Boolean;

The variant holds another variant!
*)
procedure _LapeVariantIsVariant(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := VarIsType(PVariant(Params^[0])^, varVariant);
end;

(*
Variant.IsAssigned
------------------
> function Variant.IsAssigned: Boolean;

Example:

```
  if v.IsAssigned() then
    WriteLn('Variant HAS been assigned to')
  else
    WriteLn('The variant has NOT been assigned to');
```
*)
procedure _LapeVariantIsAssigned(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := not VarIsClear(PVariant(Params^[0])^);
end;

(*
Variant.IsNull
--------------
> function Variant.IsNull: Boolean;
*)
procedure _LapeVariantIsNull(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := VarIsNull(PVariant(Params^[0])^);
end;

(*
Variant.NULL
------------
> function Variant.NULL: Variant; static;

Static method that returns a null variant variable.

Example:

```
  v := Variant.NULL;
```
*)
procedure _LapeVariantNULL(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PVariant(Result)^ := Null;
end;

procedure ImportVariant(Script: TSimbaScript);
begin
  with Script.Compiler do
  begin
    DumpSection := 'Variant';

    addGlobalType('enum(Unknown, Unassigned, Null, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Single, Double, DateTime, Currency, Boolean, Variant, AString, UString, WString)', 'EVariantVarType');

    addGlobalFunc('function Variant.VarType: EVariantVarType;', @_LapeVariantVarType);

    addGlobalFunc('function Variant.IsNumeric: Boolean;', @_LapeVariantIsNumeric);
    addGlobalFunc('function Variant.IsInteger: Boolean;', @_LapeVariantIsInteger);
    addGlobalFunc('function Variant.IsFloat: Boolean;', @_LapeVariantIsFloat);
    addGlobalFunc('function Variant.IsString: Boolean;', @_LapeVariantIsString);
    addGlobalFunc('function Variant.IsBoolean: Boolean;', @_LapeVariantIsBoolean);
    addGlobalFunc('function Variant.IsVariant: Boolean;', @_LapeVariantIsVariant);
    addGlobalFunc('function Variant.IsAssigned: Boolean;', @_LapeVariantIsAssigned);
    addGlobalFunc('function Variant.IsNull: Boolean;', @_LapeVariantIsNull);

    addGlobalFunc('function Variant.NULL: Variant; static;', @_LapeVariantNULL);

    DumpSection := '';
  end;
end;

end.
