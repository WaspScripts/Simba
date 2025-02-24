{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
  --------------------------------------------------------------------------

  Simple crude pixel font ocr. "Pixel font" being "block text/zero antialiasing" and completely fixed font set.
  Every pixel of the glyph must match for for a character to be recognized.

  Orginally was SimpleOCR found at https://github.com/ollydev/SimpleOCR
}
unit simba.pixelocr;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base,
  simba.image;

type
  TPixelFontGlyph = record
    Value: Char;

    Width: Int16;  // image width
    Height: Int16; // image Height
    ForegroundBounds: TBox;  // foreground meaning points and Shadow

    Points: TPointArray;      // character "white pixels" (note: x axis is offset from the image to not have background padding)
    Shadow: TPointArray;      // optional Shadow "red pixels" (note: x axis is offset from the image to not have background padding)
    Background: TPointArray;  // background "black pixels" (note:
    PointsShadowWidth: Int16; // width of points+Shadow

    BestMatch: Int16; // best possible match
  end;
  PPixelFontGlyph = ^TPixelFontGlyph;

  TPixelFont = record
    Glyphs: array of TPixelFontGlyph;
    SpaceWidth: Integer;
    MaxGlyphWidth: Integer;
    MaxGlyphHeight: Integer;
  end;
  PPixelFont = ^TPixelFont;

  TPixelOCRMatch = record
    Text: String;
    Hits: Integer;
    Bounds: TBox;
  end;

  TPixelOCR = record
    Tolerance: Single;
    ShadowTolerance: Single;
    Whitelist: set of Char;
    MaxWalk: Integer;
    MaxLen: Integer;
    Matches: array of TPixelOCRMatch;
  private
    function _RecognizeX(const Image: TSimbaImage; const Font: PPixelFont; X, Y: Integer; const isBinary: Boolean): TPixelOCRMatch;
    function _RecognizeXY(const Image: TSimbaImage; const Font: PPixelFont; X, Y, Height: Integer; const isBinary: Boolean): TPixelOCRMatch;
  public
    function LoadFont(Dir: String; SpaceWidth: Integer): TPixelFont;
    function TextToTPA(Font: TPixelFont; Text: String): TPointArray;
    function Locate(Image: TSimbaImage; constref Font: TPixelFont; Text: String): Single;

    function Recognize(Image: TSimbaImage; constref Font: TPixelFont; p: TPoint): String; overload;
    function Recognize(Image: TSimbaImage; constref Font: TPixelFont; Bounds: TBox): String; overload;
    function RecognizeLines(Image: TSimbaImage; constref Font: TPixelFont; Bounds: TBox): TStringArray;
  end;

const
  ALPHA_NUM_SYMBOLS = ['a'..'z', 'A'..'Z', '0'..'9', '%', '&', '#', '$', '[', ']', '{', '}', '@', '!', '?'];

implementation

uses
  simba.vartype_string,
  simba.vartype_box,
  simba.vartype_pointarray,
  simba.fs;

function IsSimilar(const Image: TSimbaImage; const X, Y: Integer; const Color2: TColorBGRA; const Tol: Single): Boolean; inline;
const
  MAX_DISTANCE_RGB = Single(441.672955930064); // Sqrt(Sqr(255) + Sqr(255) + Sqr(255))
begin
  with Image.Data[Y * Image.Width + X] do
    Result := (Sqrt(Sqr(R-Color2.R) + Sqr(G-Color2.G) + Sqr(B-Color2.B)) / MAX_DISTANCE_RGB * 100) <= Tol
end;

function IsShadow(const Image: TSimbaImage; const X, Y: Integer; const Tol: Single): Boolean; inline;
begin
  with Image.Data[Y * Image.Width + X] do
    Result := (R <= Tol) and (G <= Tol) and (B <= Tol + 5); // allow a little more in the blue channel only
end;

function GetGlyph(const Font: PPixelFont; const c: Char): PPixelFontGlyph; inline;
var
  I: Integer;
