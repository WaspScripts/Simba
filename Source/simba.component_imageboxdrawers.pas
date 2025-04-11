{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
  --------------------------------------------------------------------------
}
unit simba.component_imageboxdrawers;

{$DEFINE SIMBA_MAX_OPTIMIZATION}
{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base, simba.colormath;

const
  HEATMAP_TABLE: array[0..400] of TColor = (
    $B24C4C, $B34D4C, $B34E4C, $B34F4C, $B3504C, $B3514C, $B4524B, $B4524B, $B4534B, $B4544B, $B4554B, $B5564A, $B5574A, $B5584A, $B5594A, $B55A4A, $B65B49, $B65C49, $B65D49, $B65E49, $B65F49, $B76048, $B76148, $B76248, $B76348, $B76448, $B76548, $B86647, $B86747, $B86847,
    $B86947, $B86A47, $B96B46, $B96C46, $B96D46, $B96E46, $B96F46, $BA7045, $BA7245, $BA7345, $BA7445, $BA7545, $BB7644, $BB7744, $BB7844, $BB7A44, $BB7B44, $BB7C44, $BC7D43, $BC7E43, $BC7F43, $BC8143, $BC8243, $BD8342, $BD8442, $BD8642, $BD8742, $BD8842, $BE8941, $BE8B41,
    $BE8C41, $BE8D41, $BE8F41, $BF9040, $BF9140, $BF9340, $BF9440, $BF9540, $C0973F, $C0983F, $C0993F, $C09B3F, $C09C3F, $C09D3F, $C19F3E, $C1A03E, $C1A23E, $C1A33E, $C1A43E, $C2A63D, $C2A73D, $C2A93D, $C2AA3D, $C2AC3D, $C3AD3C, $C3AF3C, $C3B03C, $C3B23C, $C3B33C, $C4B53B,
    $C4B63B, $C4B83B, $C4B93B, $C4BB3B, $C4BC3B, $C5BE3A, $C5BF3A, $C5C13A, $C5C23A, $C5C43A, $C6C639, $C4C639, $C3C639, $C2C639, $C1C639, $BFC738, $BEC738, $BDC738, $BCC738, $BAC738, $B9C837, $B8C837, $B7C837, $B5C837, $B4C837, $B3C837, $B1C936, $B0C936, $AFC936, $ADC936,
    $ACC936, $ABCA35, $A9CA35, $A8CA35, $A6CA35, $A5CA35, $A4CB34, $A2CB34, $A1CB34, $9FCB34, $9ECB34, $9CCC33, $9BCC33, $99CC33, $98CC33, $97CC33, $95CD32, $94CD32, $92CD32, $91CD32, $8FCD32, $8ECD32, $8CCE31, $8ACE31, $89CE31, $87CE31, $86CE31, $84CF30, $83CF30, $81CF30,
    $80CF30, $7ECF30, $7CD02F, $7BD02F, $79D02F, $77D02F, $76D02F, $74D12E, $73D12E, $71D12E, $6FD12E, $6ED12E, $6CD12E, $6AD22D, $68D22D, $67D22D, $65D22D, $63D22D, $62D32C, $60D32C, $5ED32C, $5CD32C, $5BD32C, $59D42B, $57D42B, $55D42B, $53D42B, $52D42B, $50D52A, $4ED52A,
    $4CD52A, $4AD52A, $49D52A, $47D52A, $45D629, $43D629, $41D629, $3FD629, $3DD629, $3CD728, $3AD728, $38D728, $36D728, $34D728, $32D827, $30D827, $2ED827, $2CD827, $2AD827, $28D926, $26D926, $26D928, $26D929, $26D92B, $25DA2D, $25DA2E, $25DA30, $25DA32, $25DA33, $25DA35,
    $24DB37, $24DB38, $24DB3A, $24DB3C, $24DB3D, $23DC3F, $23DC41, $23DC42, $23DC44, $23DC46, $22DD48, $22DD49, $22DD4B, $22DD4D, $22DD4F, $21DE50, $21DE52, $21DE54, $21DE56, $21DE58, $21DE5A, $20DF5B, $20DF5D, $20DF5F, $20DF61, $20DF63, $1FE065, $1FE066, $1FE068, $1FE06A,
    $1FE06C, $1EE16E, $1EE170, $1EE172, $1EE174, $1EE176, $1DE278, $1DE27A, $1DE27C, $1DE27E, $1DE27F, $1CE381, $1CE383, $1CE385, $1CE387, $1CE389, $1CE38B, $1BE48E, $1BE490, $1BE492, $1BE494, $1BE496, $1AE598, $1AE59A, $1AE59C, $1AE59E, $1AE5A0, $19E6A2, $19E6A4, $19E6A6,
    $19E6A9, $19E6AB, $18E7AD, $18E7AF, $18E7B1, $18E7B3, $18E7B5, $18E7B8, $17E8BA, $17E8BC, $17E8BE, $17E8C0, $17E8C3, $16E9C5, $16E9C7, $16E9C9, $16E9CC, $16E9CE, $15EAD0, $15EAD2, $15EAD5, $15EAD7, $15EAD9, $14EBDC, $14EBDE, $14EBE0, $14EBE3, $14EBE5, $14EBE7, $13ECEA,
    $13ECEC, $13EAEC, $13E8EC, $13E6EC, $12E4ED, $12E2ED, $12E0ED, $12DEED, $12DCED, $11DAEE, $11D8EE, $11D6EE, $11D4EE, $11D2EE, $10CFEF, $10CDEF, $10CBEF, $10C9EF, $10C7EF, $0FC5F0, $0FC3F0, $0FC1F0, $0FBFF0, $0FBCF0, $0FBAF0, $0EB8F1, $0EB6F1, $0EB4F1, $0EB2F1, $0EAFF1,
    $0DADF2, $0DABF2, $0DA9F2, $0DA6F2, $0DA4F2, $0CA2F3, $0CA0F3, $0C9EF3, $0C9BF3, $0C99F3, $0B97F4, $0B94F4, $0B92F4, $0B90F4, $0B8EF4, $0B8BF4, $0A89F5, $0A87F5, $0A84F5, $0A82F5, $0A80F5, $097DF6, $097BF6, $0978F6, $0976F6, $0974F6, $0871F7, $086FF7, $086CF7, $086AF7,
    $0868F7, $0765F8, $0763F8, $0760F8, $075EF8, $075BF8, $0759F8, $0656F9, $0654F9, $0651F9, $064FF9, $064CF9, $054AFA, $0547FA, $0545FA, $0542FA, $0540FA, $043DFB, $043AFB, $0438FB, $0435FB, $0433FB, $0330FC, $032DFC, $032BFC, $0328FC, $0326FC, $0223FD, $0220FD, $021EFD,
    $021BFD, $0218FD, $0216FD, $0113FE, $0110FE, $010EFE, $010BFE, $0108FE, $0005FF, $0003FF, $0000FF
  );
  HEATMAP_LOOKUP = Single(100 * High(HEATMAP_TABLE) / 100);

type
  TDrawInfo = record
    Color: TColor;
    Data: PByte;
    BytesPerLine: Integer;
    Width: Integer;
    Height: Integer;
    VisibleRect: TRect;
    Offset: TPoint;
  end;

generic procedure DoDrawPoints<_T>(TPA: TPointArray; DrawInfo: TDrawInfo);
generic procedure DoDrawLine<_T>(Start, Stop: TPoint; DrawInfo: TDrawInfo);
generic procedure DoDrawLineGap<_T>(Start, Stop: TPoint; GapSize: Integer; DrawInfo: TDrawInfo);
generic procedure DoDrawBoxEdge<_T>(Box: TBox; DrawInfo: TDrawInfo);
generic procedure DoDrawBoxFilled<_T>(Box: TBox; DrawInfo: TDrawInfo);
generic procedure DoDrawBoxFilledEx<_T>(Box: TBox; Transparency: Single; DrawInfo: TDrawInfo);
generic procedure DoDrawCircle<_T>(Center: TPoint; Radius: Integer; DrawInfo: TDrawInfo);
generic procedure DoDrawCircleFilled<_T>(Center: TPoint; Radius: Integer; DrawInfo: TDrawInfo);
generic procedure DoDrawPolygonFilled<_T>(Poly: TPointArray; DrawInfo: TDrawInfo);
generic procedure DoDrawHeatmap<_T>(Mat: TSingleMatrix; DrawInfo: TDrawInfo);

implementation

uses
  Math,
  simba.vartype_matrix, simba.array_algorithm, simba.vartype_box;

generic procedure DoDrawPoints<_T>(TPA: TPointArray; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;
  I, X, Y: Integer;
begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  for I := 0 to High(TPA) do
  begin
    X := TPA[I].X + DrawInfo.Offset.X;
    Y := TPA[I].Y + DrawInfo.Offset.Y;
    if (X >= 0) and (Y >= 0) and (X < DrawInfo.Width) and (Y < DrawInfo.Height) then
      PType(DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X * SizeOf(_T)))^ := Color;
  end;
end;

generic procedure DoDrawLine<_T>(Start, Stop: TPoint; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;

  procedure _Pixel(const X, Y: Integer); inline;
  begin
    if (X >= 0) and (Y >= 0) and (X < DrawInfo.Width) and (Y < DrawInfo.Height) then
      PType(DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X * SizeOf(_T)))^ := Color;
  end;

  {$i shapebuilder_line.inc}

begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  _BuildLine(Start, Stop);
end;

generic procedure DoDrawLineGap<_T>(Start, Stop: TPoint; GapSize: Integer; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;

  procedure _Pixel(const X, Y: Integer); inline;
  begin
    if (X >= 0) and (Y >= 0) and (X < DrawInfo.Width) and (Y < DrawInfo.Height) then
      PType(DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X * SizeOf(_T)))^ := Color;
  end;

  {$i shapebuilder_linegap.inc}

begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  _BuildLineGap(Start, Stop, GapSize);
end;

generic procedure DoDrawBoxEdge<_T>(Box: TBox; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;

  procedure _Pixel(const X, Y: Integer); inline;
  begin
    if (X >= 0) and (Y >= 0) and (X < DrawInfo.Width) and (Y < DrawInfo.Height) then
      PType(DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X * SizeOf(_T)))^ := Color;
  end;

  procedure _Row(Y: Integer; X1, X2: Integer);
  var
    Ptr: PByte;
    Upper: PtrUInt;
  begin
    if (Y >= 0) and (Y < DrawInfo.Height) then
    begin
      X1 := EnsureRange(X1, 0, DrawInfo.Width - 1);
      X2 := EnsureRange(X2, 0, DrawInfo.Width - 1);

      if ((X2 - X1) + 1 > 0) then
      begin
        Ptr := DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X1 * SizeOf(_T));
        Upper := PtrUInt(Ptr) + ((X2 - X1) * SizeOf(_T));
        while (PtrUInt(Ptr) <= Upper) do
        begin
          PType(Ptr)^ := Color;

          Inc(Ptr, SizeOf(_T));
        end;
      end;
    end;
  end;

  {$i shapebuilder_boxedge.inc}

begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  _BuildBoxEdge(Box);
end;

generic procedure DoDrawBoxFilled<_T>(Box: TBox; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;

  procedure _Row(Y: Integer; X1, X2: Integer);
  var
    Ptr: PByte;
    Upper: PtrUInt;
  begin
    if (Y >= 0) and (Y < DrawInfo.Height) then
    begin
      X1 := EnsureRange(X1, 0, DrawInfo.Width - 1);
      X2 := EnsureRange(X2, 0, DrawInfo.Width - 1);

      if ((X2 - X1) + 1 > 0) then
      begin
        Ptr := DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X1 * SizeOf(_T));
        Upper := PtrUInt(Ptr) + ((X2 - X1) * SizeOf(_T));
        while (PtrUInt(Ptr) <= Upper) do
        begin
          PType(Ptr)^ := Color;

          Inc(Ptr, SizeOf(_T));
        end;
      end;
    end;
  end;

  {$i shapebuilder_boxfilled.inc}

begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  _BuildBoxFilled(Box);
end;

generic procedure DoDrawBoxFilledEx<_T>(Box: TBox; Transparency: Single; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  RMod, GMod, BMod: Single;
  Size, Y: Integer;
  Ptr: PByte;
  Upper: PtrUInt;
begin
  RMod := DrawInfo.Color.R * Transparency;
  GMod := DrawInfo.Color.G * Transparency;
  BMod := DrawInfo.Color.B * Transparency;
  Transparency := 1.0 - Transparency;

  Size := Box.Width * SizeOf(_T);
  for Y := Box.Y1 to Box.Y2 do
  begin
    Ptr := DrawInfo.Data + (Y * DrawInfo.BytesPerLine + Box.X1 * SizeOf(_T));
    Upper := PtrUInt(Ptr + Size);
    while (PtrUInt(Ptr) < Upper) do
      with PType(Ptr)^ do
      begin
        R := Byte(Round((R * Transparency) + RMod));
        G := Byte(Round((G * Transparency) + GMod));
        B := Byte(Round((B * Transparency) + BMod));

        Inc(Ptr, SizeOf(_T));
      end;
  end;
end;

generic procedure DoDrawCircle<_T>(Center: TPoint; Radius: Integer; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;

  procedure _Pixel(const X, Y: Integer); inline;
  begin
    if (X >= 0) and (Y >= 0) and (X < DrawInfo.Width) and (Y < DrawInfo.Height) then
      PType(DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X * SizeOf(_T)))^ := Color;
  end;

  {$i shapebuilder_circle.inc}

begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  _BuildCircle(Center.X, Center.Y, Radius);
end;

generic procedure DoDrawCircleFilled<_T>(Center: TPoint; Radius: Integer; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;

  procedure _Row(Y: Integer; X1, X2: Integer);
  var
    Ptr: PByte;
    Upper: PtrUInt;
  begin
    if (Y >= 0) and (Y < DrawInfo.Height) then
    begin
      X1 := EnsureRange(X1, 0, DrawInfo.Width - 1);
      X2 := EnsureRange(X2, 0, DrawInfo.Width - 1);

      if ((X2 - X1) + 1 > 0) then
      begin
        Ptr := DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X1 * SizeOf(_T));
        Upper := PtrUInt(Ptr) + ((X2 - X1) * SizeOf(_T));
        while (PtrUInt(Ptr) < Upper) do
        begin
          PType(Ptr)^ := Color;

          Inc(Ptr, SizeOf(_T));
        end;
      end;
    end;
  end;

  {$i shapebuilder_circlefilled.inc}

begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  _BuildCircleFilled(Center.X, Center.Y, Radius);
end;

generic procedure DoDrawPolygonFilled<_T>(Poly: TPointArray; DrawInfo: TDrawInfo);
type
  PType = ^_T;
var
  Color: _T;

  procedure _Row(Y: Integer; X1, X2: Integer);
  var
    Ptr: PByte;
    Upper: PtrUInt;
  begin
    if (Y >= 0) and (Y < DrawInfo.Height) then
    begin
      X1 := EnsureRange(X1, 0, DrawInfo.Width - 1);
      X2 := EnsureRange(X2, 0, DrawInfo.Width - 1);

      if ((X2 - X1) + 1 > 0) then
      begin
        Ptr := DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X1 * SizeOf(_T));
        Upper := PtrUInt(Ptr) + ((X2 - X1) * SizeOf(_T));
        while (PtrUInt(Ptr) <= Upper) do
        begin
          PType(Ptr)^ := Color;

          Inc(Ptr, SizeOf(_T));
        end;
      end;
    end;
  end;

  {$i shapebuilder_polygonfilled.inc}

