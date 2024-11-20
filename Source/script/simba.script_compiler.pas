{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.script_compiler;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  lpcompiler, lptypes, lpvartypes, lptree, lpffiwrappers, ffi,
  simba.base, simba.containers, simba.vartype_string;

type
  TSimbaScript_Compiler = class(TLapeCompiler)
  protected type
    TManagedImportClosure = class(TLapeDeclaration)
      Closure: TImportClosure;
    end;
  protected
    FDumpSection: String;
    FDump: TSimbaStringPairList;

    procedure DumpAdd(const Section, Str: String);
    procedure DumpMethod(Str: String);
    procedure DumpType(Name, Str: String);
    procedure DumpVar(Name, Typ: String);

    procedure InitBaseFile; override;
    procedure InitBaseVariant; override;
    procedure InitBaseDefinitions; override;
    procedure InitBaseMath; override;
    procedure InitBaseString; override;
    procedure InitBaseDateTime; override;

    function GetDumpSection: String;
  public
    constructor CreateDump(FileName: String); overload;
    destructor Destroy; override;

    // Overrides for dumping
    function addGlobalVar(Typ: lpString; Value: Pointer; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Typ: lpString; Value: lpString; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Typ: ELapeBaseType; Value: Pointer; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: Int32; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: UInt32; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: Int64; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: UInt64; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: Single; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: Double; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: AnsiString; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: UnicodeString; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: Variant; AName: lpString): TLapeGlobalVar; override;
    function addGlobalVar(Value: Pointer; AName: lpString): TLapeGlobalVar; override;
    function addGlobalFunc(Header: lpString; Value: Pointer): TLapeGlobalVar; override;
    function addGlobalType(Str: lpString; AName: lpString): TLapeType; override;

    // Compiler addons
    procedure pushCode(Code: String);
    procedure addDelayedCode(Code: TStringArray; AFileName: lpString = ''); overload;
    function addGlobalFunc(Header: lpString; Body: TStringArray): TLapeTree_Method;overload;
    function addGlobalFunc(Header: lpString; Value: Pointer; ABI: TFFIABI): TLapeGlobalVar; overload;
    function addGlobalType(Str: lpString; AName: lpString; ABI: TFFIABI): TLapeType; overload;
    function addGlobalType(Str: TStringArray; Name: String): TLapeType;  overload;
    function addClassConstructor(Obj, Params: lpString; Func: Pointer; IsOverload: Boolean = False): TLapeGlobalVar;
    procedure addClass(Name: lpString; Parent: lpString = 'TObject');
    procedure addProperty(Obj, Name, Typ: String; ReadFunc: Pointer; WriteFunc: Pointer = nil);
    procedure addPropertyIndexed(Obj, Name, Params, Typ: String; ReadFunc: Pointer; WriteFunc: Pointer = nil);
    procedure addMagic(Name: String; Params: array of lpString; ParamTypes: array of ELapeParameterType; Res: String; Func: Pointer);
    function Compile: Boolean; override;
    procedure CallProc(ProcName: String);

    property DumpSection: String read GetDumpSection write FDumpSection;
    property Dump: TSimbaStringPairList read FDump;
  end;

implementation

uses
  lpeval, lpparser, lpinterpreter;

procedure TSimbaScript_Compiler.DumpAdd(const Section, Str: String);
var
  Item: TSimbaStringPair;
begin
  Item.Name := Section;
  Item.Value := Str;

  FDump.Add(Item);
end;

procedure TSimbaScript_Compiler.DumpMethod(Str: String);
begin
  Str := Str.Trim();
  if not Str.EndsWith(';') then
    Str := Str + ';';
  Str := Str + ' external;';

  DumpAdd(DumpSection, Str);
end;

procedure TSimbaScript_Compiler.DumpType(Name, Str: String);
begin
  if Name.StartsWith('!') then
    Exit;
  Str := 'type ' + Name + ' = ' + Str;
  if not Str.EndsWith(';') then
    Str := Str + ';';

  DumpAdd(DumpSection, Str);
end;

procedure TSimbaScript_Compiler.DumpVar(Name, Typ: String);
var
  Str: String;
begin
  if Name.StartsWith('!') then
    Exit;
  Str := 'var ' + Name + ': ' + Typ;
  if not Str.EndsWith(';') then
    Str := Str + ';';

  DumpAdd(DumpSection, Str);
end;

function TSimbaScript_Compiler.GetDumpSection: String;
begin
  if (FDumpSection = '') then
    FDumpSection := '!Simba';

  Result := FDumpSection;
end;

procedure TSimbaScript_Compiler.InitBaseFile;
begin
  { nothing, we import our own file later }
end;

procedure TSimbaScript_Compiler.InitBaseVariant;
begin
  { nothing, we import our own variant later }
end;

procedure TSimbaScript_Compiler.InitBaseDefinitions;
begin
  DumpSection := 'Base';

  inherited InitBaseDefinitions();

  DumpSection := '';
end;

// lpeval_import_math.inc but moved Random functions under Random section
procedure TSimbaScript_Compiler.InitBaseMath;
begin
  DumpSection := 'Math';

  addGlobalVar(Pi, 'Pi').isConstant := True;

  addGlobalFunc('function Min(x,y: Int64): Int64; overload;', @_LapeMin);
  addGlobalFunc('function Min(x,y: Double): Double; overload;', @_LapeMinF);
  addGlobalFunc('function Max(x,y: Int64): Int64; overload;', @_LapeMax);
  addGlobalFunc('function Max(x,y: Double): Double; overload;', @_LapeMaxF);
  addGlobalFunc('function EnsureRange(Value, Min, Max: Int64): Int64; overload;', @_LapeEnsureRange);
  addGlobalFunc('function EnsureRange(Value, Min, Max: Double): Double; overload;', @_LapeEnsureRangeF);
  addGlobalFunc('function InRange(Value, Min, Max: Int64): Boolean; overload;', @_LapeInRange);
  addGlobalFunc('function InRange(Value, Min, Max: Double): Boolean; overload;', @_LapeInRangeF);

  addGlobalFunc('function Abs(x: Double): Double; overload;', @_LapeAbs);
  addGlobalFunc('function Abs(x: Int64): Int64; overload;', @_LapeAbsI);
  addGlobalFunc('function Sign(AValue: Int64): Int8; overload;', @_LapeSign);
  addGlobalFunc('function Sign(AValue: Double): Int8; overload;', @_LapeSignF);
  addGlobalFunc('function Power(Base, Exponent: Double): Double;', @_LapePower);
  addGlobalFunc('function Sqr(x: Double): Double; overload;', @_LapeSqr);
  addGlobalFunc('function Sqr(x: Int64): Int64; overload;', @_LapeSqrI);
  addGlobalFunc('function Sqrt(x: Double): Double;', @_LapeSqrt);
  addGlobalFunc('function ArcTan(x: Double): Double;', @_LapeArcTan);
  addGlobalFunc('function Ln(x: Double): Double;', @_LapeLn);
  addGlobalFunc('function Sin(x: Double): Double;', @_LapeSin);
  addGlobalFunc('function Cos(x: Double): Double;', @_LapeCos);
  addGlobalFunc('function Exp(x: Double): Double;', @_LapeExp);
  addGlobalFunc('function Hypot(x,y: Double): Double', @_LapeHypot);
  addGlobalFunc('function ArcTan2(x,y: Double): Double', @_LapeArcTan2);
  addGlobalFunc('function Tan(x: Double): Double', @_LapeTan);
  addGlobalFunc('function ArcSin(x: Double): Double', @_LapeArcSin);
  addGlobalFunc('function ArcCos(x: Double): Double', @_LapeArcCos);
  addGlobalFunc('function Cotan(x: Double): Double', @_LapeCotan);
  addGlobalFunc('function Secant(x: Double): Double', @_LapeSecant);
  addGlobalFunc('function Cosecant(x: Double): Double', @_LapeCosecant);
  addGlobalFunc('function Round(x: Double): Int64; overload;', @_LapeRound);
  addGlobalFunc('function Round(x: Double; Precision: Int8): Double; overload;', @_LapeRoundTo);
  addGlobalFunc('function Frac(x: Double): Double;', @_LapeFrac);
  addGlobalFunc('function Int(x: Double): Double;', @_LapeInt);
  addGlobalFunc('function Trunc(x: Double): Int64;', @_LapeTrunc);
  addGlobalFunc('function Ceil(x: Double): Int64; overload;', @_LapeCeil);
  addGlobalFunc('function Ceil(x: Double; Precision: Int8): Double; overload;', @_LapeCeilTo);
  addGlobalFunc('function Floor(x: Double): Int64;', @_LapeFloor);
  addGlobalFunc('function CosH(x: Double): Double;', @_LapeCosH);
  addGlobalFunc('function SinH(x: Double): Double;', @_LapeSinH);
  addGlobalFunc('function TanH(x: Double): Double;', @_LapeTanH);
  addGlobalFunc('function ArcCosH(x: Double): Double;', @_LapeArcCosH);
  addGlobalFunc('function ArcSinH(x: Double): Double;', @_LapeArcSinH);
  addGlobalFunc('function ArcTanH(x: Double): Double;', @_LapeArcTanH);
  addGlobalFunc('procedure SinCos(theta: Double; out sinus, cosinus: Double);', @_LapeSinCos);
  addGlobalFunc('procedure DivMod(Dividend: UInt32; Divisor: UInt16; var Result, Remainder: UInt16);', @_LapeDivMod);

  DumpSection := 'Random';

  addGlobalVar(ltUInt32, @RandSeed, 'RandSeed');

  addGlobalFunc('function Random(min, max: Int64): Int64; overload;', @_LapeRandomRange);
  addGlobalFunc('function Random(min, max: Double): Double; overload;', @_LapeRandomRangeF);
  addGlobalFunc('function Random(l: Int64): Int64; overload;', @_LapeRandom);
  addGlobalFunc('function Random: Double; overload;', @_LapeRandomF);
  addGlobalFunc('procedure Randomize;', @_LapeRandomize);

  DumpSection := '';
end;

// lpeval_import_string.inc but removed a few things
procedure TSimbaScript_Compiler.InitBaseString;
begin
  DumpSection := 'Base';

  addGlobalType('set of (rfReplaceAll, rfIgnoreCase)', 'TReplaceFlags');

  addGlobalFunc('function UTF8Encode(s: WideString): AnsiString; overload;', @_LapeUTF8EncodeW);
  addGlobalFunc('function UTF8Encode(s: UnicodeString): AnsiString; overload;', @_LapeUTF8EncodeU);
  addGlobalFunc('function UTF8Decode(s: AnsiString): WideString; overload;', @_LapeUTF8DecodeW);
  addGlobalFunc('function UTF8Decode(s: AnsiString): UnicodeString; overload;', @_LapeUTF8DecodeU);

  // locale independent
  addGlobalFunc('function UpperCase(s: string): string;', @_LapeUpperCase);
  addGlobalFunc('function LowerCase(s: string): string;', @_LapeLowerCase);
  addGlobalFunc('function UpCase(c: AnsiChar): AnsiChar; overload;', @_LapeUpCaseA);
  addGlobalFunc('function UpCase(c: WideChar): WideChar; overload;', @_LapeUpCaseW);

  addGlobalFunc('function CompareStr(s1, s2: string): Int32;', @_LapeCompareStr);
  addGlobalFunc('function CompareText(s1, s2: string): Int32;', @_LapeCompareText);
  addGlobalFunc('function SameText(s1, s2: string): Boolean;', @_LapeSameText);

  // Uses current user locale
  addGlobalFunc('function AnsiUpperCase(s: string): string;', @_LapeAnsiUpperCase);
  addGlobalFunc('function AnsiLowerCase(s: string): string;', @_LapeAnsiLowerCase);
  addGlobalFunc('function AnsiCompareStr(s1, s2: string): Int32;', @_LapeAnsiCompareStr);
  addGlobalFunc('function AnsiCompareText(s1, s2: string): Int32;', @_LapeAnsiCompareText);
  addGlobalFunc('function AnsiSameText(s1,s2: string): Boolean;', @_LapeAnsiSameText);
  addGlobalFunc('function AnsiSameStr(s1,s2: string): Boolean;', @_LapeAnsiSameStr);

  // Uses current user locale
  addGlobalFunc('function WideUpperCase(s: WideString): WideString;', @_LapeWideUpperCase);
  addGlobalFunc('function WideLowerCase(s: WideString): WideString;', @_LapeWideLowerCase);
  addGlobalFunc('function WideCompareStr(s1, s2: WideString): Int32;', @_LapeWideCompareStr);
  addGlobalFunc('function WideCompareText(s1, s2: WideString): Int32;', @_LapeWideCompareText);
  addGlobalFunc('function WideSameText(s1,s2: WideString): Boolean;', @_LapeWideSameText);
  addGlobalFunc('function WideSameStr(s1,s2: WideString): Boolean;', @_LapeWideSameStr);
  addGlobalFunc('function WideFormat(Fmt: WideString; Args: array of Variant): WideString;', @_LapeWideFormat);

  addGlobalFunc('function Pos(Substr, Source: AnsiString): SizeInt; overload;', @_LapePosA);
  addGlobalFunc('function Pos(Substr, Source: WideString): SizeInt; overload;', @_LapePosW);
  addGlobalFunc('function Pos(Substr, Source: UnicodeString): SizeInt; overload;', @_LapePosU);

  addGlobalFunc('function StringReplace(S, OldPattern, NewPattern: string; Flags: TReplaceFlags = [rfReplaceAll]): string;', @_LapeStringReplace);
  addGlobalFunc('function UnicodeStringReplace(S, OldPattern, NewPattern: UnicodeString; Flags: TReplaceFlags = [rfReplaceAll]): UnicodeString;', @_LapeUnicodeStringReplace);
  addGlobalFunc('function WideStringReplace(S, OldPattern, NewPattern: WideString; Flags: TReplaceFlags = [rfReplaceAll]): WideString;', @_LapeWideStringReplace);

  addGlobalFunc('function Trim(s: string): string;', @_LapeTrim);
  addGlobalFunc('function TrimLeft(s: string): string;', @_LapeTrimLeft);
  addGlobalFunc('function TrimRight(s: string): string;', @_LapeTrimRight);
  addGlobalFunc('function PadL(s: string; Len: SizeInt; c: Char = '' ''): string;', @_LapePadL);
  addGlobalFunc('function PadR(s: string; Len: SizeInt; c: Char = '' ''): string;', @_LapePadR);

  addGlobalFunc('function IntToHex(Value: Int64; Digits: Int32 = 1): string; overload;', @_LapeIntToHex);
  addGlobalFunc('function IntToHex(Value: UInt64; Digits: Int32 = 1): string; overload;', @_LapeUIntToHex);
  addGlobalFunc('function IntToStr(i: Int64): string; overload;', @_LapeToString_Int64);
  addGlobalFunc('function IntToStr(i: UInt64): string; overload;', @_LapeToString_UInt64);

  addGlobalFunc('function StrToInt(s: string): Int32; overload;', @_LapeStrToInt);
  addGlobalFunc('function StrToInt(s: string; Def: Int32): Int32; overload;', @_LapeStrToIntDef);
  addGlobalFunc('function StrToInt64(s: string): Int64; overload;', @_LapeStrToInt64);
  addGlobalFunc('function StrToInt64(s: string; Def: Int64): Int64; overload;', @_LapeStrToInt64Def);
  addGlobalFunc('function StrToUInt64(s: string): UInt64; overload;', @_LapeStrToUInt64);
  addGlobalFunc('function StrToUInt64(s: string; Def: UInt64): UInt64; overload;', @_LapeStrToUInt64Def);
  addGlobalFunc('function StrToFloat(s: string): Double; overload;', @_LapeStrToFloat);
  addGlobalFunc('function StrToFloat(s: string; Def: Double): Double; overload;', @_LapeStrToFloatDef);
  addGlobalFunc('function StrToCurr(s: string): Currency; overload;', @_LapeStrToCurr);
  addGlobalFunc('function StrToCurr(s: string; Def: Currency): Currency; overload;', @_LapeStrToCurrDef);
  addGlobalFunc('function StrToBool(s: string): Boolean; overload;', @_LapeStrToBool);
  addGlobalFunc('function StrToBool(s: string; Default: Boolean): Boolean; overload;', @_LapeStrToBoolDef);

  addGlobalFunc('function BoolToStr(B: Boolean; TrueS: string = ''True''; FalseS: string = ''False''): string;', @_LapeBoolToStr);
  addGlobalFunc('function FloatToStr(f: Double): string;', @_LapeToString_Double);
  addGlobalFunc('function CurrToStr(Value: Currency): string;', @_LapeToString_Currency);

  addGlobalFunc('function Format(Fmt: string; Args: array of Variant): string;', @_LapeFormat);
  addGlobalFunc('function FormatCurr(Format: string; Value: Currency): string;', @_LapeFormatCurr);
  addGlobalFunc('function FormatFloat(Format: string; Value: Double): string;', @_LapeFormatFloat);

  addGlobalFunc('function StringOfChar(c: Char; l: SizeInt): string;', @_LapeStringOfChar);

  DumpSection := '';
end;

// Import our own methods later (import_datetime.pas)
procedure TSimbaScript_Compiler.InitBaseDateTime;
begin
  DumpSection := 'Date & Time';

  addGlobalType(getBaseType(ltDouble).createCopy(True), 'TDateTime', False);

  TLapeType_OverloadedMethod(Globals['ToString'].VarType).addMethod(
    TLapeType_Method(addManagedType(
      TLapeType_Method.Create(
        Self,
        [getGlobalType('TDateTime')],
        [lptConstRef],
        [TLapeGlobalVar(nil)],
        getBaseType(ltString)
      )
    )).NewGlobalVar(@_LapeDateTimeToStr)
  );

  addGlobalFunc('function GetTickCount: UInt64;', @_LapeGetTickCount);
  addGlobalFunc('procedure Sleep(MilliSeconds: UInt32);', @_LapeSleep);

  DumpSection := '';
end;

constructor TSimbaScript_Compiler.CreateDump(FileName: String);
begin
  FDump := TSimbaStringPairList.Create();

  Create(TLapeTokenizerString.Create('begin end;'));
end;

destructor TSimbaScript_Compiler.Destroy;
begin
  if (FDump <> nil) then
    FreeAndNil(FDump);

  inherited Destroy;
end;

function TSimbaScript_Compiler.addGlobalVar(Typ: lpString; Value: Pointer; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, Typ);
end;

function TSimbaScript_Compiler.addGlobalVar(Typ: lpString; Value: lpString; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, Typ);
end;

function TSimbaScript_Compiler.addGlobalVar(Typ: ELapeBaseType; Value: Pointer; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, LapeTypeToString(Typ));
end;

function TSimbaScript_Compiler.addGlobalVar(Value: Int32; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'Int32');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: UInt32; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'UInt32');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: Int64; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'Int64');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: UInt64; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'UInt64');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: Single; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'Single');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: Double; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'Double');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: AnsiString; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'String');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: UnicodeString; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'UnicodeString');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: Variant; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'Variant');
end;

