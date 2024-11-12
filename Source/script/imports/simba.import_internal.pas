unit simba.import_internal;

{$i simba.inc}

interface

uses
  Classes, SysUtils, lptypes,
  simba.base, simba.script_compiler;

procedure ImportInternal(Compiler: TSimbaScript_Compiler);

implementation

uses
  lpvartypes,
  simba.script, simba.image, simba.process,
  simba.vartype_pointarray, simba.vartype_ordarray, simba.vartype_stringarray,
  simba.vartype_floatmatrix;

type
  PSimbaScript = ^TSimbaScript;

procedure _LapeSetSimbaTitle(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('SetSimbaTitle requires Simba communication');
    SimbaCommunication.SetSimbaTitle(PString(Params^[1])^);
  end;
end;

procedure _LapeDebugImage_SetMaxSize(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_SetMaxSize(PInteger(Params^[1])^, PInteger(Params^[2])^);
  end;
end;

procedure _LapeDebugImage_Show(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Show(PSimbaImage(Params^[1])^, PBoolean(Params^[2])^);
  end;
end;

procedure _LapeDebugImage_Update(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Update(PSimbaImage(Params^[1])^);
  end;
end;

procedure _LapeDebugImage_Hide(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Hide();
  end;
end;

procedure _LapeDebugImage_Display1(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Display(PInteger(Params^[1])^, PInteger(Params^[2])^);
  end;
end;

procedure _LapeDebugImage_Display2(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('DebugImage requires Simba communication');
    SimbaCommunication.DebugImage_Display(PInteger(Params^[1])^, PInteger(Params^[2])^, PInteger(Params^[3])^, PInteger(Params^[4])^);
  end;
end;

procedure _LapePause(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
    State := ESimbaScriptState.STATE_PAUSED;
end;

procedure _LapeShowTrayNotification(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('TrayNotification requires Simba communication');
    SimbaCommunication.ShowTrayNotification(PString(Params^[1])^, PString(Params^[2])^, PInteger(Params^[3])^);
  end;
end;

procedure _LapeGetSimbaPID(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('GetSimbaPID requires Simba communication');
    TProcessID(Result^) := SimbaCommunication.GetSimbaPID();
  end;
end;

procedure _LapeGetSimbaTargetPID(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('GetSimbaTargetPID requires Simba communication');
    TProcessID(Result^) := SimbaCommunication.GetSimbaTargetPID();
  end;
end;

procedure _LapeGetSimbaTargetWindow(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  with PSimbaScript(Params^[0])^ do
  begin
    if (SimbaCommunication = nil) then
      SimbaException('GetSimbaTargetWindow requires Simba communication');
    PWindowHandle(Result)^ := SimbaCommunication.GetSimbaTargetWindow();
  end;
end;

procedure ImportInternal(Compiler: TSimbaScript_Compiler);
begin
  with Compiler do
  begin
    ImportingSection := '!Hidden';

    addGlobalType('type Pointer', '_TSimbaScript');
    addGlobalVar('_TSimbaScript', nil, '_SimbaScript'); // Value added later

    addGlobalFunc('procedure _TSimbaScript.DebugImage_SetMaxSize(Width, Height: Integer)', @_LapeDebugImage_SetMaxSize);
    addGlobalFunc('procedure _TSimbaScript.DebugImage_Show(Image: TImage; EnsureVisible: Boolean)', @_LapeDebugImage_Show);
    addGlobalFunc('procedure _TSimbaScript.DebugImage_Update(Image: TImage)', @_LapeDebugImage_Update);
    addGlobalFunc('procedure _TSimbaScript.DebugImage_Hide()', @_LapeDebugImage_Hide);
    addGlobalFunc('procedure _TSimbaScript.DebugImage_Display(Width, Height: Integer); overload', @_LapeDebugImage_Display1);
    addGlobalFunc('procedure _TSimbaScript.DebugImage_Display(X, Y, Width, Height: Integer); overload', @_LapeDebugImage_Display2);
    addGlobalFunc('procedure _TSimbaScript.Pause()', @_LapePause);
    addGlobalFunc('procedure _TSimbaScript.SetSimbaTitle(S: String)', @_LapeSetSimbaTitle);
    addGlobalFunc('procedure _TSimbaScript.ShowTrayNotification(Title, Message: String; Timeout: Integer)', @_LapeShowTrayNotification);

    addGlobalFunc('function _TSimbaScript.GetSimbaPID: TProcessID', @_LapeGetSimbaPID);
    addGlobalFunc('function _TSimbaScript.GetSimbaTargetPID: TProcessID', @_LapeGetSimbaTargetPID);
    addGlobalFunc('function _TSimbaScript.GetSimbaTargetWindow: TWindowHandle', @_LapeGetSimbaTargetWindow);

    ImportingSection := '';
  end;
end;

end.