begin
  for I := 0 to High(Font^.Glyphs) do
    if (Font^.Glyphs[I].Value = c) then
      Exit(@Font^.Glyphs[I]);

  SimbaException('Character %s does exist in the Font', [c]);
  Result := nil;
end;

function ContainsAlphaNumSym(const Text: string): Boolean; inline;
var
  I: Integer;
begin
  for I := 1 to Length(Text) do
    if Text[I] in ALPHA_NUM_SYMBOLS then
      Exit(True);

  Result := False;
end;

function TPixelOCR._RecognizeX(const Image: TSimbaImage; const Font: PPixelFont; X, Y: Integer; const isBinary: Boolean): TPixelOCRMatch;

  function CompareUsingBackground(const Glyph: PPixelFontGlyph; const X, Y: Integer): Integer; inline;
  var
    FirstPixel: TColorBGRA;
    I, Misses, Bad: Integer;
  begin
     case isBinary of
       True:
         begin
           // binary is simple, check all points are white
           for I := 0 to High(Glyph^.Points) do
             with Image.Data[(Glyph^.Points[I].Y + Y) * Image.Width + (Glyph^.Points[I].X + X)] do
               if (B <> 255) or (G <> 255) or (R <> 255) then
                 Exit(-1);

           // then deduct background points that are white
           // if < 50% its not a match.
           Bad := High(Glyph^.Background) div 2;
           Misses := 0;
           for I := 0 to High(Glyph^.Background) do
             with Image.Data[(Glyph^.Background[I].Y + Y) * Image.Width + (Glyph^.Background[I].X + X)] do
               if (B <> 0) or (G <> 0) or (R <> 0) then
               begin
                 Inc(Misses);
                 if (Misses > Bad) then
                   Exit(-1);
               end;
         end;

       False:
         begin
           // check all points match the first point color
           FirstPixel := Image.Data[(Glyph^.Points[0].Y + Y) * Image.Width + (Glyph^.Points[0].X + X)];
           for I := 1 to High(Glyph^.Points) do
             if not IsSimilar(Image, Glyph^.Points[I].X + X, Glyph^.Points[I].Y + Y, FirstPixel, Tolerance) then
               Exit(-1);

           // then deduct background points that match the first point color
           // if < 50% its not a match.
           Bad := High(Glyph^.Background) div 2;
           Misses := 0;
           for I := 0 to High(Glyph^.Background) do
             if IsSimilar(Image, Glyph^.Background[I].X + X, Glyph^.Background[I].Y + Y, FirstPixel, Tolerance) then
             begin
               Inc(Misses);
               if (Misses > Bad) then
                 Exit(-1);
             end;
         end;
     end;

     Result := Glyph^.BestMatch - Misses;
  end;

  function CompareUsingShadow(const Glyph: PPixelFontGlyph; const X, Y: Integer): Integer; inline;
  var
    FirstPixel: TColorBGRA;
    I: Integer;
  begin
    case isBinary of
      True:
        begin
          // binary is simple - check all points are white
          for I := 0 to High(Glyph^.Points) do
            with Image.Data[(Glyph^.Points[I].Y + Y) * Image.Width + (Glyph^.Points[I].X + X)] do
              if (B <> 255) or (G <> 255) or (R <> 255) then
                Exit(-1);

          // and shadows are 0
          for I := 0 to High(Glyph^.Shadow) do
            with Image.Data[(Glyph^.Shadow[I].Y + Y) * Image.Width + (Glyph^.Shadow[I].X + X)] do
              if (B <> 0) or (G <> 0) or (R <> 0) then
                Exit(-1);
        end;

      False:
        begin
          // if the first pixel is a dark'ish color its a non starter
          if IsShadow(Image, Glyph^.Points[0].X + X, Glyph^.Points[0].Y + Y, Self.shadowTolerance * 2) then
            Exit(-1);

          // check all shadows are shadows
          for I := 0 to High(Glyph^.Shadow) do
            if not IsShadow(Image, Glyph^.Shadow[I].X + X, Glyph^.Shadow[I].Y + Y, self.shadowTolerance) then
              Exit(-1);

          // Always use first pixel to compare against
          FirstPixel := Image.Data[(Glyph^.Points[0].Y + Y) * Image.Width + (Glyph^.Points[0].X + X)];
          // check all other Points match the first pixel
          for I := 1 to High(Glyph^.Points) do
            if not IsSimilar(Image, Glyph^.Points[I].X + X, Glyph^.Points[I].Y + Y, FirstPixel, Tolerance) then
              Exit(-1);
        end;
    end;

    Result := Glyph^.BestMatch;
  end;

