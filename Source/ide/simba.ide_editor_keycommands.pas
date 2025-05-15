{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.ide_editor_keycommands;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Controls, SynEditKeyCmds;

const
  ecCompletionBox:    TSynEditorCommand = 0;
  ecParamHint:        TSynEditorCommand = 0;
  ecDocumentation:    TSynEditorCommand = 0;
  ecCommentSelection: TSynEditorCommand = 0;
  ecCodeComplete:     TSynEditorCommand = 0;

function EditorCommandName(Command: Integer): String;

procedure SimbaDefaultKeystrokes(Keystrokes: TSynEditKeyStrokes);
procedure SimbaLoadKeystrokes(Keystrokes: TSynEditKeyStrokes; UseSettings: Boolean);

implementation

uses
  IniFiles,
  LCLType,
  simba.settings;

function EditorCommandName(Command: Integer): String;
begin
  if (Command = ecDocumentation) then
    Result := 'ecDocumentation'
  else if (Command = ecCommentSelection) then
    Result := 'ecCommentSelection'
  else if (Command = ecCodeComplete) then
    Result := 'ecCodeComplete'
  else if (Command = ecCompletionBox) then
    Result := 'ecCompletionBox'
  else if (Command = ecParamHint) then
    Result := 'ecParamHint'
  else
    Result := EditorCommandToCodeString(Command);
end;

function EditorCommandFromName(Command: String): Integer;
begin
  Result := 0;
  if (Command = 'ecDocumentation') then
    Result := ecDocumentation
  else if (Command = 'ecCommentSelection') then
    Result := ecCommentSelection
  else if (Command = 'ecCodeComplete') then
    Result := ecCodeComplete
  else if (Command = 'ecCompletionBox') then
    Result := ecCompletionBox
  else if (Command = 'ecParamHint') then
    Result := ecParamHint
  else if not IdentToEditorCommand(Command, Result) then
    Result := 0;
end;

procedure SimbaLoadKeystrokes(Keystrokes: TSynEditKeyStrokes; UseSettings: Boolean);
var
  INI: TIniFile;
  I: Integer;
  Sections: TStringList;
  Command: Integer;
  KeystrokeIndex: Integer;
  Shift: TShiftState;
  Key: Integer;
begin
  // load defaults first
  SimbaDefaultKeystrokes(Keystrokes);

  if UseSettings then
    if (SimbaSettings.Editor.Keystrokes.Value <> '') and FileExists(SimbaSettings.Editor.Keystrokes.Value) then
    begin
      Sections := TStringList.Create();

      INI := TIniFile.Create(SimbaSettings.Editor.Keystrokes.Value);
      INI.ReadSections(Sections);
      for I := 0 to Sections.Count - 1 do
      begin
        if (not INI.ValueExists(Sections[I], 'Key')) or (not INI.ValueExists(Sections[I], 'Shift')) then
          Continue;

        Command := EditorCommandFromName(Sections[I]);
        if (Command > 0) then
        begin
          KeystrokeIndex := Keystrokes.FindCommand(Command);
          if (KeystrokeIndex > -1) then
          begin
            Key := INI.ReadInteger(Sections[I], 'Key', 0);
            Shift := TShiftState(INI.ReadInteger(Sections[I], 'Shift', 0));

            Keystrokes[KeystrokeIndex].Key := Key;
            Keystrokes[KeystrokeIndex].Shift := Shift;
          end;
        end;
      end;

      INI.Free();
      Sections.Free();
    end;
end;

procedure SimbaDefaultKeystrokes(Keystrokes: TSynEditKeyStrokes);

  procedure AddKey(const ACmd: TSynEditorCommand; const AKey: word; const AShift: TShiftState; const AShiftMask: TShiftState = []);
  begin
    with Keystrokes.Add() do
    begin
      Key       := AKey;
      Shift     := AShift;
      ShiftMask := AShiftMask;
      Command   := ACmd;
    end;
  end;

begin
  Keystrokes.Clear();

  AddKey(ecUp, VK_UP, []);
  AddKey(ecSelUp, VK_UP, [ssShift]);
  AddKey(ecScrollUp, VK_UP, [ssModifier]);
  AddKey(ecDown, VK_DOWN, []);
  AddKey(ecSelDown, VK_DOWN, [ssShift]);
  AddKey(ecScrollDown, VK_DOWN, [ssModifier]);
  AddKey(ecLeft, VK_LEFT, []);
  AddKey(ecSelLeft, VK_LEFT, [ssShift]);
  AddKey(ecWordLeft, VK_LEFT, [ssModifier]);
  AddKey(ecSelWordLeft, VK_LEFT, [ssShift,ssModifier]);
  AddKey(ecRight, VK_RIGHT, []);
  AddKey(ecSelRight, VK_RIGHT, [ssShift]);
  AddKey(ecWordRight, VK_RIGHT, [ssModifier]);
  AddKey(ecSelWordRight, VK_RIGHT, [ssShift,ssModifier]);
  AddKey(ecPageDown, VK_NEXT, []);
  AddKey(ecSelPageDown, VK_NEXT, [ssShift]);
  AddKey(ecPageBottom, VK_NEXT, [ssModifier]);
  AddKey(ecSelPageBottom, VK_NEXT, [ssShift,ssModifier]);
  AddKey(ecPageUp, VK_PRIOR, []);
  AddKey(ecSelPageUp, VK_PRIOR, [ssShift]);
  AddKey(ecPageTop, VK_PRIOR, [ssModifier]);
  AddKey(ecSelPageTop, VK_PRIOR, [ssShift,ssModifier]);
  AddKey(ecLineStart, VK_HOME, []);
  AddKey(ecSelLineStart, VK_HOME, [ssShift]);
  AddKey(ecEditorTop, VK_HOME, [ssModifier]);
  AddKey(ecSelEditorTop, VK_HOME, [ssShift,ssModifier]);
  AddKey(ecLineEnd, VK_END, []);
  AddKey(ecSelLineEnd, VK_END, [ssShift]);
  AddKey(ecEditorBottom, VK_END, [ssModifier]);
  AddKey(ecSelEditorBottom, VK_END, [ssShift,ssModifier]);
  AddKey(ecToggleMode, VK_INSERT, []);
  AddKey(ecCopy, VK_INSERT, [ssModifier]);
  AddKey(ecPaste, VK_INSERT, [ssShift]);
  AddKey(ecDeleteChar, VK_DELETE, []);
  AddKey(ecCut, VK_DELETE, [ssShift]);
  AddKey(ecDeleteLastChar, VK_BACK, []);
  AddKey(ecDeleteLastChar, VK_BACK, [ssShift]);
  AddKey(ecDeleteLastWord, VK_BACK, [ssModifier]);
  AddKey(ecUndo, VK_BACK, [ssAlt]);
  AddKey(ecRedo, VK_BACK, [ssAlt,ssShift]);
  AddKey(ecLineBreak, VK_RETURN, []);
  AddKey(ecSelectAll, ord('A'), [ssModifier]);
  AddKey(ecCopy, ord('C'), [ssModifier]);
  AddKey(ecBlockIndent, ord('I'), [ssModifier,ssShift]);
  AddKey(ecLineBreak, ord('M'), [ssModifier]);
  //AddKey(ecInsertLine, ord('N'), [ssModifier]);
  AddKey(ecDeleteWord, ord('T'), [ssModifier]);
  AddKey(ecBlockUnindent, ord('U'), [ssModifier,ssShift]);
  AddKey(ecPaste, ord('V'), [ssModifier]);
  AddKey(ecCut, ord('X'), [ssModifier]);
  AddKey(ecDeleteLine, ord('Y'), [ssModifier]);
  AddKey(ecDeleteEOL, ord('Y'), [ssModifier,ssShift]);
  AddKey(ecUndo, ord('Z'), [ssModifier]);
  AddKey(ecRedo, ord('Z'), [ssModifier,ssShift]);
  //AddKey(ecGotoMarker0, ord('0'), [ssModifier]);
  //AddKey(ecGotoMarker1, ord('1'), [ssModifier]);
  //AddKey(ecGotoMarker2, ord('2'), [ssModifier]);
  //AddKey(ecGotoMarker3, ord('3'), [ssModifier]);
  //AddKey(ecGotoMarker4, ord('4'), [ssModifier]);
  //AddKey(ecGotoMarker5, ord('5'), [ssModifier]);
  //AddKey(ecGotoMarker6, ord('6'), [ssModifier]);
  //AddKey(ecGotoMarker7, ord('7'), [ssModifier]);
  //AddKey(ecGotoMarker8, ord('8'), [ssModifier]);
  //AddKey(ecGotoMarker9, ord('9'), [ssModifier]);
  //AddKey(ecSetMarker0, ord('0'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker1, ord('1'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker2, ord('2'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker3, ord('3'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker4, ord('4'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker5, ord('5'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker6, ord('6'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker7, ord('7'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker8, ord('8'), [ssModifier,ssShift]);
  //AddKey(ecSetMarker9, ord('9'), [ssModifier,ssShift]);
  AddKey(ecFoldLevel1, ord('1'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel2, ord('2'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel3, ord('3'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel4, ord('4'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel5, ord('5'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel6, ord('6'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel7, ord('7'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel8, ord('8'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel9, ord('9'), [ssAlt,ssShift]);
  AddKey(ecFoldLevel0, ord('0'), [ssAlt,ssShift]);
  AddKey(ecFoldCurrent, VK_OEM_MINUS, [ssAlt, ssShift]);
  AddKey(ecUnFoldCurrent, VK_OEM_PLUS, [ssAlt, ssShift]);

  AddKey(ecToggleMarkupWord, ord('M'), [ssAlt]);
  //AddKey(ecNormalSelect, ord('N'), [ssModifier,ssShift]);
  //AddKey(ecColumnSelect, ord('C'), [ssModifier,ssShift]);
  AddKey(ecLineSelect, ord('L'), [ssModifier,ssShift]);
  AddKey(ecTab, VK_TAB, []);
  AddKey(ecShiftTab, VK_TAB, [ssShift]);
  AddKey(ecMatchBracket, ord('B'), [ssModifier,ssShift]);

  AddKey(ecColSelUp, VK_UP,    [ssAlt, ssShift]);
  AddKey(ecColSelDown, VK_DOWN,  [ssAlt, ssShift]);
  AddKey(ecColSelLeft, VK_LEFT, [ssAlt, ssShift]);
  AddKey(ecColSelRight, VK_RIGHT, [ssAlt, ssShift]);
  AddKey(ecColSelPageDown, VK_NEXT, [ssAlt, ssShift]);
  AddKey(ecColSelPageBottom, VK_NEXT, [ssAlt, ssShift,ssModifier]);
  AddKey(ecColSelPageUp, VK_PRIOR, [ssAlt, ssShift]);
  AddKey(ecColSelPageTop, VK_PRIOR, [ssAlt, ssShift,ssModifier]);
  AddKey(ecColSelLineStart, VK_HOME, [ssAlt, ssShift]);
  AddKey(ecColSelLineEnd, VK_END, [ssAlt, ssShift]);
  AddKey(ecColSelEditorTop, VK_HOME, [ssAlt, ssShift,ssModifier]);
  AddKey(ecColSelEditorBottom, VK_END, [ssAlt, ssShift,ssModifier]);

  AddKey(ecCodeComplete, VK_RETURN, [ssModifier]);
  AddKey(ecParamHint, VK_SPACE, [ssModifier, ssShift]);
  AddKey(ecCompletionBox, VK_SPACE, [ssModifier]);
  AddKey(ecCommentSelection, VK_LCL_SLASH, [ssModifier]);
  AddKey(ecDocumentation, VK_D, [ssModifier]);
end;

initialization
  ecCompletionBox    := AllocatePluginKeyRange(1);
  ecParamHint        := AllocatePluginKeyRange(1);
  ecDocumentation    := AllocatePluginKeyRange(1);
  ecCommentSelection := AllocatePluginKeyRange(1);
  ecCodeComplete     := AllocatePluginKeyRange(1);

end.

