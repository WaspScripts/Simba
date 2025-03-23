unit simba.import_json;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base, simba.script;

procedure ImportJson(Script: TSimbaScript);

implementation

uses
  lptypes,
  simba.json;

(*
JSON
====
JSON parser.
*)

type
  PJSONItemType = ^EJSONItemType;
  PSimbaJSONItem = ^TSimbaJSONItem;

procedure _LapeJSONItem_ItemType_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PJSONItemType(Result)^ := PSimbaJSONItem(Params^[0])^.Typ;
end;

procedure _LapeJSONItem_AsInt_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInt64(Result)^ := PSimbaJSONItem(Params^[0])^.AsInt;
end;

procedure _LapeJSONItem_AsInt_Write(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AsInt := PInt64(Params^[1])^;
end;

procedure _LapeJSONItem_AsFloat_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDouble(Result)^ := PSimbaJSONItem(Params^[0])^.AsFloat;
end;

procedure _LapeJSONItem_AsFloat_Write(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AsFloat := PDouble(Params^[1])^;
end;

procedure _LapeJSONItem_AsString_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PString(Result)^ := PSimbaJSONItem(Params^[0])^.AsString;
end;

procedure _LapeJSONItem_AsString_Write(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AsString := PString(Params^[1])^;
end;

procedure _LapeJSONItem_AsUnicodeString_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PUnicodeString(Result)^ := PSimbaJSONItem(Params^[0])^.AsUnicodeString;
end;

procedure _LapeJSONItem_AsUnicodeString_Write(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AsUnicodeString := PUnicodeString(Params^[1])^;
end;

procedure _LapeJSONItem_AsBool_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.AsBool;
end;

procedure _LapeJSONItem_AsBool_Write(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AsBool := PBoolean(Params^[1])^;
end;

procedure _LapeJSONItem_Count_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PSimbaJSONItem(Params^[0])^.Count;
end;

procedure _LapeJSONItem_Keys_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PStringArray(Result)^ := PSimbaJSONItem(Params^[0])^.Keys;
end;

procedure _LapeJSONItem_ItemsByKey_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := PSimbaJSONItem(Params^[0])^.ItemsByKey[PString(Params^[1])^];
end;

procedure _LapeJSONItem_ItemsByIndex_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := PSimbaJSONItem(Params^[0])^.ItemsByIndex[PInteger(Params^[1])^];
end;

procedure _LapeJSONItem_Add(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.Add(PString(Params^[1])^, PSimbaJSONItem(Params^[2])^);
end;

procedure _LapeJSONItem_AddInt(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AddInt(PString(Params^[1])^, PInt64(Params^[2])^);
end;

procedure _LapeJSONItem_AddFloat(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AddFloat(PString(Params^[1])^, PDouble(Params^[2])^);
end;

procedure _LapeJSONItem_AddString(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AddString(PString(Params^[1])^, PString(Params^[2])^);
end;

procedure _LapeJSONItem_AddBool(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AddBool(PString(Params^[1])^, PBoolean(Params^[2])^);
end;

procedure _LapeJSONItem_AddArray(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AddArray(PString(Params^[1])^, PSimbaJSONItem(Params^[2])^);
end;

procedure _LapeJSONItem_AddObject(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.AddObject(PString(Params^[1])^, PSimbaJSONItem(Params^[2])^);
end;

procedure _LapeJSONItem_Has1(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.Has(PString(Params^[1])^);
end;

procedure _LapeJSONItem_Has2(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.Has(PString(Params^[1])^, PJSONItemType(Params^[2])^);
end;

procedure _LapeJSONItem_GetInt(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.GetInt(PString(Params^[1])^, PInt64(Params^[2])^);
end;

procedure _LapeJSONItem_GetString(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.GetString(PString(Params^[1])^, PString(Params^[2])^);
end;

procedure _LapeJSONItem_GetUnicodeString(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.GetUnicodeString(PString(Params^[1])^, PUnicodeString(Params^[2])^);
end;

procedure _LapeJSONItem_GetBool(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.GetBool(PString(Params^[1])^, PBoolean(Params^[2])^);
end;

procedure _LapeJSONItem_GetArray(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.GetArray(PString(Params^[1])^, PSimbaJSONItem(Params^[2])^);
end;

procedure _LapeJSONItem_GetObject(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.GetObject(PString(Params^[1])^, PSimbaJSONItem(Params^[2])^);
end;

procedure _LapeJSONItem_GetFloat(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PBoolean(Result)^ := PSimbaJSONItem(Params^[0])^.GetFloat(PString(Params^[1])^, PDouble(Params^[2])^);
end;

procedure _LapeJSONItem_FindPath(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := PSimbaJSONItem(Params^[0])^.FindPath(PString(Params^[1])^);
end;

procedure _LapeJSONItem_Clone(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := PSimbaJSONItem(Params^[0])^.Clone();
end;

procedure _LapeJSONItem_Delete(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.Delete(PSimbaJSONItem(Params^[1])^);
end;

procedure _LapeJSONItem_Clear(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.Clear();
end;

procedure _LapeJSONItem_Free(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Params^[0])^.Free();
end;

procedure _LapeJSONItem_ToJSON(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PString(Result)^ := PSimbaJSONItem(Params^[0])^.ToJSON;
end;

procedure _LapeNewJSONObject(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := NewJSONObject();
end;

procedure _LapeNewJSONArray(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := NewJSONArray();
end;

procedure _LapeParseJSON(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := ParseJSON(PString(Params^[0])^);
end;

procedure _LapeLoadJSON(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PSimbaJSONItem(Result)^ := LoadJSON(PString(Params^[0])^);
end;

procedure _LapeSaveJSON(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  SaveJSON(PSimbaJSONItem(Params^[0])^, PString(Params^[1])^);
end;

procedure ImportJSON(Script: TSimbaScript);
begin
  with Script.Compiler do
  begin
    DumpSection := 'JSON';

    addGlobalType('enum(UNKNOWN, INT, FLOAT, STR, BOOL, NULL, ARR, OBJ)', 'EJSONType');
    addGlobalType('type Pointer', 'TJSONItem');

    addProperty('TJSONItem', 'Typ', 'EJSONType', @_LapeJSONItem_ItemType_Read);
    addProperty('TJSONItem', 'AsInt', 'Int64', @_LapeJSONItem_AsInt_Read, @_LapeJSONItem_AsInt_Write);
    addProperty('TJSONItem', 'AsString', 'String', @_LapeJSONItem_AsString_Read, @_LapeJSONItem_AsString_Write);
    addProperty('TJSONItem', 'AsUnicodeString', 'UnicodeString', @_LapeJSONItem_AsUnicodeString_Read, @_LapeJSONItem_AsUnicodeString_Write);
    addProperty('TJSONItem', 'AsBool', 'Boolean', @_LapeJSONItem_AsBool_Read, @_LapeJSONItem_AsBool_Write);
    addProperty('TJSONItem', 'AsFloat', 'Double', @_LapeJSONItem_AsFloat_Read, @_LapeJSONItem_AsFloat_Write);
    addProperty('TJSONItem', 'Count', 'Integer', @_LapeJSONItem_Count_Read);
    addProperty('TJSONItem', 'Keys', 'TStringArray', @_LapeJSONItem_Keys_Read);
    addPropertyIndexed('TJSONItem', 'Items', 'Key: String', 'TJSONItem', @_LapeJSONItem_ItemsByKey_Read);
    addPropertyIndexed('TJSONItem', 'Items', 'Index: Integer', 'TJSONItem', @_LapeJSONItem_ItemsByIndex_Read);

    addGlobalFunc('function TJSONItem.ToJSON: String', @_LapeJSONItem_ToJSON);
    addGlobalFunc('procedure TJSONItem.Add(Key: String; Item: TJSONItem)', @_LapeJSONItem_Add);
    addGlobalFunc('procedure TJSONItem.AddInt(Key: String; Value: Int64)', @_LapeJSONItem_AddInt);
    addGlobalFunc('procedure TJSONItem.AddString(Key: String; Value: String)', @_LapeJSONItem_AddString);
    addGlobalFunc('procedure TJSONItem.AddBool(Key: String; Value: Boolean)', @_LapeJSONItem_AddBool);
    addGlobalFunc('procedure TJSONItem.AddFloat(Key: String; Value: Double)', @_LapeJSONItem_AddFloat);
    addGlobalFunc('procedure TJSONItem.AddArray(Key: String; Value: TJSONItem)', @_LapeJSONItem_AddArray);
    addGlobalFunc('procedure TJSONItem.AddObject(Key: String; Value: TJSONItem)', @_LapeJSONItem_AddObject);
    addGlobalFunc('function TJSONItem.Has(Key: String): Boolean; overload', @_LapeJSONItem_Has1);
    addGlobalFunc('function TJSONItem.Has(Key: String; Typ: EJSONType): Boolean; overload', @_LapeJSONItem_Has2);

    addGlobalFunc('function TJSONItem.GetInt(Key: String; out Value: Int64): Boolean', @_LapeJSONItem_GetInt);
    addGlobalFunc('function TJSONItem.GetFloat(Key: String; out Value: Double): Boolean', @_LapeJSONItem_GetFloat);
    addGlobalFunc('function TJSONItem.GetString(Key: String; out Value: String): Boolean', @_LapeJSONItem_GetString);
    addGlobalFunc('function TJSONItem.GetUnicodeString(Key: String; out Value: String): Boolean', @_LapeJSONItem_GetUnicodeString);
    addGlobalFunc('function TJSONItem.GetBool(Key: String; out Value: Boolean): Boolean', @_LapeJSONItem_GetBool);
    addGlobalFunc('function TJSONItem.GetArray(Key: String; out Value: TJSONItem): Boolean', @_LapeJSONItem_GetArray);
    addGlobalFunc('function TJSONItem.GetObject(Key: String; out Value: TJSONItem): Boolean', @_LapeJSONItem_GetObject);

    addGlobalFunc('function TJSONItem.FindPath(Path: String): TJSONItem', @_LapeJSONItem_FindPath);
    addGlobalFunc('function TJSONItem.Clone: TJSONItem', @_LapeJSONItem_Clone);
    addGlobalFunc('procedure TJSONItem.Delete(Item: TJSONItem); overload', @_LapeJSONItem_Delete);
    addGlobalFunc('procedure TJSONItem.Clear', @_LapeJSONItem_Clear);
    addGlobalFunc('procedure TJSONItem.Free', @_LapeJSONItem_Free);

    addGlobalFunc('function NewJSONObject: TJSONItem;', @_LapeNewJSONObject);
    addGlobalFunc('function NewJSONArray: TJSONItem;', @_LapeNewJSONArray);
    addGlobalFunc('function ParseJSON(Str: String): TJSONItem;', @_LapeParseJSON);
    addGlobalFunc('function LoadJSON(FileName: String): TJSONItem;', @_LapeLoadJSON);
    addGlobalFunc('procedure SaveJSON(Item: TJSONItem; FileName: String);', @_LapeSaveJSON);

    DumpSection := '';
  end;
end;

end.
