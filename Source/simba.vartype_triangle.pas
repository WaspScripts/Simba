{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.vartype_triangle;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base;

type
  TTriangleHelper = type helper for TTriangle
  private
    function GetCorners: TPointArray;
    function GetMean: TPoint;
    function GetArea: Integer;
    function GetBounds: TBox;
  public const
    EMPTY: TTriangle = (A: (X:0; Y:0); B: (X:0; Y:0); C: (X:0; Y:0));
  public
    class function Create(A, B, C: TPoint): TTriangle; static; 

    function Centroid(): TPoint;
    function SymmedianPoint(): TPoint;
    function Incenter(): TPoint;

    function Rotate(Radians: Double): TTriangle;
    function Contains(P: TPoint): Boolean;
    function Offset(P: TPoint): TTriangle;
    function Extract(Points: TPointArray): TPointArray;
    function Exclude(Points: TPointArray): TPointArray;
    function Expand(Amount: Int32): TTriangle;
    function NearestEdge(P: TPoint): TPoint;
    function IsObtuse(): Boolean; overload;
    function IsObtuse(out Obstuse: TPoint): Boolean;
    function Circumcircle(): TCircle;
    function Incircle(): TCircle;

    property Corners: TPointArray read GetCorners;
    property Mean: TPoint read GetMean;
    property Area: Integer read GetArea;
    property Bounds: TBox read GetBounds;
  end;

  operator in(const P: TPoint; const Triangle: TTriangle): Boolean;

implementation

uses
  Math,
  simba.math, simba.vartype_pointarray, simba.random, simba.geometry, simba.containers,
  simba.vartype_point;


class function TTriangleHelper.Create(A ,B, C: TPoint): TTriangle;
begin
  Result.A := A;
  Result.B := B;
  Result.C := C;
end;


function TTriangleHelper.GetCorners: TPointArray;
begin
  Result := [A, B, C];
end;


function TTriangleHelper.GetBounds: TBox;
begin
  Result.X1 := Min(Min(A.X, B.X), C.X);
  Result.X2 := Max(Max(A.X, B.X), C.X);
  Result.Y1 := Min(Min(A.Y, B.Y), C.Y);
  Result.Y2 := Max(Max(A.Y, B.Y), C.Y);
end;


function TTriangleHelper.GetMean: TPoint;
begin
  Result.x := (A.x + B.x + C.x) div 3;
  Result.y := (A.y + B.y + C.y) div 3;
end;


function TTriangleHelper.GetArea: Integer;
begin
  Result := Ceil(Abs((A.x * (B.y - C.y) + B.x * (C.y - A.y) + C.x * (A.y - B.y)) / 2));
end;

function TTriangleHelper.Centroid(): TPoint;
begin
  Result := Self.GetMean();
end;

function TTriangleHelper.SymmedianPoint(): TPoint;
  function WeightedIntersection(YY, ZZ: TPoint; y, z: Single): TPoint; inline;
  begin
    Result.X := Round((y * YY.X + z * ZZ.X) / (y + z));
    Result.Y := Round((y * YY.Y + z * ZZ.Y) / (y + z));
  end;
var
  ar, br, cr: Double;
  KA, KB: TPoint;
begin
  with Self do
  begin
    ar := Sqr(B.X - C.X) + Sqr(B.Y - C.Y);
    br := Sqr(A.X - C.X) + Sqr(A.Y - C.Y);
    cr := Sqr(A.X - B.X) + Sqr(A.Y - B.Y);

    KA := WeightedIntersection(B,C, br,cr);
    KB := WeightedIntersection(A,C, ar,cr);

    if not TSimbaGeometry.LinesIntersect(A, KA, B, KB, Result) then
      Result := A;
  end;
end;

function TTriangleHelper.Incenter(): TPoint;
var
  ar, br, cr: Single;
  I: TPoint;
begin
  ar := Distance(B, C);
  br := Distance(A, C);
  cr := Distance(A, B);

  Result.x := Round((ar * A.x + br * B.x + cr * C.x) / (ar + br + cr));
  Result.y := Round((ar * A.y + br * B.y + cr * C.y) / (ar + br + cr));
end;

function TTriangleHelper.Rotate(Radians: Double): TTriangle;
begin
  // we can use RotatePointFast for any A,B,C if dist to X,Y < 100
  with Self.Mean do
  begin
    Result.A := TSimbaGeometry.RotatePoint(Self.A, Radians, X, Y);
    Result.B := TSimbaGeometry.RotatePoint(Self.B, Radians, X, Y);
    Result.C := TSimbaGeometry.RotatePoint(Self.C, Radians, X, Y);
  end;
end;


function TTriangleHelper.Contains(P: TPoint): Boolean;
begin
  Result := TSimbaGeometry.PointInTriangle(P, Self.A, Self.B, Self.C);
end;


function TTriangleHelper.Offset(P: TPoint): TTriangle;
begin
  Result := TTriangle.Create(A.Offset(P), B.Offset(P), C.Offset(P));
end;


function TTriangleHelper.Extract(Points: TPointArray): TPointArray;
var
  I: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init(Length(Points));
  for I := 0 to High(Points) do
    if Self.Contains(Points[I]) then
      Buffer.Add(Points[I]);
  
  Result := Buffer.ToArray(False);
end;


function TTriangleHelper.Exclude(Points: TPointArray): TPointArray;
var
  I: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init(Length(Points));
  for I := 0 to High(Points) do
    if not Self.Contains(Points[I]) then
      Buffer.Add(Points[I]);

  Result := Buffer.ToArray(False);
end;


function TTriangleHelper.Expand(Amount: Int32): TTriangle;
var
  poly: TPointArray;
  tmp: TPoint;
  o: Int32;
begin
  o := TSimbaGeometry.CrossProduct(A,B,C);
  SetLength(poly, 3);
  poly[0] := A;
  poly[1] := B;
  poly[2] := C;

  if o < 0 then
  begin
    tmp := A;
    A   := C;
    C   := tmp;
  end;

  poly := TSimbaGeometry.ExpandPolygon(poly, Amount);

  Result.A := poly[0];
  Result.B := poly[1];
  Result.C := poly[2];
end;

function TTriangleHelper.NearestEdge(P: TPoint): TPoint;
var
  Dists: array[0..2] of Double;
  Points: array[0..2] of TPoint;
  I: Integer;
  Best: Double;
begin
  Dists[0] := TSimbaGeometry.DistToLine(P, Self.A, Self.B, Points[0]);
  Dists[1] := TSimbaGeometry.DistToLine(P, Self.B, Self.C, Points[1]);
  Dists[2] := TSimbaGeometry.DistToLine(P, Self.C, Self.A, Points[2]);

  Best   := Dists[0];
  Result := Points[0];

  for I := 1 to 2 do
    if (Dists[I] < Best) then
    begin
      Best   := Dists[I];
      Result := Points[I];
    end;
end;


function TTriangleHelper.IsObtuse(out Obstuse: TPoint): Boolean;
var ab,ac,bc,len: Int64;
begin
  ab := Sqr(Self.A.x-Self.B.x) + Sqr(Self.A.y-Self.B.y);
  ac := Sqr(Self.A.x-Self.C.x) + Sqr(Self.A.y-Self.C.y);
  bc := Sqr(Self.B.x-Self.C.x) + Sqr(Self.B.y-Self.C.y);

  len := Max(ab, Max(ac, bc));
  if len = ab then begin Result := ab > ac+bc; Obstuse := Self.C; end;
  if len = ac then begin Result := ac > ab+bc; Obstuse := Self.B; end;
  if len = bc then begin Result := bc > ac+ab; Obstuse := Self.A; end;
end;


function TTriangleHelper.IsObtuse(): Boolean; overload;
var ab,ac,bc,len: Int64;
begin
  ab := Sqr(Self.A.x-Self.B.x) + Sqr(Self.A.y-Self.B.y);
  ac := Sqr(Self.A.x-Self.C.x) + Sqr(Self.A.y-Self.C.y);
  bc := Sqr(Self.B.x-Self.C.x) + Sqr(Self.B.y-Self.C.y);

  len := Max(ab, Max(ac, bc));
  Result := ((len = ab) and (ab > ac+bc)) or
            ((len = ac) and (ac > ab+bc)) or
            ((len = bc) and (bc > ac+ab));
end;


function TTriangleHelper.Circumcircle(): TCircle;
var
  d,l: Single;
  p,pcs,q,qcs: record x,y: Single; end;
begin
  p.x := (A.x+B.x) / 2;
  p.y := (A.y+B.y) / 2;
  
  q.x := (A.x+C.x) / 2;
  q.y := (A.y+C.y) / 2;
  
  SinCos(ArcTan2(A.Y-B.Y, A.X-B.X) - PI/2, pcs.y, pcs.x);
  SinCos(ArcTan2(A.Y-C.Y, A.X-C.X) - PI/2, qcs.y, qcs.x);
  
  d := pcs.x * qcs.y - pcs.y * qcs.x;
  
  if (Abs(d) >= 0.001) then
  begin
    l := (qcs.x * (p.y - q.y) - qcs.y * (p.x - q.x)) / d;

    Result.X := Round(p.x + l * pcs.x);
    Result.Y := Round(p.y + l * pcs.y);
    Result.Radius := Ceil(Sqrt(Sqr((p.x + l * pcs.x) - A.x) + Sqr((p.y + l * pcs.y) - A.y)));
  end else
  begin
    Result.Radius := 0;
    Result.X := 0;
    Result.Y := 0;
  end;
end;

function TTriangleHelper.Incircle(): TCircle;
var
  p,q: TPoint;
begin
  p := Self.Incenter();
  q := Self.NearestEdge(p);

  Result.x := p.x;
  Result.y := p.y;
  Result.Radius := Round(p.DistanceTo(q));
end;


operator in(const P: TPoint; const Triangle: TTriangle): Boolean;
begin
  Result := Triangle.Contains(P);
end;

end.

