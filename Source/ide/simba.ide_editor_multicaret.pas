{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
  --------------------------------------------------------------------------
  Tweaks TSynPluginMultiCaret a little
}
unit simba.ide_editor_multicaret;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  SynEdit, SynEditKeyCmds, SynEditMouseCmds, SynPluginMultiCaret, LCLType;

type
  TSimbaEditorPlugin_MultiCaret = class(TSynPluginMultiCaret)
  protected
    function DoSimbaHandleMouseAction(AnAction: TSynEditMouseAction; var AnInfo: TSynEditMouseActionInfo): Boolean;
    procedure DoEditorAdded(Value: TCustomSynEdit); override;
    procedure DoEditorRemoving(Value: TCustomSynEdit); override;
    procedure DoCommand(Sender: TObject; AfterProcessing: boolean; var Handled: boolean; var Command: TSynEditorCommand; var AChar: TUtf8Char; Data: pointer; HandlerData: pointer);
  end;

implementation

function TSimbaEditorPlugin_MultiCaret.DoSimbaHandleMouseAction(AnAction: TSynEditMouseAction; var AnInfo: TSynEditMouseActionInfo): Boolean;
begin
  // always default to adding in selection if available
  if (AnAction.Command = emcPluginMultiCaretToggleCaret) and Editor.SelAvail then
    AnAction.Command := emcPluginMultiCaretSelectionToCarets;

  Result := DoHandleMouseAction(AnAction, AnInfo);
end;

procedure TSimbaEditorPlugin_MultiCaret.DoEditorAdded(Value: TCustomSynEdit);
var
  I: Integer;
begin
  inherited DoEditorAdded(Value);

  if (Value <> nil) then
  begin
    Value.UnRegisterMouseActionExecHandler(@DoHandleMouseAction);
    Value.RegisterMouseActionExecHandler(@DoSimbaHandleMouseAction);
    Value.RegisterCommandHandler(@DoCommand, nil);

    // middle mouse click and selection does multi caret in column mode
    for I := 0 to Value.MouseTextActions.Count - 1 do
      if (Value.MouseTextActions[I].Command = emcPasteSelection) then
      begin
        Value.MouseTextActions.Delete(I);
        Break;
      end;
    Value.MouseTextActions.AddCommand(emcStartColumnSelections, True, mbXMiddle, ccSingle, cdDown, [], []);
  end;
end;

procedure TSimbaEditorPlugin_MultiCaret.DoEditorRemoving(Value: TCustomSynEdit);
begin
  if (Value <> nil) then
  begin
    Value.UnRegisterMouseActionExecHandler(@DoSimbaHandleMouseAction);
    Value.UnRegisterCommandHandler(@DoCommand);
  end;

  inherited DoEditorRemoving(Value);
end;

procedure TSimbaEditorPlugin_MultiCaret.DoCommand(Sender: TObject; AfterProcessing: boolean; var Handled: boolean; var Command: TSynEditorCommand; var AChar: TUtf8Char; Data: pointer; HandlerData: pointer);
begin
  Handled := (Command = ecChar) and (AChar = Char(VK_ESCAPE)) and (CaretsCount > 0);
  if Handled then
    Editor.CommandProcessor(ecPluginMultiCaretClearAll, #0, nil);
end;

end.

