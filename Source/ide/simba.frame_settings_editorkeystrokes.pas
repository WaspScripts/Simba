{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.frame_settings_editorkeystrokes;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, StdCtrls, SynEditKeyCmds,
  TreeFilterEdit, DividerBevel, simba.ide_editor;

type
  TSimbaEditorHotkeyFrame = class(TFrame)
    ButtonResetDefaults: TButton;
    ButtonReset: TButton;
    CheckboxAlt: TCheckBox;
    CheckboxShift: TCheckBox;
    CheckboxCtrl: TCheckBox;
    ComboKey: TComboBox;
    DividerBevel1: TDividerBevel;
    GroupBox1: TGroupBox;
    TreeFilterEdit1: TTreeFilterEdit;
    Tree: TTreeView;
    procedure ButtonResetClick(Sender: TObject);
    procedure ButtonResetDefaultsClick(Sender: TObject);
    procedure CheckboxShiftChange(Sender: TObject);
    procedure ComboKeyChange(Sender: TObject);
    procedure TreeAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
  protected
    FDoneInit: Boolean;
    FDefaultKeyStrokes: TSynEditKeyStrokes;
    FEditor: TSimbaEditor;
    FChanging: Boolean;

    procedure Init;

    function KeystrokeIsNotDefault(Keystroke: TSynEditKeyStroke): Boolean;
    function KeystrokeText(Keystroke: TSynEditKeyStroke): String;
  public
    procedure Load;
    procedure Save;
  end;

implementation

uses
  LCLProc, LCLType, IniFiles,
  simba.vartype_string, simba.env,
  simba.ide_editor_commands, simba.settings;

procedure TSimbaEditorHotkeyFrame.ButtonResetClick(Sender: TObject);
var
  Node: TTreeNode;
  Keystroke: TSynEditKeyStroke;
begin
  Node := Tree.Selected;
  if (Node = nil) then
    Exit;
  Keystroke := TSynEditKeyStroke(Node.Data);
  Keystroke.Assign(FDefaultKeyStrokes[FDefaultKeyStrokes.FindCommand(Keystroke.Command)]);

  TreeChange(Tree, Tree.Selected);
end;

procedure TSimbaEditorHotkeyFrame.ButtonResetDefaultsClick(Sender: TObject);
begin
  FEditor.Keystrokes.Assign(FDefaultKeyStrokes);

  SimbaSettings.Editor.Keystrokes.Value := '';
  SimbaSettings.Editor.Keystrokes.Changed();

  Load();
end;

procedure TSimbaEditorHotkeyFrame.CheckboxShiftChange(Sender: TObject);
var
  Node: TTreeNode;
  Keystroke: TSynEditKeyStroke;
  NewShift: TShiftState;
begin
  if FChanging then Exit;

  Node := Tree.Selected;
  if (Node = nil) then
    Exit;
  Keystroke := TSynEditKeyStroke(Node.Data);

  NewShift := [];
  if CheckboxShift.Checked then Include(NewShift, ssShift);
  if CheckboxAlt.Checked   then Include(NewShift, ssAlt);
  if CheckboxCtrl.Checked  then Include(NewShift, ssCtrl);

  Keystroke.Shift := NewShift;

  Node.Text := KeystrokeText(Keystroke);
end;

procedure TSimbaEditorHotkeyFrame.ComboKeyChange(Sender: TObject);
var
  Node: TTreeNode;
  Keystroke: TSynEditKeyStroke;
begin
  if FChanging then Exit;

  Node := Tree.Selected;
  if (Node = nil) then
    Exit;
  Keystroke := TSynEditKeyStroke(Node.Data);
  Keystroke.Key := PtrUInt(ComboKey.Items.Objects[ComboKey.ItemIndex]);

  Node.Text := KeystrokeText(Keystroke);
end;

procedure TSimbaEditorHotkeyFrame.TreeAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Bold := KeystrokeIsNotDefault(TSynEditKeyStroke(Node.Data));
end;

procedure TSimbaEditorHotkeyFrame.TreeChange(Sender: TObject; Node: TTreeNode);
var
  Keystroke: TSynEditKeyStroke;
begin
  if (Tree.Selected = nil) then
  begin
    GroupBox1.Caption := '';
    GroupBox1.Enabled := False;
  end else
  begin
    Keystroke := TSynEditKeyStroke(Node.Data);

    FChanging := True;
    CheckboxShift.Checked := ssShift in Keystroke.Shift;
    CheckboxAlt.Checked   := ssAlt   in Keystroke.Shift;
    CheckboxCtrl.Checked  := ssCtrl  in Keystroke.Shift;
    ComboKey.ItemIndex    := ComboKey.Items.IndexOfObject(TObject(Pointer(PtrUInt(Keystroke.Key))));
    FChanging := False;

    Node.Text := KeystrokeText(Keystroke);

    GroupBox1.Caption := Node.Text.Before(' - ');
    GroupBox1.Enabled := True;
  end;
end;

procedure TSimbaEditorHotkeyFrame.Init;

  procedure Add(const Key: integer);
  var
    S: String;
  begin
    S := KeyAndShiftStateToKeyString(Key, []);
    if not KeyStringIsIrregular(S) then
      ComboKey.Items.AddObject(S, TObject(Pointer(PtrUInt(Key))));
  end;

var
  Key: Integer;
begin
  if FDoneInit then
    Exit;

  for Key := 0 to VK_SCROLL do
    Add(Key);
  for Key := VK_BROWSER_BACK to VK_OEM_8 do
    Add(Key);

  FDefaultKeyStrokes := TSimbaEditor.Create(Self, []).Keystrokes;

  FDoneInit := True;
end;

function TSimbaEditorHotkeyFrame.KeystrokeIsNotDefault(Keystroke: TSynEditKeyStroke): Boolean;
begin
  Result := (Keystroke.Shift <> FDefaultKeyStrokes[Keystroke.Index].Shift) or
            (Keystroke.Key <> FDefaultKeyStrokes[Keystroke.Index].Key);
end;

function TSimbaEditorHotkeyFrame.KeystrokeText(Keystroke: TSynEditKeyStroke): String;
begin
  Result := Copy(EditorCommandName(Keystroke.Command), 3);
  if (Result <> '') then
    Result := Result + ' - ' + KeyAndShiftStateToKeyString(Keystroke.Key, Keystroke.Shift);
end;

procedure TSimbaEditorHotkeyFrame.Load;
var
  i: Integer;
  node: TTreeNode;
begin
  Init();
  if (FEditor <> nil) then
    FEditor.Free();
  FEditor := TSimbaEditor.Create(Self, [seoKeybindings]);

  Tree.Items.Clear();
  for i := 0 to FEditor.Keystrokes.Count - 1 do
  begin
    node := Tree.Items.Add(nil, KeystrokeText(FEditor.Keystrokes[i]));
    node.Data := FEditor.Keystrokes[i];
  end;
end;

procedure TSimbaEditorHotkeyFrame.Save;

  function hasChanges: Boolean;
  var
    I: Integer;
  begin
    for I := 0 to FEditor.Keystrokes.Count - 1 do
      if KeystrokeIsNotDefault(FEditor.Keystrokes[I]) then
        Exit(True);
    Result := False;
  end;

var
  INI: TIniFile;
  I: Integer;
  Section: String;
begin
  if hasChanges() then
  begin
    INI := TIniFile.Create(SimbaEnv.DataPath + 'editor_keys.ini');
    for I := 0 to FEditor.Keystrokes.Count - 1 do
    begin
      Section := EditorCommandName(FEditor.Keystrokes[i].Command);
      if (Section = '') then
        Continue;

      if KeystrokeIsNotDefault(FEditor.Keystrokes[I]) then
      begin
        INI.WriteInteger(Section, 'Key', Int32(FEditor.Keystrokes[i].Key));
        INI.WriteInteger(Section, 'Shift', Int32(FEditor.Keystrokes[i].Shift));
      end else
        INI.EraseSection(Section);
    end;
    INI.Free();

    SimbaSettings.Editor.Keystrokes.Value := SimbaEnv.DataPath + 'editor_keys.ini';
  end else
    SimbaSettings.Editor.Keystrokes.Value := '';

  SimbaSettings.Editor.Keystrokes.Changed();
end;

{$R *.lfm}

end.