function TSimbaScript_Compiler.addGlobalVar(Value: Pointer; AName: lpString): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpVar(AName, 'Pointer');
end;

function TSimbaScript_Compiler.addGlobalFunc(Header: lpString; Value: Pointer): TLapeGlobalVar;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpMethod(Header);
end;

function TSimbaScript_Compiler.addGlobalType(Str: lpString; AName: lpString): TLapeType;
begin
  Result := inherited;

  if (FDump <> nil) then
    DumpType(AName, Str);
end;

procedure TSimbaScript_Compiler.pushCode(Code: String);
begin
  pushTokenizer(TLapeTokenizerString.Create(Code));
end;

procedure TSimbaScript_Compiler.addDelayedCode(Code: TStringArray; AFileName: lpString);
begin
  addDelayedCode(LapeDelayedFlags + LineEnding.Join(Code), AFileName);
end;

procedure TSimbaScript_Compiler.addProperty(Obj, Name, Typ: String; ReadFunc: Pointer; WriteFunc: Pointer);
begin
  if (ReadFunc <> nil) then
    addGlobalFunc('property ' + Obj + '.' + Name + ': ' + Typ + ';', ReadFunc);
  if (WriteFunc <> nil) then
    addGlobalFunc('property ' + Obj + '.' + Name + '(Value: ' + Typ + ');', WriteFunc);