var
  Space: Integer;
  Hits, BestHits: Integer;
  Lo, Hi: PPixelFontGlyph;
  Glyph, BestGlyph: PPixelFontGlyph;
begin
  Result := Default(TPixelOCRMatch);
  Result.Bounds.X1 := $FFFFFF;
  Result.Bounds.Y1 := $FFFFFF;
  Space := 0;

  if (X < 0) then X := 0;
  if (Y < 0) then Y := 0;

  Lo := @Font^.Glyphs[0];
  Hi := @Font^.Glyphs[High(Font^.Glyphs)];

  while (X < Image.Width) and ((MaxWalk = 0) or (Space < MaxWalk)) do
  begin
    BestHits := 0;

    Glyph := Lo;
    while (PtrUInt(Glyph) <= PtrUInt(Hi)) do
    begin
      if (Glyph^.Points <> nil) and (X + Glyph^.PointsShadowWidth < Image.Width) and (Y + Glyph^.Height < Image.Height) then
      begin
        if (Glyph^.Shadow <> nil) then
          Hits := CompareUsingShadow(Glyph, X, Y)
        else
          Hits := CompareUsingBackground(Glyph, X, Y);

        if (Hits > BestHits) then
        begin
          BestGlyph := Glyph;
          BestHits := Hits;
        end;
      end;

      Inc(Glyph);
    end;

    if (BestHits > 0) then
    begin
      if ((WhiteList = []) or (BestGlyph^.Value in Self.Whitelist)) then
      begin
        if (Result.Text <> '') and (Space >= Font^.SpaceWidth) then
          Result.Text += ' ';

        with Result.Bounds do
        begin
          X1 := Min(X1, X);
          Y1 := Min(Y1, Y + BestGlyph^.ForegroundBounds.Y1);
          X2 := Max(X2, X + BestGlyph^.PointsShadowWidth);
          Y2 := Max(Y2, Y + BestGlyph^.ForegroundBounds.Y2);
        end;

        Result.Text += BestGlyph^.Value;
        Result.Hits += BestHits;

        if (MaxLen >= Length(Result.Text)) then
          Exit;
      end;

      Space := 0;
      X += BestGlyph^.PointsShadowWidth;
    end else
    begin
      Space += 1;
      X += 1;
    end;
  end;
end;

function TPixelOCR._RecognizeXY(const Image: TSimbaImage; const Font: PPixelFont; X, Y, Height: Integer; const isBinary: Boolean): TPixelOCRMatch;
var
  Stop: Integer;
  Match: TPixelOCRMatch;
begin
  Result := Default(TPixelOCRMatch);

  Stop := Y + Height;
  while (Y < Stop) do
  begin
    Match := Self._RecognizeX(Image, Font, X, Y, isBinary);
    if (Match.Hits > Result.Hits) then
      Result := Match;

    Y += 1;
  end;
end;

function TPixelOCR.LoadFont(Dir: String; SpaceWidth: Integer): TPixelFont;
var
  Image: TSimbaImage;
  Files: TStringArray;
  I: Integer;
  Character: String;
  Glyph: TPixelFontGlyph;
  B: TBox;