begin
  Color := Default(_T);
  Color.R := DrawInfo.Color.R;
  Color.G := DrawInfo.Color.G;
  Color.B := DrawInfo.Color.B;

  _BuildPolygonFilled(Poly, TRect.Create(0,0,DrawInfo.Width-1, DrawInfo.Height-1), DrawInfo.Offset);
end;

generic procedure DoDrawHeatmap<_T>(Mat: TSingleMatrix; DrawInfo: TDrawInfo);
type
  PType = ^_T;

  procedure _Pixel(const X, Y: Integer; const Color: TColor); inline;
  begin
    // Should already be clipped
    // if (X >= 0) and (Y >= 0) and (X < DrawInfo.Width) and (Y < DrawInfo.Height) then
    with PType(DrawInfo.Data + (Y * DrawInfo.BytesPerLine + X * SizeOf(_T)))^ do
    begin
      R := Color shr R_BIT and $FF;
      G := Color shr G_BIT and $FF;
      B := Color shr B_BIT and $FF;
    end;
  end;

var
  X, Y: Integer;
  B: TBox;
begin
  B.X1 := DrawInfo.VisibleRect.Left;
  B.Y1 := DrawInfo.VisibleRect.Top;
  B.X2 := Min(Min(B.X1 + Mat.Width, Mat.Width) - 1, DrawInfo.VisibleRect.Right - 1);
  B.Y2 := Min(Min(B.Y1 + Mat.Height, Mat.Height) - 1, DrawInfo.VisibleRect.Bottom - 1);

  for Y := B.Y1 to B.Y2 do
    for X := B.X1 to B.X2 do
      _Pixel(X + DrawInfo.Offset.X, Y + DrawInfo.Offset.Y, HEATMAP_TABLE[Round(Mat[Y, X] * HEATMAP_LOOKUP)]);
end;

end.

