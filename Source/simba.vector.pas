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

  TVector2Array = array of TVector2;
  TVector3Array = array of TVector3;

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

  operator * (const Left, Right: TVector2): TVector2;
  operator * (const Left: TVector2; const Right: Single): TVector2;
  operator + (const Left, Right: TVector2): TVector2;
  operator + (const Left: TVector2; const Right: Single): TVector2;
  operator - (const Left, Right: TVector2): TVector2;
  operator - (const Left: TVector2; const Right: Single): TVector2;
  operator - (const Left: Single; Right: TVector2): TVector2;
  operator / (const Left, Right: TVector2): TVector2;
  operator / (const Left: TVector2; const Right: Single): TVector2;
  operator / (const Left: Single; const Right: TVector2): TVector2;

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

  operator * (const Left, Right: TVector3): TVector3;
  operator * (const Left: TVector3; const Right: Single): TVector3;
  operator + (const Left, Right: TVector3): TVector3;
  operator + (const Left: TVector3; const Right: Single): TVector3;
  operator - (const Left, Right: TVector3): TVector3;
  operator - (const Left: TVector3; const Right: Single): TVector3;
  operator - (const Left: Single; const Right: TVector3): TVector3;
  operator / (const Left, Right: TVector3): TVector3;
  operator / (const Left: TVector3; const Right: Single): TVector3;
  operator / (const Left: Single; const Right: TVector3): TVector3;

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

  TMatrix4Helper = type helper for TMatrix4
  public const
    IDENTITY: TMatrix4 = (
      M11: 1.0; M12: 0.0; M13: 0.0; M14: 0.0;
      M21: 0.0; M22: 1.0; M23: 0.0; M24: 0.0;
      M31: 0.0; M32: 0.0; M33: 1.0; M34: 0.0;
      M41: 0.0; M42: 0.0; M43: 0.0; M44: 1.0
    );
  public
    class function RotationX(Angle: Single): TMatrix4; static;
    class function RotationY(Angle: Single): TMatrix4; static;
    class function RotationZ(Angle: Single): TMatrix4; static;
    class function Translation(value: TVector3): TMatrix4; static;
    class function LookAtLH(eye, target, up: TVector3): TMatrix4; static;
    class function LookAtRH(eye, target, up: TVector3): TMatrix4; static;
    class function PerspectiveFovLH(fov, aspect, znear, zfar: Single): TMatrix4; static;
    class function PerspectiveFovRH(fov, aspect, znear, zfar: Single): TMatrix4; static;
    class function RotationQuaternion(x,y,z,w: Single): TMatrix4; static;
    class function RotationYawPitchRoll(yaw, pitch, roll: Single): TMatrix4; static;
  end;

  operator * (const Left, Right: TMatrix4): TMatrix4;
  operator * (const Left: TMatrix4; Right: Single): TMatrix4;

implementation

uses
  Math;

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
var
  CosValue, SinValue: Single;
begin
  SinCos(Angle, SinValue, CosValue);
  Result.X := Mx + CosValue * (Self.X - Mx) - SinValue * (Self.Y - My);
  Result.Y := My + SinValue * (Self.X - Mx) + CosValue * (Self.Y - My);
end;

