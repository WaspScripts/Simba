unit simba.ide_editor_mousecommands;

{$i simba.inc}

interface

uses
  Classes, SysUtils, SynEditMouseCmds;

const
  emcMouseButtonBack:    TSynEditorMouseCommand = 0;
  emcMouseButtonForward: TSynEditorMouseCommand = 0;

implementation

initialization
  emcMouseButtonBack    := AllocatePluginMouseRange(1);
  emcMouseButtonForward := AllocatePluginMouseRange(1);

end.