end;

procedure TSimbaScript_Compiler.addPropertyIndexed(Obj, Name, Params, Typ: String; ReadFunc: Pointer; WriteFunc: Pointer);
begin
  if (ReadFunc <> nil) then
    addGlobalFunc('property ' + Obj + '.' + Name + '(' + Params + '):' + Typ + ';', ReadFunc);
  if (WriteFunc <> nil) then
    addGlobalFunc('property ' + Obj + '.' + Name + '(' + Params + '; Value: ' + Typ + ');', WriteFunc);
end;

procedure TSimbaScript_Compiler.addMagic(Name: String; Params: array of lpString; ParamTypes: array of ELapeParameterType; Res: String; Func: Pointer);

  function getType(Name: lpString): TLapeType;
  begin
    if (Name <> '') then
    begin
      Result := getGlobalType(Name);
      if (Result = nil) then
      begin
        Result := getBaseType(Name);
        if (Result = nil) then
          SimbaException('Type "%s" not found', [Name]);
      end;
    end else
      Result := nil;
  end;

var
  ParamVarTypes: array of TLapeType;
  ParamDefaults: array of TLapeGlobalVar;
  i: Integer;
  Header: TLapeType_Method;
begin
  if (Globals[Name] = nil) or (not (Globals[Name].VarType is TLapeType_OverloadedMethod)) then
    SimbaException('addNativeMagic "%s" is incorrect', [Name]);

  SetLength(ParamVarTypes, Length(Params));
  SetLength(ParamDefaults, Length(Params));
  for i := 0 to High(ParamVarTypes) do
    ParamVarTypes[i] := getType(Params[i]);

  Header := addManagedType(TLapeType_Method.Create(Self, ParamVarTypes, ParamTypes, ParamDefaults, getType(Res))) as TLapeType_Method;
  with TLapeType_OverloadedMethod(Globals[Name].VarType) do
    addMethod(Header.NewGlobalVar(Func));
