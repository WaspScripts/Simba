{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.image_drawmatrix;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base,
  simba.image,
  simba.image_utils,
  simba.colormath,
  simba.colormath_conversion,
  simba.vartype_matrix;

procedure SimbaImage_FromMatrix(Image: TSimbaImage; Matrix: TSingleMatrix; ColorMapType: Integer = 0); overload;
procedure SimbaImage_FromMatrix(Image: TSimbaImage; Matrix: TIntegerMatrix); overload;

// For use of less accurate (less colors available) FromMatrix with ColorMapType=0 but much faster
// Value must be 0..1 and is referenced to HeatmapTable
function GetHeapmapColor(const Value: Single): TColor; inline;

var
  HeatmapTable: array[0..500] of TColor;

implementation

procedure SimbaImage_FromMatrix(Image: TSimbaImage; Matrix: TSingleMatrix; ColorMapType: Integer);
var
  Width, Height, X, Y: Integer;
  Normed: TSingleMatrix;
  HSL: TColorHSL;
begin
  Matrix.GetSize(Width, Height);
  Image.SetSize(Width, Height);

  Normed := Matrix.NormMinMax(0, 1);
  Dec(Width);
  Dec(Height);

  for Y := 0 to Height do
    for X := 0 to Width do
    begin
      case ColorMapType of
        0:begin //cold blue to red
            HSL.H := (1 - Normed[Y, X]) * 240;
            HSL.S := 40 + Normed[Y, X] * 60;
            HSL.L := 50;
          end;
        1:begin //black -> blue -> red
            HSL.H := (1 - Normed[Y, X]) * 240;
            HSL.S := 100;
            HSL.L := Normed[Y, X] * 50;
          end;
        2:begin //white -> blue -> red
            HSL.H := (1 - Normed[Y, X]) * 240;
            HSL.S := 100;
            HSL.L := 100 - Normed[Y, X] * 50;
          end;
        3:begin //Light (to white)
            HSL.H := 0;
            HSL.L := (1 - Normed[Y, X]) * 100;
            HSL.S := 0;
          end;
        4:begin //Light (to black)
            HSL.H := 0;
            HSL.L := Normed[Y, X] * 100;
            HSL.S := 0;
          end;
        else
          begin //Custom black to hue to white
            HSL.H := ColorMapType;
            HSL.S := 100;
            HSL.L := Normed[Y, X] * 100;
          end;
      end;

      Image.Data[Y * Image.Width + X] := TSimbaColorConversion.ColorToBGRA(HSL.ToColor(), ALPHA_OPAQUE);
    end;
end;

procedure SimbaImage_FromMatrix(Image: TSimbaImage; Matrix: TIntegerMatrix);
var
  X, Y, Width, Height: Integer;
begin
  Matrix.GetSize(Width, Height);
  Image.SetSize(Width, Height);

  Dec(Width);
  Dec(Height);
  for Y := 0 to Height do
    for X := 0 to Width do
      Image.Data[Y * Image.Width + X] := TSimbaColorConversion.ColorToBGRA(Matrix[Y, X], ALPHA_OPAQUE);
end;

function GetHeapmapColor(const Value: Single): TColor;
begin
  if (Value >= 0) and (Value <= 1.0) then
  begin
    Assert(Round(Value * High(HeatmapTable)) < Length(HeatmapTable));
    Result := HeatmapTable[Round(Value * High(HeatmapTable))]; // float value to heatmaptable index
  end else
    Result := $FFFFFF; // return white, should stick out as a error since value must be within 0..1
end;

procedure BuildHeatmapTable;
var
  I: Integer;
  Val: Single;
  HSL: TColorHSL;
begin
  I := 0;
  Val := 0.0;
  while (Val <= 1) and (I < Length(HeatmapTable)) do
  begin
    HSL.H := (1 - Val) * 240;
    HSL.S := 40 + Val * 60;
    HSL.L := 50;
    HeatmapTable[I] := HSL.ToColor;
    Inc(I);

    Val += 0.002; // will obv need tweaking depending on heatmap table size
  end;
  Assert(I = Length(HeatmapTable));
end;

initialization
  BuildHeatmapTable();

end.

