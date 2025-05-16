{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)

  Images for components.
  Must be here so the components work in a script process since SimbaMainForm.Images wont be created
}
unit simba.component_images;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Graphics, Controls, ImgList, Types, Forms;

type
  TSimbaImageComponents = class(TImageList)
  public
    ARROW_RIGHT: Integer;
    ARROW_DOWN: Integer;
    TICK: Integer;
  end;

var
  SimbaComponentImages: TSimbaImageComponents;

implementation

uses
  simba.ide_initialization, simba.ide_utils;

type
  TImageListHelper = class helper for TImageList
    procedure DoWidthForPPI(Sender: TCustomImageList; AImageWidth, APPI: Integer; var AResultWidth: Integer);
  end;

procedure TImageListHelper.DoWidthForPPI(Sender: TCustomImageList; AImageWidth, APPI: Integer; var AResultWidth: Integer);
begin
  AResultWidth := ImageWidthForDPI(Screen.PixelsPerInch);
end;

procedure CreateSimbaComponentImages;

  function ImageFromResource(Name: String): TCustomBitmap;
  var
    Stream: TStream;
  begin
    Stream := TResourceStream.Create(HINSTANCE, Name, RT_RCDATA);
    try
      Result := TPortableNetworkGraphic.Create();
      Result.LoadFromStream(Stream);
    finally
      Stream.Free();
    end;
  end;

begin
  SimbaComponentImages := TSimbaImageComponents.Create(Application);
  SimbaComponentImages.RegisterResolutions([16,24,32]);
  SimbaComponentImages.OnGetWidthForPPI := @SimbaComponentImages.DoWidthForPPI;

  SimbaComponentImages.ARROW_RIGHT := SimbaComponentImages.AddMultipleResolutions([
    ImageFromResource('ARROW_RIGHT'),
    ImageFromResource('ARROW_RIGHT_150'),
    ImageFromResource('ARROW_RIGHT_200')
  ]);

  SimbaComponentImages.ARROW_DOWN := SimbaComponentImages.AddMultipleResolutions([
    ImageFromResource('ARROW_DOWN'),
    ImageFromResource('ARROW_DOWN_150'),
    ImageFromResource('ARROW_DOWN_200')
  ]);

  SimbaComponentImages.TICK := SimbaComponentImages.AddMultipleResolutions([
    ImageFromResource('TICK'),
    ImageFromResource('TICK_150'),
    ImageFromResource('TICK_200')
  ]);
end;

initialization
  CreateSimbaComponentImages();

end.