end;

function TSimbaScript_Compiler.addGlobalFunc(Header: lpString; Body: TStringArray): TLapeTree_Method;
var
  Decl: lpString;
  OldState: Pointer;
begin
  Decl := Header + LineEnding + LineEnding.Join(Body);
  OldState := getTempTokenizerState(LapeDelayedFlags + Decl, '!' + Header);
  try
    Expect([tk_kw_Function, tk_kw_Procedure, tk_kw_Operator, tk_kw_Property]);
    Result := ParseMethod(nil, False);
    CheckAfterCompile();
    addDelayedExpression(Result, True, True);
  finally
    resetTokenizerState(OldState);
  end;

  if (FDump <> nil) then
    DumpAdd(DumpSection, Decl);
end;

function TSimbaScript_Compiler.addGlobalFunc(Header: lpString; Value: Pointer; ABI: TFFIABI): TLapeGlobalVar;
var
  Closure: TManagedImportClosure;
begin
  Closure := TManagedImportClosure.Create();
  Closure.Closure := LapeImportWrapper(Value, Self, Header, ABI);

  with TManagedImportClosure(addManagedDecl(Closure)) do
    Result := addGlobalFunc(Header, Closure.Func);
end;

function TSimbaScript_Compiler.addGlobalType(Str: lpString; AName: lpString; ABI: TFFIABI): TLapeType;
begin
  Result := addGlobalType('native(type ' + Str + ', ffi_' + ABIToStr(ABI) + ')', AName);
