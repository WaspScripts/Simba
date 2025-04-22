{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
  --------------------------------------------------------------------------
  Author: Jarl Holta - https://github.com/slackydev
}
unit simba.vector;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base;

type
  TMatrix4 = record
    M11, M12, M13, M14,
    M21, M22, M23, M24,
    M31, M32, M33, M34,
    M41, M42, M43, M44: Single;
  end;

  TVector2 = record
    X, Y: Single;
  end;
  TVector3 = record
    X, Y, Z: Single;
  end;
  TVector4 = record
    X,Y,Z,W: Single;
  end;

  TVector2Array = array of TVector2;
  TVector3Array = array of TVector3;
  TVector4Array = array of TVector4;

  TVector2Helper = type helper for TVector2
    function ToPoint: TPoint;
    function ToVec3(Z: Single): TVector3;

    function Magnitude(): Single;
    function Distance(Other: TVector2): Single;
    function SqDistance(Other: TVector2): Single;
    function Cross(Other: TVector2): Single;
    function Dot(Other: TVector2): Single;
    function Normalize: TVector2;
    function Rotate(Angle:Single; Mx,My:Single): TVector2;
  end;

  operator * (Left, Right: TVector2): TVector2;
  operator * (Left: TVector2; Right: Single): TVector2;
  operator + (Left, Right: TVector2): TVector2;
  operator + (Left: TVector2; Right: Single): TVector2;
  operator - (Left, Right: TVector2): TVector2;
  operator - (Left: TVector2; Right: Single): TVector2;
  operator - (Left: Single; Right: TVector2): TVector2;
  operator / (Left, Right: TVector2): TVector2;
  operator / (Left: TVector2; Right: Single): TVector2;
  operator / (Left: Single; Right: TVector2): TVector2;

type
  TVector3Helper = type helper for TVector3
  public const
    UNIT_X: TVector3 = (X: 1; Y: 0; Z: 0);
    UNIT_Y: TVector3 = (X: 0; Y: 1; Z: 0);
    UNIT_Z: TVector3 = (X: 0; Y: 0; Z: 1);
  public
    function ToVec2(): TVector2;
    function ToPoint(): TPoint;

    function Abs(): TVector3;
    function Cross(Other: TVector3): TVector3;
    function Dot(Other: TVector3): Single;
    function Magnitude(): Single;
    function Distance(Other: TVector3): Single;
    function SqDistance(Other: TVector3): Single;
    function Normalize(): TVector3;
    function Rotate(Angle: Single; Mx,My: Single): TVector3;
    function Transform(Matrix: TMatrix4): TVector3;
  end;

  operator * (Left, Right: TVector3): TVector3;
  operator * (Left: TVector3; Right: Single): TVector3;
  operator + (Left, Right: TVector3): TVector3;
  operator + (Left: TVector3; Right: Single): TVector3;
  operator - (Left, Right: TVector3): TVector3;
  operator - (Left: TVector3; Right: Single): TVector3;
  operator - (Left: Single; Right: TVector3): TVector3;
  operator / (Left, Right: TVector3): TVector3;
  operator / (Left: TVector3; Right: Single): TVector3;
  operator / (Left: Single; Right: TVector3): TVector3;

type
  TVector2ArrayHelper = type helper for TVector2Array
    class function Create(Points: TPointArray): TVector2Array; static;
    function ToPoints: TPointArray;
    function Offset(Vec: TVector2): TVector2Array;
    function Mean: TVector2;
  end;

  TVector3ArrayHelper = type helper for TVector3Array
    class function Create(Points: TPointArray; Z: Single = 0): TVector3Array; static;
    function ToPoints: TPointArray;
    function Offset(Vec: TVector3): TVector3Array;
    function Mean: TVector3;
  end;

implementation

function TVector2Helper.ToPoint: TPoint;
begin
  Result.X := Trunc(Self.X);
  Result.Y := Trunc(Self.Y);
end;

function TVector2Helper.ToVec3(Z: Single): TVector3;
begin
  Result.X := Self.X;
  Result.Y := Self.Y;
  Result.Z := Z;
end;

function TVector2Helper.Magnitude(): Single;
begin
  Result := Sqrt(Sqr(Self.X) + Sqr(Self.Y));
end;

function TVector2Helper.Distance(Other: TVector2): Single;
begin
  Result := Sqrt(Sqr(Self.X-Other.X) + Sqr(Self.Y-Other.Y));
end;

function TVector2Helper.SqDistance(Other: TVector2): Single;
begin
  Result := Sqr(Self.X-Other.X) + Sqr(Self.Y-Other.Y);
end;

function TVector2Helper.Cross(Other: TVector2): Single;
begin
  Result := (Self.X * Other.Y) - (Self.Y * Other.X);
end;

