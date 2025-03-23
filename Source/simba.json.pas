{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)

  Wraps FPC's json parser
}
unit simba.json;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  fpjson,
  simba.base,
  simba.baseclass;

type
  {$SCOPEDENUMS ON}
  EJSONItemType = (UNKNOWN, INT, FLOAT, STR, BOOL, NULL, ARR, OBJ);
  {$SCOPEDENUMS OFF}

  TSimbaJSONItem = type Pointer;
  TSimbaJSONItemHelper = type helper for TSimbaJSONItem
  private
    procedure CheckIsObject;
    procedure CheckIsObjectOrArray;

    function GetAsBool: Boolean;
    function GetAsFloat: Double;
    function GetAsInt: Int64;
    function GetAsString: String;
    function GetAsUnicodeString: UnicodeString;
    function GetCount: Integer;
    function GetItemByIndex(Index: Integer): TSimbaJSONItem;
    function GetItemByKey(Key: String): TSimbaJSONItem;
    function GetItemType: EJSONItemType;
    function GetKeys: TStringArray;

    procedure SetAsBool(AValue: Boolean);
    procedure SetAsFloat(AValue: Double);
    procedure SetAsInt(AValue: Int64);
    procedure SetAsString(AValue: String);
    procedure SetAsUnicodeString(AValue: UnicodeString);
  public
    property Typ: EJSONItemType read GetItemType;

    property AsInt: Int64 read GetAsInt write SetAsInt;
    property AsString: String read GetAsString write SetAsString;
    property AsUnicodeString: UnicodeString read GetAsUnicodeString write SetAsUnicodeString;
    property AsBool: Boolean read GetAsBool write SetAsBool;
    property AsFloat: Double read GetAsFloat write SetAsFloat;

    property Keys: TStringArray read GetKeys;
    property Count: Integer read GetCount;
    property ItemsByIndex[Index: Integer]: TSimbaJSONItem read GetItemByIndex;
    property ItemsByKey[Key: String]: TSimbaJSONItem read GetItemByKey;

    procedure Add(Key: String; Value: TSimbaJSONItem);
    procedure AddInt(Key: String; Value: Int64);
    procedure AddString(Key: String; Value: String);
    procedure AddUnicodeSring(Key: String; Value: UnicodeString);
    procedure AddBool(Key: String; Value: Boolean);
    procedure AddFloat(Key: String; Value: Double);
    procedure AddArray(Key: String; Value: TSimbaJSONItem);
    procedure AddObject(Key: String; Value: TSimbaJSONItem);

    function Has(Key: String): Boolean; overload;
    function Has(Key: String; ItemType: EJSONItemType): Boolean; overload;

    function GetInt(Key: String; out Value: Int64): Boolean;
    function GetFloat(Key: String; out Value: Double): Boolean;
    function GetString(Key: String; out Value: String): Boolean;
    function GetUnicodeString(Key: String; out Value: UnicodeString): Boolean;
    function GetBool(Key: String; out Value: Boolean): Boolean;
    function GetArray(Key: String; out Value: TSimbaJSONItem): Boolean;
    function GetObject(Key: String; out Value: TSimbaJSONItem): Boolean;

    function FindPath(Path: String): TSimbaJSONItem;
    function Clone: TSimbaJSONItem;
    procedure Delete(Item: TSimbaJSONItem);
    procedure Clear;

    function ToJSON: String;

    procedure Free;
  end;

  function NewJSONObject: TSimbaJSONItem;
  function NewJSONArray: TSimbaJSONItem;
  function ParseJSON(Str: String): TSimbaJSONItem;
  function LoadJSON(FileName: String): TSimbaJSONItem;
  procedure SaveJSON(Json: TSimbaJSONItem; FileName: String);

implementation

uses
  jsonscanner,
  jsonparser;

procedure TSimbaJSONItemHelper.CheckIsObject;
begin
  if (TJSONData(Self).JSONType <> jtObject) then
    raise Exception.CreateFmt('Expected a JSON object. This item is a %s', [JSONTypeName(TJSONData(Self).JSONType)]);
end;

procedure TSimbaJSONItemHelper.CheckIsObjectOrArray;
begin
  if (not (TJSONData(Self).JSONType in [jtObject, jtArray])) then
    raise Exception.CreateFmt('Expected a JSON object/array. This item is a %s', [JSONTypeName(TJSONData(Self).JSONType)]);
end;

function TSimbaJSONItemHelper.GetAsBool: Boolean;
begin
  Result := TJSONData(Self).AsBoolean;
end;

