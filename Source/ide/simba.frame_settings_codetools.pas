{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.frame_settings_codetools;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, DividerBevel;

type
  TSimbaCodetoolsFrame = class(TFrame)
    CompletionKeywordsCheckbox: TCheckBox;
    AutoOpenCompletionCheckbox: TCheckBox;
    AutoOpenParamHintCheckbox: TCheckBox;
    IgnoreDirectiveCheckbox: TCheckBox;
    DividerBevel1: TDividerBevel;
    DividerBevel2: TDividerBevel;
  public
    procedure Load;
    procedure Save;
  end;

implementation

{$R *.lfm}

uses
  simba.settings, LCLType, LCLProc;

procedure TSimbaCodetoolsFrame.Load;
begin
  CompletionKeywordsCheckbox.Checked := SimbaSettings.CodeTools.CompletionAddKeywords.Value;
  IgnoreDirectiveCheckbox.Checked    := SimbaSettings.CodeTools.IgnoreIDEDirective.Value;
  AutoOpenParamHintCheckbox.Checked  := SimbaSettings.CodeTools.ParamHintOpenAutomatically.Value;
  AutoOpenCompletionCheckbox.Checked := SimbaSettings.CodeTools.CompletionOpenAutomatically.Value;
end;

procedure TSimbaCodetoolsFrame.Save;
begin
  SimbaSettings.CodeTools.IgnoreIDEDirective.Value          := IgnoreDirectiveCheckbox.Checked;
  SimbaSettings.CodeTools.ParamHintOpenAutomatically.Value  := AutoOpenParamHintCheckbox.Checked;
  SimbaSettings.CodeTools.CompletionAddKeywords.Value       := CompletionKeywordsCheckbox.Checked;
  SimbaSettings.CodeTools.CompletionOpenAutomatically.Value := AutoOpenCompletionCheckbox.Checked;
end;

end.