begin
  Result := Default(TPixelFont);
  Result.SpaceWidth := SpaceWidth;

  Files := TSimbaDir.DirList(dir);
  if (Length(Files) = 0) then
    Exit;

  SetLength(Result.Glyphs, Length(Files));

  Image := TSimbaImage.Create();
  try
    for I := 0 to High(Files) do
    begin
      if not TSimbaPath.PathHasExt(Files[I], ['.bmp', '.png']) then
        Continue;

      Character := TSimbaPath.PathExtractNameWithoutExt(Files[I]);
      if Character.IsNumeric and (Character.ToInt >= 32) and (Character.ToInt <= 126) then
      begin
        Image.Load(Files[I]);

        Glyph := Default(TPixelFontGlyph);
        Glyph.Value := Char(Character.ToInt);
        Glyph.Width := Image.Width;
        Glyph.Height := Image.Height;
        if (Glyph.Value > #32) then // not a space
        begin
          Glyph.Points := Image.FindColor($FFFFFF);
          Glyph.Shadow := Image.FindColor($0000FF);
          Glyph.ForegroundBounds := TPointArray(Glyph.Points + Glyph.Shadow).Bounds;

          B := Glyph.Points.Bounds;
          if (B.X1 > 0) then
          begin
            Glyph.Points := Glyph.Points.Offset(-B.X1, 0);
            Glyph.Shadow := Glyph.Shadow.Offset(-B.X1, 0);
          end;
          B := TPointArray(Glyph.Points + Glyph.Shadow).Bounds;

          Glyph.Background := TPointArray(Glyph.Points + Glyph.Shadow).Invert(B.Expand(1));
          Glyph.PointsShadowWidth := B.Width;
          if (Length(Glyph.Shadow) > 0) then
            Glyph.BestMatch := Length(Glyph.Points) + Length(Glyph.Shadow)
          else
            Glyph.BestMatch := Length(Glyph.Points) + Length(Glyph.Background);

          Result.MaxGlyphWidth := Max(Result.MaxGlyphWidth, Glyph.Width);
          Result.MaxGlyphHeight := Max(Result.MaxGlyphHeight, Glyph.Height);
        end;

        Result.Glyphs += [Glyph];
      end;
    end;
  finally
    Image.Free();
  end;
end;

function TPixelOCR.TextToTPA(Font: TPixelFont; Text: String): TPointArray;
var
  I, J, X, Count, OffsetY: Integer;
begin
  X := 0;
  Count := 0;
  OffsetY := $FFFFFF;
  for I := 1 to Length(Text) do
    with GetGlyph(@Font, Text[I])^ do
    begin
      Inc(Count, Length(Points));
      OffsetY := Min(ForegroundBounds.Y1, OffsetY);
    end;
  SetLength(Result, Count);

  Count := 0;
  for I := 1 to Length(Text) do
    with GetGlyph(@Font, Text[I])^ do
    begin
      for J := 0 to High(Points) do
      begin
        Result[Count].X := Points[J].X + (X + ForegroundBounds.X1);
        Result[Count].Y := Points[J].Y - OffsetY;
        Inc(Count);
      end;
      Inc(X, Width);
    end;
end;

function TPixelOCR.Locate(Image: TSimbaImage; constref Font: TPixelFont; Text: String): Single;
var
  X, Y: Integer;
  SearchWidth, SearchHeight: Integer;
  Bad, I: Integer;
  Match: Single;
  BestMatch: TPixelOCRMatch;
  First: TColorBGRA;
  Points, Background: TPointArray;
label
  NotFound, Finished;
begin
  Result := 0;

  Points := TextToTPA(Font, Text);
  Background := Points.Invert();
  if (Length(Points) = 0) or (Length(Background) = 0) then
    Exit;

  SearchHeight := Image.Height - Background.Bounds.Height;
  SearchWidth := Image.Width - Background.Bounds.Width;

  for Y := 0 to SearchHeight do
    for X := 0 to SearchWidth do
    begin
      First := Image.Data[(Y + Points[0].Y) * Image.Width + (X + Points[0].X)];
      for I := 1 to High(Points) do
        if (not IsSimilar(Image, X + Points[I].X, Y + Points[I].Y, First, Tolerance)) then
          goto NotFound;

      Bad := 0;
      for I := 0 to High(Background) do
        if IsSimilar(Image, X + Background[I].X, Y + Background[I].Y, First, Tolerance) then
          Inc(Bad);

      Match := 1 - (Bad / Length(Background));
      if (Match > Result) then
      begin
        Result := Match;

        BestMatch.Bounds.X1 := X;
        BestMatch.Bounds.Y1 := Y;

        if (Result = 1) then
          goto Finished;
      end;

      NotFound:
    end;
  Finished:

  BestMatch.Hits := Round(Result * 100);
  BestMatch.Text := Text;
  BestMatch.Bounds.X2 := BestMatch.Bounds.X1 + Points.Bounds.Width;
  BestMatch.Bounds.Y2 := BestMatch.Bounds.Y1 + Points.Bounds.Height;

  Matches := [BestMatch];
end;

function TPixelOCR.Recognize(Image: TSimbaImage; constref Font: TPixelFont; p: TPoint): String; overload;
begin
  if (Length(Font.Glyphs) = 0) then
    SimbaException('Font is empty');

  Matches := [Self._RecognizeX(Image, @Font, p.X, p.Y, Image.isBinary)];
  Result := Matches[0].Text;
end;

function TPixelOCR.Recognize(Image: TSimbaImage; constref Font: TPixelFont; Bounds: TBox): String; overload;
begin
  if (Length(Font.Glyphs) = 0) then
    SimbaException('Font is empty');

  Matches := [Self._RecognizeXY(Image, @Font, Bounds.X1, Bounds.Y1, Bounds.Height, Image.isBinary)];
  Result := Matches[0].Text;
end;

function TPixelOCR.RecognizeLines(Image: TSimbaImage; constref Font: TPixelFont; Bounds: TBox): TStringArray;

  function MaybeRecognize(const X, Y: Integer; const isBinary: Boolean; out Match: TPixelOCRMatch): Boolean;
  var
    Temp: TPixelOCR;
  begin
    Result := False;

    // use a copy here since we change these properties
    Temp := Self;
    Temp.Whitelist := ALPHA_NUM_SYMBOLS;
    Temp.MaxLen := 1;
    Temp.MaxWalk := 0;

    // Find something on a row that isn't a small character
    Match := Temp._RecognizeX(Image, @Font, X, Y, isBinary);
    if (Match.Hits > 0) then
    begin
      // OCR the row and some extra rows
      Temp.Whitelist := Self.Whitelist;
      Temp.MaxWalk := 0;
      Temp.MaxLen := 0;

      Match := Temp._RecognizeXY(Image, @Font, X, Y, Font.MaxGlyphHeight div 2, isBinary);
      // Ensure that actual Text was extracted, not just a symbol mess of short or small character symbols.
      if ContainsAlphaNumSym(Match.Text) then
        Result := True;
    end;
  end;

var
  isBinary: Boolean;
  Match: TPixelOCRMatch;
begin
  if (Length(Font.Glyphs) = 0) then
    SimbaException('Font is empty');

  Result := [];
  Matches := [];

  isBinary := Image.isBinary;

  while (Bounds.Y1 < Bounds.Y2) do
  begin
    if MaybeRecognize(Bounds.X1, Bounds.Y1, isBinary, Match) then
    begin
      Result += [Match.Text];
      Matches += [Match];

      // Now we can confidently skip this search line by a jump, but we dont skip fully in case of close/overlapping Text
      // So we divide the texts max glyph Height by 2 and subtract that from the lower end of the found bounds.
      Bounds.Y1 := Max(Bounds.Y1, Match.Bounds.Y2 - (Font.MaxGlyphHeight div 2));
    end;

    Bounds.Y1 += 1;
  end;
end;

end.