function TVector2Helper.Dot(Other: TVector2): Single;
begin
  Result := (Self.X * Other.X) + (Self.Y * Other.Y);
end;

function TVector2Helper.Normalize: TVector2;
var len,inv: Single;
begin
  Result := Self;
  len := Sqrt(Self.X*Self.X + Self.Y*Self.Y);
  if len <> 0 then
  begin
    inv := 1.0 / len;
    Result.X := Result.X * inv;
    Result.Y := Result.Y * inv;
  end;
end;

function TVector2Helper.Rotate(Angle: Single; Mx, My: Single): TVector2;
begin
  Result.X := Mx + Cos(Angle) * (Self.X - Mx) - Sin(Angle) * (Self.Y - My);
  Result.Y := My + Sin(Angle) * (Self.X - Mx) + Cos(Angle) * (Self.Y - My);
end;

operator *(Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X * Right.X;
  Result.Y := Left.Y * Right.Y;
end;

operator *(Left: TVector2; Right: Single): TVector2;
begin
  Result.X := Left.X * Right;
  Result.Y := Left.Y * Right;
end;

operator +(Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;

operator +(Left: TVector2; Right: Single): TVector2;
begin
  Result.X := Left.X + Right;
  Result.Y := Left.Y + Right;
end;

operator -(Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;

operator -(Left: TVector2; Right: Single): TVector2;
begin
  Result.X := Left.X - Right;
  Result.Y := Left.Y - Right;
end;

operator -(Left: Single; Right: TVector2): TVector2;
begin
  Result.X := Left - Right.X;
  Result.Y := Left - Right.Y;
end;

operator /(Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X / Right.X;
  Result.Y := Left.Y / Right.Y;
end;

operator /(Left: TVector2; Right: Single): TVector2;
begin
  Result.X := Left.X / Right;
  Result.Y := Left.Y / Right;
end;

operator /(Left: Single; Right: TVector2): TVector2;
begin
  Result.X := Left / Right.X;
  Result.Y := Left / Right.Y;
end;

function TVector3Helper.ToVec2(): TVector2;
begin
  Result.X := Self.X;
  Result.Y := Self.Y;
end;

function TVector3Helper.ToPoint(): TPoint;
begin
  Result.X := Trunc(Self.X);
  Result.Y := Trunc(Self.Y);
end;

function TVector3Helper.Abs(): TVector3;
begin
  Result.X := System.Abs(Self.X);
  Result.Y := System.Abs(Self.Y);
  Result.Z := System.Abs(Self.Y);
end;

function TVector3Helper.Cross(Other: TVector3): TVector3;
begin
  Result.X := (Self.Y * Other.Z) - (Self.Z * Other.Y);
  Result.Y := (Self.Z * Other.X) - (Self.X * Other.Z);
  Result.Z := (Self.X * Other.Y) - (Self.Y * Other.X);
end;

function TVector3Helper.Dot(Other: TVector3): Single;
begin
  Result := (Self.X * Other.X) + (Self.Y * Other.Y) + (Self.Z * Other.Z);
end;

function TVector3Helper.Magnitude(): Single;
begin
  Result := Sqrt(Sqr(Self.X) + Sqr(Self.Y) + Sqr(Self.Z));
end;

function TVector3Helper.Distance(Other: TVector3): Single;
begin
  Result := Sqrt(Sqr(Self.X-Other.X) + Sqr(Self.Y-Other.Y) + Sqr(Self.Z-Other.Z));
end;

function TVector3Helper.SqDistance(Other: TVector3): Single;
begin
  Result := Sqr(Self.X-Other.X) + Sqr(Self.Y-Other.Y) + Sqr(Self.Z-Other.Z);
end;

function TVector3Helper.Normalize(): TVector3;
var len,inv: Single;
begin
  Result := Self;
  len := Sqrt(Self.X*Self.X + Self.Y*Self.Y + Self.Z*Self.Z);
  if len <> 0 then
  begin
    inv := 1.0 / len;
    Result.X := Result.X * inv;
    Result.Y := Result.Y * inv;
    Result.Z := Result.Z * inv;
  end;
end;

function TVector3Helper.Rotate(Angle: Single; Mx, My: Single): TVector3;
begin
  Result.X := Mx + Cos(angle) * (Self.X - Mx) - Sin(angle) * (Self.Y - My);
  Result.Y := My + Sin(angle) * (Self.X - Mx) + Cos(angle) * (Self.Y - My);
  Result.Z := Self.Z;
end;

function TVector3Helper.Transform(Matrix: TMatrix4): TVector3;
var
  Vec: TVector4;
begin
  Vec.X := (Self.X * Matrix.M11) + (Self.Y * Matrix.M21) + (Self.Z * Matrix.M31) + Matrix.M41;
  Vec.Y := (Self.X * Matrix.M12) + (Self.Y * Matrix.M22) + (Self.Z * Matrix.M32) + Matrix.M42;
  Vec.Z := (Self.X * Matrix.M13) + (Self.Y * Matrix.M23) + (Self.Z * Matrix.M33) + Matrix.M43;
  Vec.W := 1.0 / ((Self.X * Matrix.M14) + (Self.Y * Matrix.M24) + (Self.Z * Matrix.M34) + Matrix.M44);

  Result.X := Vec.X * Vec.W;
  Result.Y := Vec.Y * Vec.W;
  Result.Z := Vec.Z * Vec.W;
end;

operator*(Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X * Right.X;
  Result.Y := Left.Y * Right.Y;
  Result.Z := Left.Z * Right.Z;
end;

operator*(Left: TVector3; Right: Single): TVector3;
begin
  Result.X := Left.X * Right;
  Result.Y := Left.Y * Right;
  Result.Z := Left.Z * Right;
end;

operator+(Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
  Result.Z := Left.Z + Right.Z;
end;

operator+(Left: TVector3; Right: Single): TVector3;
begin
  Result.X := Left.X + Right;
  Result.Y := Left.Y + Right;
  Result.Z := Left.Z + Right;
end;

operator-(Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
  Result.Z := Left.Z - Right.Z;
end;

operator-(Left: TVector3; Right: Single): TVector3;
begin
  Result.X := Left.X - Right;
  Result.Y := Left.Y - Right;
  Result.Z := Left.Z - Right;
end;

operator-(Left: Single; Right: TVector3): TVector3;
begin
  Result.X := Left - Right.X;
  Result.Y := Left - Right.Y;
  Result.Z := Left - Right.Z;
end;

operator/(Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X / Right.X;
  Result.Y := Left.Y / Right.Y;
  Result.Z := Left.Z / Right.Z;
end;

operator/(Left: TVector3; Right: Single): TVector3;
begin
  Result.X := Left.X / Right;
  Result.Y := Left.Y / Right;
  Result.Z := Left.Z / Right;
end;

operator/(Left: Single; Right: TVector3): TVector3;
begin
  Result.X := Left / Right.X;
  Result.Y := Left / Right.Y;
  Result.Z := Left / Right.Z;
end;

class function TVector2ArrayHelper.Create(Points: TPointArray): TVector2Array;
var
  I: Integer;
begin
  SetLength(Result, Length(Points));
  for I := 0 to High(Points) do
  begin
    Result[I].X := Points[I].X;
    Result[I].Y := Points[I].Y;
  end;
end;

function TVector2ArrayHelper.ToPoints: TPointArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Result) do
  begin
    Result[I].X := Trunc(Self[I].X);
    Result[I].Y := Trunc(Self[I].Y);
  end;
end;

function TVector2ArrayHelper.Offset(Vec: TVector2): TVector2Array;
var
  I: Integer;
begin
  Result := Copy(Self);
  for I := 0 to High(Result) do
  begin
    Result[I].X += Vec.X;
    Result[I].Y += Vec.Y;
  end;
end;

function TVector2ArrayHelper.Mean: TVector2;
var
  I, Len: Integer;
begin
  Result := Default(TVector2);
  Len := Length(Self);
  for I := 0 to Len - 1 do
  begin
    Result.X += Self[I].X;
    Result.Y += Self[I].Y;
  end;
  Result.X /= Len;
  Result.Y /= Len;
end;

class function TVector3ArrayHelper.Create(Points: TPointArray; Z: Single): TVector3Array;
var
  I: Integer;
begin
  SetLength(Result, Length(Points));
  for I := 0 to High(Points) do
  begin
    Result[I].X := Points[I].X;
    Result[I].Y := Points[I].Y;
    Result[I].Z := Z;
  end;
end;

function TVector3ArrayHelper.ToPoints: TPointArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Result) do
  begin
    Result[I].X := Trunc(Self[I].X);
    Result[I].Y := Trunc(Self[I].Y);
  end;
end;

function TVector3ArrayHelper.Offset(Vec: TVector3): TVector3Array;
var
  I: Integer;
begin
  Result := Copy(Self);
  for I := 0 to High(Result) do
  begin
    Result[I].X += Vec.X;
    Result[I].Y += Vec.Y;
    Result[I].Z += Vec.Z;
  end;
end;

function TVector3ArrayHelper.Mean: TVector3;
var
  I, Len: Integer;
begin
  Result := Default(TVector3);
  Len := Length(Self);
  for I := 0 to Len - 1 do
  begin
    Result.X += Self[I].X;
    Result.Y += Self[I].Y;
    Result.Z += Self[I].Z;
  end;
  Result.X /= Len;
  Result.Y /= Len;
  Result.Z /= Len;
end;

end.