function TSimbaJSONItemHelper.GetAsFloat: Double;
begin
  Result := TJSONData(Self).AsFloat;
end;

function TSimbaJSONItemHelper.GetAsInt: Int64;
begin
  Result := TJSONData(Self).AsInt64;
end;

function TSimbaJSONItemHelper.GetAsString: String;
begin
  Result := TJSONData(Self).AsString;
end;

function TSimbaJSONItemHelper.GetCount: Integer;
begin
  Result := TJSONData(Self).Count;
end;

function TSimbaJSONItemHelper.GetItemByIndex(Index: Integer): TSimbaJSONItem;
begin
  Result := TJSONData(Self).Items[Index];
end;

function TSimbaJSONItemHelper.GetItemByKey(Key: String): TSimbaJSONItem;
begin
  CheckIsObject();

  Result := TJSONObject(Self).Find(Key);
end;

function TSimbaJSONItemHelper.GetItemType: EJSONItemType;
begin
  case TJSONData(Self).JSONType of
    jtUnknown: Result := EJSONItemType.UNKNOWN;
    jtString:  Result := EJSONItemType.STR;
    jtBoolean: Result := EJSONItemType.BOOL;
    jtNull:    Result := EJSONItemType.NULL;
    jtArray:   Result := EJSONItemType.ARR;
    jtObject:  Result := EJSONItemType.OBJ;
    jtNumber:
      if (TJSONNumber(Self).NumberType = ntFloat) then
        Result := EJSONItemType.FLOAT
      else
        Result := EJSONItemType.INT;
  end;
end;

function TSimbaJSONItemHelper.GetKeys: TStringArray;
var
  I: Integer;
begin
  CheckIsObject();

  SetLength(Result, TJSONObject(Self).Count);
  for I := 0 to TJSONObject(Self).Count - 1 do
    Result[I] := TJSONObject(Self).Names[I];
end;

function TSimbaJSONItemHelper.GetAsUnicodeString: UnicodeString;
begin
  Result := TJSONData(Self).AsUnicodeString;
end;

function TSimbaJSONItemHelper.ToJSON: String;
begin
  Result := TJSONData(Self).FormatJSON();
end;

procedure TSimbaJSONItemHelper.SetAsBool(AValue: Boolean);
begin
  TJSONData(Self).AsBoolean := AValue;
end;

procedure TSimbaJSONItemHelper.SetAsFloat(AValue: Double);
begin
  TJSONData(Self).AsFloat := AValue;
end;

procedure TSimbaJSONItemHelper.SetAsInt(AValue: Int64);
begin
  TJSONData(Self).AsInt64 := AValue;
end;

procedure TSimbaJSONItemHelper.SetAsString(AValue: String);
begin
  TJSONData(Self).AsString := AValue;
end;

procedure TSimbaJSONItemHelper.SetAsUnicodeString(AValue: UnicodeString);
begin
  TJSONData(Self).AsUnicodeString := AValue;
end;

procedure TSimbaJSONItemHelper.Add(Key: String; Value: TSimbaJSONItem);
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, TJSONData(Value));
    jtArray:  TJSONArray(Self).Add(TJSONData(Value));
  end;
end;

procedure TSimbaJSONItemHelper.AddInt(Key: String; Value: Int64);
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, Value);
    jtArray:  TJSONArray(Self).Add(Value);
  end;
end;

procedure TSimbaJSONItemHelper.AddString(Key: String; Value: String);
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, Value);
    jtArray:  TJSONArray(Self).Add(Value);
  end;
end;

procedure TSimbaJSONItemHelper.AddUnicodeSring(Key: String; Value: UnicodeString);
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, Value);
    jtArray:  TJSONArray(Self).Add(Value);
  end;
end;

procedure TSimbaJSONItemHelper.AddBool(Key: String; Value: Boolean);
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, Value);
    jtArray:  TJSONArray(Self).Add(Value);
  end;
end;

procedure TSimbaJSONItemHelper.AddFloat(Key: String; Value: Double);
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, Value);
    jtArray:  TJSONArray(Self).Add(Value);
  end;
end;

procedure TSimbaJSONItemHelper.AddArray(Key: String; Value: TSimbaJSONItem);
begin
  CheckIsObjectOrArray();
  if (TJSONData(Value).JSONType <> jtArray) then
    raise Exception.Create('Value is not a JSON array');

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, TJSONArray(Value));
    jtArray:  TJSONArray(Self).Add(TJSONArray(Value));
  end;
end;