end;

function TSimbaScript_Compiler.addGlobalType(Str: TStringArray; Name: String): TLapeType;
begin
  Result := addGlobalType(LineEnding.Join(Str), Name);
end;

function TSimbaScript_Compiler.addClassConstructor(Obj, Params: lpString; Func: Pointer; IsOverload: Boolean): TLapeGlobalVar;
var
  Directives: String;
begin
  Directives := 'static;';
  if IsOverload then
    Directives := Directives + ' overload;';

  Result := addGlobalFunc('function ' + Obj + '.Create' + Params + ': ' + Obj + ';' + Directives, Func);
end;

procedure TSimbaScript_Compiler.addClass(Name: lpString; Parent: lpString);
begin
  addGlobalType('strict ' + Parent, Name);
end;

function TSimbaScript_Compiler.Compile: Boolean;
begin
  {$IF DEFINED(DARWIN) and DECLARED(LoadFFI)}
  if not FFILoaded then
    LoadFFI('/usr/local/opt/libffi/lib/');
  {$ENDIF}

  if not FFILoaded then
    raise Exception.Create('ERROR: libffi is missing or incompatible');

  Result := inherited Compile();
end;

procedure TSimbaScript_Compiler.CallProc(ProcName: String);
var
  Method: TLapeGlobalVar;
begin
  Method := Globals[ProcName];
  if (Method = nil) or (Method.BaseType <> ltScriptMethod) or
     (TLapeType_Method(Method.VarType).Res <> nil) or (TLapeType_Method(Method.VarType).Params.Count <> 0) then
    SimbaException('CallProc: Invalid procedure "%s"', [ProcName]);

  with TLapeCodeRunner.Create(Emitter) do
  try
    Run(PCodePos(Method.Ptr)^);
  finally
    Free();
  end;
end;

end.

