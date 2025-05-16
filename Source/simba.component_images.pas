unit simba.component_images;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Graphics, Controls, ImgList, Types, Forms;

var
  SimbaComponentImages: TImageList;

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
  begin
    Result := TPortableNetworkGraphic.Create();
    Result.LoadFromStream(TResourceStream.Create(HINSTANCE, Name, RT_RCDATA));
  end;

begin
  SimbaComponentImages := TImageList.Create(Application);
  SimbaComponentImages.RegisterResolutions([16,24,32]);
  SimbaComponentImages.OnGetWidthForPPI := @SimbaComponentImages.DoWidthForPPI;
  SimbaComponentImages.AddMultipleResolutions([
    ImageFromResource('ARROW_RIGHT'),
    ImageFromResource('ARROW_RIGHT_150'),
    ImageFromResource('ARROW_RIGHT_200')
  ]);

  SimbaComponentImages.AddMultipleResolutions([
    ImageFromResource('ARROW_DOWN'),
    ImageFromResource('ARROW_DOWN_150'),
    ImageFromResource('ARROW_DOWN_200')
  ]);
end;

initialization
  CreateSimbaComponentImages();

end.

