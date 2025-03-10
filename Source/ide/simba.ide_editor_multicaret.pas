{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.ide_editor_multicaret;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  SynEdit, SynEditMouseCmds, SynPluginMultiCaret;

type
  TSimbaEditorPlugin_MultiCaret = class(TSynPluginMultiCaret)
  protected
    function DoSimbaHandleMouseAction(AnAction: TSynEditMouseAction; var AnInfo: TSynEditMouseActionInfo): Boolean;
    procedure DoEditorAdded(AValue: TCustomSynEdit); override;
    procedure DoEditorRemoving(AValue: TCustomSynEdit); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  LCLType;

function TSimbaEditorPlugin_MultiCaret.DoSimbaHandleMouseAction(AnAction: TSynEditMouseAction; var AnInfo: TSynEditMouseActionInfo): Boolean;
begin
  // default to adding in selection if available
  if (AnAction.Command = emcPluginMultiCaretToggleCaret) and Editor.SelAvail then
    AnAction.Command := emcPluginMultiCaretSelectionToCarets;

  Result := DoHandleMouseAction(AnAction, AnInfo);
end;

procedure TSimbaEditorPlugin_MultiCaret.DoEditorAdded(AValue: TCustomSynEdit);
var
  I: Integer;
begin
  inherited DoEditorAdded(AValue);

  if (AValue <> nil) then
  begin
    AValue.UnRegisterMouseActionExecHandler(@DoHandleMouseAction);
    AValue.RegisterMouseActionExecHandler(@DoSimbaHandleMouseAction);

    // middle mouse click and selection does multi caret in column mode
    for I := 0 to AValue.MouseTextActions.Count - 1 do
      if (AValue.MouseTextActions[I].Command = emcPasteSelection) then
      begin
        AValue.MouseTextActions.Delete(I);
        Break;
      end;
    AValue.MouseTextActions.AddCommand(emcStartColumnSelections, True, mbXMiddle, ccSingle, cdDown, [], []);
  end;
end;

procedure TSimbaEditorPlugin_MultiCaret.DoEditorRemoving(AValue: TCustomSynEdit);
begin
  if (AValue <> nil) then
    AValue.UnRegisterMouseActionExecHandler(@DoSimbaHandleMouseAction);

  inherited DoEditorRemoving(AValue);
end;

constructor TSimbaEditorPlugin_MultiCaret.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  KeyStrokes.Clear();
  with KeyStrokes.Add() do
  begin
    Key := VK_ESCAPE;
    Shift := [];
    Command := ecPluginMultiCaretClearAll;
  end;
end;

end.