operator*(const Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X * Right.X;
  Result.Y := Left.Y * Right.Y;
end;

operator*(const Left: TVector2; const Right: Single): TVector2;
begin
  Result.X := Left.X * Right;
  Result.Y := Left.Y * Right;
end;

operator+(const Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;

operator+(const Left: TVector2; const Right: Single): TVector2;
begin
  Result.X := Left.X + Right;
  Result.Y := Left.Y + Right;
end;

operator-(const Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;

operator-(const Left: TVector2; const Right: Single): TVector2;
begin
  Result.X := Left.X - Right;
  Result.Y := Left.Y - Right;
end;

operator-(const Left: Single; Right: TVector2): TVector2;
begin
  Result.X := Left - Right.X;
  Result.Y := Left - Right.Y;
end;

operator/(const Left, Right: TVector2): TVector2;
begin
  Result.X := Left.X / Right.X;
  Result.Y := Left.Y / Right.Y;
end;

operator/(const Left: TVector2; const Right: Single): TVector2;
begin
  Result.X := Left.X / Right;
  Result.Y := Left.Y / Right;
end;

operator/(const Left: Single; const Right: TVector2): TVector2;
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
var
  SinValue, CosValue: Single;
begin
  SinCos(Angle, SinValue, CosValue);
  Result.X := Mx + CosValue * (Self.X - Mx) - SinValue * (Self.Y - My);
  Result.Y := My + SinValue * (Self.X - Mx) + CosValue * (Self.Y - My);
  Result.Z := Self.Z;
end;

function TVector3Helper.Transform(Matrix: TMatrix4): TVector3;
var
  w: Single;
begin
  w := 1.0 / ((Self.X * Matrix.M14) + (Self.Y * Matrix.M24) + (Self.Z * Matrix.M34) + Matrix.M44);

  Result.X := ((Self.X * Matrix.M11) + (Self.Y * Matrix.M21) + (Self.Z * Matrix.M31) + Matrix.M41) * w;
  Result.Y := ((Self.X * Matrix.M12) + (Self.Y * Matrix.M22) + (Self.Z * Matrix.M32) + Matrix.M42) * w;
  Result.Z := ((Self.X * Matrix.M13) + (Self.Y * Matrix.M23) + (Self.Z * Matrix.M33) + Matrix.M43) * w;
end;

operator*(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X * Right.X;
  Result.Y := Left.Y * Right.Y;
  Result.Z := Left.Z * Right.Z;
end;

operator*(const Left: TVector3; const Right: Single): TVector3;
begin
  Result.X := Left.X * Right;
  Result.Y := Left.Y * Right;
  Result.Z := Left.Z * Right;
end;

operator+(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
  Result.Z := Left.Z + Right.Z;
end;

operator+(const Left: TVector3; const Right: Single): TVector3;
begin
  Result.X := Left.X + Right;
  Result.Y := Left.Y + Right;
  Result.Z := Left.Z + Right;
end;

operator-(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
  Result.Z := Left.Z - Right.Z;
end;

operator-(const Left: TVector3; const Right: Single): TVector3;
begin
  Result.X := Left.X - Right;
  Result.Y := Left.Y - Right;
  Result.Z := Left.Z - Right;
end;

operator-(const Left: Single; const Right: TVector3): TVector3;
begin
  Result.X := Left - Right.X;
  Result.Y := Left - Right.Y;
  Result.Z := Left - Right.Z;
end;

operator/(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X / Right.X;
  Result.Y := Left.Y / Right.Y;
  Result.Z := Left.Z / Right.Z;
end;

operator/(const Left: TVector3; const Right: Single): TVector3;
begin
  Result.X := Left.X / Right;
  Result.Y := Left.Y / Right;
  Result.Z := Left.Z / Right;
end;

operator/(const Left: Single; const Right: TVector3): TVector3;
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

class function TMatrix4Helper.RotationX(Angle: Single): TMatrix4;
var
  SinValue, CosValue: Single;
begin
  SinCos(Angle, SinValue, CosValue);

  Result := IDENTITY;
  Result.M22 := CosValue;
  Result.M23 := SinValue;
  Result.M32 := -SinValue;
  Result.M33 := CosValue;
end;

class function TMatrix4Helper.RotationY(Angle: Single): TMatrix4;
var
  SinValue, CosValue: Single;
begin
  SinCos(Angle, SinValue, CosValue);

  Result := IDENTITY;
  Result.M11 := CosValue;
  Result.M13 := SinValue;
  Result.M31 := -SinValue;
  Result.M33 := CosValue;
end;

class function TMatrix4Helper.RotationZ(Angle: Single): TMatrix4;
var
  SinValue, CosValue: Single;
begin
  SinCos(Angle, SinValue, CosValue);

  Result := IDENTITY;
  Result.M11 := CosValue;
  Result.M12 := SinValue;
  Result.M21 := -SinValue;
  Result.M22 := CosValue;
end;

class function TMatrix4Helper.Translation(value: TVector3): TMatrix4;
begin
  result := IDENTITY;
  result.M41 := value.x;
  result.M42 := value.y;
  result.M43 := value.z;
end;

class function TMatrix4Helper.LookAtLH(eye, target, up: TVector3): TMatrix4;
var
  xaxis,yaxis,zaxis: TVector3;
begin
  zaxis := (target - eye).Normalize();
  xaxis := up.Cross(zaxis).Normalize();
  yaxis := zaxis.Cross(xaxis);

  Result := IDENTITY;
  Result.M11 := xaxis.X; result.M21 := xaxis.Y; result.M31 := xaxis.Z;
  Result.M12 := yaxis.X; result.M22 := yaxis.Y; result.M32 := yaxis.Z;
  Result.M13 := zaxis.X; result.M23 := zaxis.Y; result.M33 := zaxis.Z;

  Result.M41 := xaxis.Dot(eye);
  Result.M42 := yaxis.Dot(eye);
  Result.M43 := zaxis.Dot(eye);

  Result.M41 := -Result.M41;
  Result.M42 := -Result.M42;
  Result.M43 := -Result.M43;
end;

class function TMatrix4Helper.LookAtRH(eye, target, up: TVector3): TMatrix4;
var
  xaxis,yaxis,zaxis: TVector3;
begin
  zaxis := (eye - target).Normalize();
  xaxis := up.Cross(zaxis).Normalize();
  yaxis := zaxis.Cross(xaxis);

  Result := IDENTITY;
  Result.M11 := xaxis.X; Result.M21 := xaxis.Y; Result.M31 := xaxis.Z;
  Result.M12 := yaxis.X; Result.M22 := yaxis.Y; Result.M32 := yaxis.Z;
  Result.M13 := zaxis.X; Result.M23 := zaxis.Y; Result.M33 := zaxis.Z;

  Result.M41 := xaxis.Dot(eye);
  Result.M42 := yaxis.Dot(eye);
  Result.M43 := zaxis.Dot(eye);

  Result.M41 := -Result.M41;
  Result.M42 := -Result.M42;
  Result.M43 := -Result.M43;
end;

class function TMatrix4Helper.PerspectiveFovLH(fov, aspect, znear, zfar: Single): TMatrix4;
var yScale, q: Single;
begin
  yScale := (1.0 / Tan(fov * 0.5));
  q := zfar / (zfar - znear);

  Result := Default(TMatrix4);
  Result.M11 := yScale / aspect;
  Result.M22 := yScale;
  Result.M33 := q;
  Result.M34 := 1.0;
  Result.M43 := -q * znear;
end;

class function TMatrix4Helper.PerspectiveFovRH(fov, aspect, znear, zfar: Single): TMatrix4;
var yScale, q: Single;
begin
  yScale := (1.0 / Tan(fov * 0.5));
  q := zfar / (znear - zfar);

  Result := Default(TMatrix4);
  Result.M11 := yScale / aspect;
  Result.M22 := yScale;
  Result.M33 := q;
  Result.M34 := -1.0;
  Result.M43 := q * znear;
end;

class function TMatrix4Helper.RotationQuaternion(x,y,z,w: Single): TMatrix4;
var
  xx,yy,zz,xy,zw,zx,yw,yz,xw: Single;
begin
  xx := X * X;
  yy := Y * Y;
  zz := Z * Z;
  xy := X * Y;
  zw := Z * W;
  zx := Z * X;
  yw := Y * W;
  yz := Y * Z;
  xw := X * W;

  Result := IDENTITY;
  Result.M11 := 1.0 - (2.0 * (yy + zz));
  Result.M12 := 2.0 * (xy + zw);
  Result.M13 := 2.0 * (zx - yw);
  Result.M21 := 2.0 * (xy - zw);
  Result.M22 := 1.0 - (2.0 * (zz + xx));
  Result.M23 := 2.0 * (yz + xw);
  Result.M31 := 2.0 * (zx + yw);
  Result.M32 := 2.0 * (yz - xw);
  Result.M33 := 1.0 - (2.0 * (yy + xx));
end;

class function TMatrix4Helper.RotationYawPitchRoll(yaw, pitch, roll: Single): TMatrix4;
var
  halfRoll, halfPitch, halfYaw: Single;
  sinRoll, cosRoll, sinPitch, cosPitch, sinYaw, cosYaw: Single;
begin
  halfRoll  := roll  * 0.5;
  halfPitch := pitch * 0.5;
  halfYaw   := yaw   * 0.5;

  SinCos(halfRoll,  sinRoll,  cosRoll);
  SinCos(halfPitch, sinPitch, cosPitch);
  SinCos(halfYaw,   sinYaw,   cosYaw);

  Result := TMatrix4.RotationQuaternion(
    (cosYaw * sinPitch * cosRoll) + (sinYaw * cosPitch * sinRoll),
    (sinYaw * cosPitch * cosRoll) - (cosYaw * sinPitch * sinRoll),
    (cosYaw * cosPitch * sinRoll) - (sinYaw * sinPitch * cosRoll),
    (cosYaw * cosPitch * cosRoll) + (sinYaw * sinPitch * sinRoll)
  );
end;

operator * (const Left, Right: TMatrix4): TMatrix4;
begin
  Result.M11 := (left.M11 * right.M11) + (left.M12 * right.M21) + (left.M13 * right.M31) + (left.M14 * right.M41);
  Result.M12 := (left.M11 * right.M12) + (left.M12 * right.M22) + (left.M13 * right.M32) + (left.M14 * right.M42);
  Result.M13 := (left.M11 * right.M13) + (left.M12 * right.M23) + (left.M13 * right.M33) + (left.M14 * right.M43);
  Result.M14 := (left.M11 * right.M14) + (left.M12 * right.M24) + (left.M13 * right.M34) + (left.M14 * right.M44);
  Result.M21 := (left.M21 * right.M11) + (left.M22 * right.M21) + (left.M23 * right.M31) + (left.M24 * right.M41);
  Result.M22 := (left.M21 * right.M12) + (left.M22 * right.M22) + (left.M23 * right.M32) + (left.M24 * right.M42);
  Result.M23 := (left.M21 * right.M13) + (left.M22 * right.M23) + (left.M23 * right.M33) + (left.M24 * right.M43);
  Result.M24 := (left.M21 * right.M14) + (left.M22 * right.M24) + (left.M23 * right.M34) + (left.M24 * right.M44);
  Result.M31 := (left.M31 * right.M11) + (left.M32 * right.M21) + (left.M33 * right.M31) + (left.M34 * right.M41);
  Result.M32 := (left.M31 * right.M12) + (left.M32 * right.M22) + (left.M33 * right.M32) + (left.M34 * right.M42);
  Result.M33 := (left.M31 * right.M13) + (left.M32 * right.M23) + (left.M33 * right.M33) + (left.M34 * right.M43);
  Result.M34 := (left.M31 * right.M14) + (left.M32 * right.M24) + (left.M33 * right.M34) + (left.M34 * right.M44);
  Result.M41 := (left.M41 * right.M11) + (left.M42 * right.M21) + (left.M43 * right.M31) + (left.M44 * right.M41);
  Result.M42 := (left.M41 * right.M12) + (left.M42 * right.M22) + (left.M43 * right.M32) + (left.M44 * right.M42);
  Result.M43 := (left.M41 * right.M13) + (left.M42 * right.M23) + (left.M43 * right.M33) + (left.M44 * right.M43);
  Result.M44 := (left.M41 * right.M14) + (left.M42 * right.M24) + (left.M43 * right.M34) + (left.M44 * right.M44);
end;

operator * (const Left: TMatrix4; Right: Single): TMatrix4;
begin
  Result.M11 := left.M11 * right;
  Result.M12 := left.M12 * right;
  Result.M13 := left.M13 * right;
  Result.M14 := left.M14 * right;
  Result.M21 := left.M21 * right;
  Result.M22 := left.M22 * right;
  Result.M23 := left.M23 * right;
  Result.M24 := left.M24 * right;
  Result.M31 := left.M31 * right;
  Result.M32 := left.M32 * right;
  Result.M33 := left.M33 * right;
  Result.M34 := left.M34 * right;
  Result.M41 := left.M41 * right;
  Result.M42 := left.M42 * right;
  Result.M43 := left.M43 * right;
  Result.M44 := left.M44 * right;
end;

end.

