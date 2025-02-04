{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.form_debugimage;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls,
  simba.component_imagebox, simba.image_lazbridge, simba.threading;

type
  TSimbaDebugImageForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    FImageBox: TSimbaImageBox;
    FBackBuffer: TBitmap;
    FUpdating: TEnterableLock;

    FLastRepaint: Double;
    FNeedRepaint: Boolean;

    FMaxWidth, FMaxHeight: Integer;

    procedure DoApplicationIsIdle(Sender: TObject; var Done: Boolean);
    procedure DoImgDoubleClick(Sender: TSimbaImageBox; X, Y: Integer);
  public
    // Can (and probs should) be called off main thread.
    // Stream must be BGRA and have AWidth*AHeight*SizeOf(TColorBGRA) readable
    procedure UpdateFromStream(AWidth, AHeight: Integer; Stream: TStream; AResize, AEnsureVisible: Boolean); overload;
    procedure UpdateFromStream(AWidth, AHeight: Integer; Stream: TStream); overload;

    procedure Close;

    procedure SetMaxSize(AWidth, AHeight: Integer);
    procedure SetSize(AWidth, AHeight: Integer; AEnsureVisible: Boolean = True);

    property ImageBox: TSimbaImageBox read FImageBox;
  end;

var
  SimbaDebugImageForm: TSimbaDebugImageForm;

implementation

{$R *.lfm}

uses
  simba.base, simba.ide_dockinghelpers,
  simba.colormath, simba.datetime;

procedure TSimbaDebugImageForm.Close;
var
  Form: TCustomForm;
begin
  Form := TCustomForm(Self);
  if (HostDockSite is TSimbaAnchorDockHostSite) then
    Form := TSimbaAnchorDockHostSite(HostDockSite);

  Form.Close();
end;

procedure TSimbaDebugImageForm.FormCreate(Sender: TObject);
begin
  FMaxWidth := 1500;
  FMaxHeight := 1000;

  FImageBox := TSimbaImageBox.Create(Self);
  FImageBox.Parent := Self;
  FImageBox.Align := alClient;
  FImageBox.OnImgDoubleClick := @DoImgDoubleClick;
  FImageBox.BackgroundOwner := False;

  Application.AddOnIdleHandler(@DoApplicationIsIdle);
end;

procedure TSimbaDebugImageForm.FormDestroy(Sender: TObject);
begin
  Application.RemoveOnIdleHandler(@DoApplicationIsIdle);

  if (FBackBuffer <> nil) then
    FreeAndNil(FBackBuffer);
  if (FImageBox.Background <> nil) then
    FImageBox.Background.Free();
end;

procedure TSimbaDebugImageForm.DoApplicationIsIdle(Sender: TObject; var Done: Boolean);
begin
  if FNeedRepaint and ((HighResolutionTime() - FLastRepaint) >= 10) then // do not repaint yet if very recently done. not worth
  begin
    FImageBox.Invalidate();

    FNeedRepaint := False;
    FLastRepaint := HighResolutionTime();
  end;
end;

procedure TSimbaDebugImageForm.DoImgDoubleClick(Sender: TSimbaImageBox; X, Y: Integer);
begin
  DebugLn([EDebugLn.FOCUS], 'Debug Image Click: (%d, %d)', [X, Y]);
end;

procedure TSimbaDebugImageForm.UpdateFromStream(AWidth, AHeight: Integer; Stream: TStream; AResize, AEnsureVisible: Boolean);
var
  Source, Dest: PByte;
  SourceUpper: PtrUInt;
  DestBytesPerLine, SourceBytesPerLine: Integer;

  procedure BGR;
  var
    Y: Integer;
  begin
    for Y := 0 to AHeight - 1 do
    begin
      Stream.Read(Source^, SourceBytesPerLine);
      LazImage_CopyRow_BGR(PColorBGRA(Source), SourceUpper, PColorBGR(Dest));
      Inc(Dest, DestBytesPerLine);
    end;
  end;

  procedure BGRA;
  var
    Y: Integer;
  begin
    for Y := 0 to AHeight - 1 do
    begin
      Stream.Read(Source^, SourceBytesPerLine);
      LazImage_CopyRow_BGRA(PColorBGRA(Source), SourceUpper, PColorBGRA(Dest));
      Inc(Dest, DestBytesPerLine);
    end;
  end;

  procedure ARGB;
  var
    Y: Integer;
  begin
    for Y := 0 to AHeight - 1 do
    begin
      Stream.Read(Source^, SourceBytesPerLine);
      LazImage_CopyRow_ARGB(PColorBGRA(Source), SourceUpper, PColorARGB(Dest));
      Inc(Dest, DestBytesPerLine);
    end;
  end;

  procedure SwapBuffers;
  var
    Temp: TBitmap;
  begin
    Temp := FImageBox.Background;
    FImageBox.Background := FBackBuffer;
    FBackBuffer := Temp;

    if AResize then
      SimbaDebugImageForm.SetSize(FImageBox.Background.Width, FImageBox.Background.Height, AEnsureVisible)
    else if AEnsureVisible then
      SimbaDebugImageForm.SetSize(-1, -1, True);

    FNeedRepaint := True;
  end;

begin
  FUpdating.Enter();
  try
    Source := nil;

    if (FBackBuffer = nil) then
      FBackBuffer := TBitmap.Create();
    FBackBuffer.BeginUpdate();
    try
      FBackBuffer.SetSize(AWidth, AHeight);

      DestBytesPerLine := FBackBuffer.RawImage.Description.BytesPerLine;
      Dest             := FBackBuffer.RawImage.Data;

      SourceBytesPerLine := AWidth * SizeOf(TColorBGRA);
      Source             := GetMem(SourceBytesPerLine);
      SourceUpper        := PtrUInt(Source + SourceBytesPerLine);

      case FImageBox.PixelFormat of
        ELazPixelFormat.BGR:  BGR();
        ELazPixelFormat.BGRA: BGRA();
        ELazPixelFormat.ARGB: ARGB();
        else
          SimbaException('Not supported');
      end;
    finally
      FBackBuffer.EndUpdate();
      if (Source <> nil) then
        FreeMem(Source);
    end;

    RunInMainThread(@SwapBuffers);
  finally
    FUpdating.Leave();
  end;
end;

procedure TSimbaDebugImageForm.UpdateFromStream(AWidth, AHeight: Integer; Stream: TStream);
begin
  UpdateFromStream(AWidth, AHeight, Stream, False, False);
end;

procedure TSimbaDebugImageForm.SetSize(AWidth, AHeight: Integer; AEnsureVisible: Boolean);
var
  Form: TCustomForm;
begin
  Form := TCustomForm(Self);
  if (HostDockSite is TSimbaAnchorDockHostSite) then
    Form := TSimbaAnchorDockHostSite(HostDockSite);

  if (AWidth > -1) and (AHeight > -1) then
  begin
    if (Form is TSimbaAnchorDockHostSite) and (TSimbaAnchorDockHostSite(Form).Header <> nil) then
    begin
      AHeight := AHeight + TSimbaAnchorDockHostSite(Form).Header.Height +
                           TSimbaAnchorDockHostSite(Form).Header.BorderSpacing.Top +
                           TSimbaAnchorDockHostSite(Form).Header.BorderSpacing.Bottom;
    end;
    AHeight := AHeight + FImageBox.StatusBar.Height;

    if (AWidth > Form.Width) then
      Form.Width := Min(AWidth, FMaxWidth);
    if (AHeight > Form.Height) then
      Form.Height := Min(AHeight, FMaxHeight);
  end;

  if AEnsureVisible then
    Form.EnsureVisible(True);
end;

procedure TSimbaDebugImageForm.SetMaxSize(AWidth, AHeight: Integer);
begin
  if (FMaxWidth = AWidth) and (FMaxHeight = AHeight) then
    Exit;

  if (HostDockSite is TSimbaAnchorDockHostSite) then
  begin
    FMaxWidth := AWidth;
    FMaxHeight := AHeight;

    if (HostDockSite.Width > FMaxWidth) then
      HostDockSite.Width := FMaxWidth;
    if (HostDockSite.Height > FMaxHeight) then
      HostDockSite.Height := FMaxHeight;
  end;
end;

end.