procedure TSimbaJSONItemHelper.AddObject(Key: String; Value: TSimbaJSONItem);
begin
  CheckIsObjectOrArray();
  if (TJSONData(Value).JSONType <> jtObject) then
    raise Exception.Create('Value is not a JSON object');

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Add(Key, TJSONObject(Value));
    jtArray:  TJSONArray(Self).Add(TJSONObject(Value));
  end;
end;

function TSimbaJSONItemHelper.Has(Key: String): Boolean;
begin
  CheckIsObject();
  Result := TJSONObject(Self).Find(Key) <> nil;
end;

function TSimbaJSONItemHelper.Has(Key: String; ItemType: EJSONItemType): Boolean;
var
  Item: TSimbaJSONItem;
begin
  CheckIsObject();
  Item := ItemsByKey[Key];
  Result := (Item <> nil) and (Item.Typ = ItemType);
end;

function TSimbaJSONItemHelper.GetInt(Key: String; out Value: Int64): Boolean;
begin
  Result := Has(Key, EJSONItemType.INT);
  if Result then
    Value := ItemsByKey[Key].AsInt;
end;

function TSimbaJSONItemHelper.GetFloat(Key: String; out Value: Double): Boolean;
begin
  Result := Has(Key, EJSONItemType.FLOAT);
  if Result then
    Value := ItemsByKey[Key].AsFloat;
end;

function TSimbaJSONItemHelper.GetString(Key: String; out Value: String): Boolean;
begin
  Result := Has(Key, EJSONItemType.STR);
  if Result then
    Value := ItemsByKey[Key].AsString;
end;

function TSimbaJSONItemHelper.GetUnicodeString(Key: String; out Value: UnicodeString): Boolean;
begin
  Result := Has(Key, EJSONItemType.STR);
  if Result then
    Value := ItemsByKey[Key].AsUnicodeString;
end;

function TSimbaJSONItemHelper.GetBool(Key: String; out Value: Boolean): Boolean;
begin
  Result := Has(Key, EJSONItemType.BOOL);
  if Result then
    Value := ItemsByKey[Key].AsBool;
end;

function TSimbaJSONItemHelper.GetArray(Key: String; out Value: TSimbaJSONItem): Boolean;
begin
  Result := Has(Key, EJSONItemType.ARR);
  if Result then
    Value := TJSONArray(ItemsByKey[Key]);
end;

function TSimbaJSONItemHelper.GetObject(Key: String; out Value: TSimbaJSONItem): Boolean;
begin
  Result := Has(Key, EJSONItemType.OBJ);
  if Result then
    Value := TJSONObject(ItemsByKey[Key]);
end;

function TSimbaJSONItemHelper.FindPath(Path: String): TSimbaJSONItem;
begin
  Result := TJSONData(Self).FindPath(Path);
end;

function TSimbaJSONItemHelper.Clone: TSimbaJSONItem;
begin
  Result := TJSONData(Self).Clone;
end;

procedure TSimbaJSONItemHelper.Delete(Item: TSimbaJSONItem);
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Delete(TJSONObject(Self).IndexOf(TJSONData(Item)));
    jtArray:  TJSONArray(Self).Delete(TJSONArray(Self).IndexOf(TJSONData(Item)));
    else
      raise Exception.Create('Cannot delete to a non json object/array');
  end;
end;

procedure TSimbaJSONItemHelper.Clear;
begin
  CheckIsObjectOrArray();

  case TJSONData(Self).JSONType of
    jtObject: TJSONObject(Self).Clear;
    jtArray:  TJSONArray(Self).Clear;
  end;
end;

procedure TSimbaJSONItemHelper.Free;
begin
  FreeAndNil(TJSONData(Self));
end;

function NewJSONObject: TSimbaJSONItem;
begin
  Result := TJSONObject.Create();
end;

function NewJSONArray: TSimbaJSONItem;
begin
  Result := TJSONArray.Create();
end;

function ParseJSON(Str: String): TSimbaJSONItem;
begin
  Result := TSimbaJSONItem(GetJSON(Str));
end;

function LoadJSON(FileName: String): TSimbaJSONItem;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    Result := TSimbaJSONItem(GetJSON(Stream));
  finally
    Stream.Free();
  end;
end;

procedure SaveJSON(Json: TSimbaJSONItem; FileName: String);
var
  Stream: TFileStream;
  Text: String;
begin
  Text := JSON.ToJSON;

  if FileExists(FileName) then
    Stream := TFileStream.Create(FileName, fmOpenReadWrite)
  else
    Stream := TFileStream.Create(FileName, fmCreate);

  try
    Stream.Write(Text[1], Length(Text));
  finally
    Stream.Free();
  end;
end;

end.

