{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}

{
 Jarl Holta - https://github.com/slackydev/SimbaExt

  - CreateFromSimplePolygon
  - ConvexHull
  - ConcaveHull
  - ConvexityDefects
  - Border
  - Skeleton
  - MinAreaRect
  - MinAreaCircle
  - Erode
  - Grow
  - RotateEx
  - PartitionEx
  - DistanceTransform
  - QuickSkeleton
}

{
  Jani Lähdesmäki - Janilabo

  - Cluster
}

unit simba.vartype_pointarray;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base,
  simba.vartype_polygon,
  simba.vartype_quad,
  simba.vartype_circle;

type
  {$PUSH}
  {$SCOPEDENUMS ON}
  EConvexityDefects = (NONE, ALL, MINIMAL);
  {$POP}

  TPointArrayHelper = type helper for TPointArray
  public
    class function CreateFromLine(Start, Stop: TPoint): TPointArray; static;
    class function CreateFromCircle(Center: TPoint; Radius: Integer; Filled: Boolean): TPointArray; static;
    class function CreateFromEllipse(Center: TPoint; RadiusX, RadiusY: Integer; Filled: Boolean): TPointArray; static;
    class function CreateFromBox(Box: TBox; Filled: Boolean): TPointArray; static;
    class function CreateFromPolygon(Poly: TPointArray; Filled: Boolean): TPointArray; static;
    class function CreateFromSimplePolygon(Center: TPoint; Sides: Integer; Size: Integer; Filled: Boolean): TPointArray; static;
    class function CreateFromAxes(X, Y: TIntegerArray): TPointArray; static;

    function IndexOf(P: TPoint): Integer;
    function IndicesOf(P: TPoint): TIntegerArray;
    function Equals(Other: TPointArray): Boolean;
    function Sum: TPoint;
    function Reversed: TPointArray;

    function Offset(P: TPoint): TPointArray; overload;
    function Offset(X, Y: Integer): TPointArray; overload;

    function Invert(ABounds: TBox): TPointArray; overload;
    function Invert: TPointArray; overload;

    function Connect: TPointArray;
    function Density: Double;

    function Edges: TPointArray;
    function Border: TPointArray;
    function Skeleton(FMin: Integer = 2; FMax: Integer = 6): TPointArray;
    function FloodFill(const StartPoint: TPoint; const EightWay: Boolean): TPointArray;
    function ShapeFill: TPointArray;

    procedure FurthestPoints(out A, B: TPoint);
    function ConvexHull: TPolygon;

    function Mean: TPoint;
    function Median: TPoint;
    function MinAreaRect: TQuad;
    function MinAreaCircle: TCircle;
    function Bounds: TBox;
    function Area: Double;

    function Erode(Iterations: Integer): TPointArray;
    function Grow(Iterations: Integer): TPointArray;

    function Unique: TPointArray;
    function ReduceByDistance(Dist: Integer): TPointArray;

    // Return points NOT in ...
    function ExcludeDist(Center: TPoint; MinDist, MaxDist: Double): TPointArray;
    function ExcludePolygon(Polygon: TPolygon): TPointArray;
    function ExcludeBox(Box: TBox): TPointArray;
    function ExcludeQuad(Quad: TQuad): TPointArray;
    function ExcludePie(StartDegree, EndDegree, MinRadius, MaxRadius: Single; Center: TPoint): TPointArray;
    function ExcludePoints(Points: TPointArray): TPointArray;

    // return points WITHIN ...
    function ExtractDist(Center: TPoint; MinDist, MaxDist: Single): TPointArray;
    function ExtractPolygon(Polygon: TPolygon): TPointArray;
    function ExtractBox(Box: TBox): TPointArray;
    function ExtractQuad(Quad: TQuad): TPointArray;
    function ExtractPie(StartDegree, EndDegree, MinRadius, MaxRadius: Single; Center: TPoint): TPointArray;

    function Extremes: TPointArray;
    function Rotate(Radians: Double; Center: TPoint): TPointArray;
    function RotateEx(Radians: Double): TPointArray;

    function PointsNearby(Other: TPointArray; MinDist, MaxDist: Double): TPointArray; overload;
    function PointsNearby(Other: TPointArray; MinDistX, MinDistY, MaxDistX, MaxDistY: Double): TPointArray; overload;
    function IsPointNearby(Other: TPoint; MinDist, MaxDist: Double): Boolean; overload;
    function IsPointNearby(Other: TPoint; MinDistX, MinDistY, MaxDistX, MaxDistY: Double): Boolean; overload;

    function NearestPoint(Other: TPoint): TPoint;
    function FurthestPoint(Other: TPoint): TPoint;

    function Sort(Weights: TIntegerArray; LowToHigh: Boolean = True): TPointArray; overload;
    function Sort(Weights: TSingleArray; LowToHigh: Boolean = True): TPointArray; overload;
    function Sort(Weights: TDoubleArray; LowToHigh: Boolean = True): TPointArray; overload;

    function SortFrom(From: TPoint): TPointArray;
    function SortCircular(Center: TPoint; StartDegrees: Integer; Clockwise: Boolean): TPointArray;
    function SortByX(LowToHigh: Boolean = True): TPointArray;
    function SortByY(LowToHigh: Boolean = True): TPointArray;

    function SortByRow(LowToHigh: Boolean = True): TPointArray;
    function SortByColumn(LowToHigh: Boolean = True): TPointArray;

    function Rows: T2DPointArray;
    function Columns: T2DPointArray;

    function Split(DistX, DistY: Single): T2DPointArray; overload;
    function Split(Dist: Single): T2DPointArray; overload;

    function Cluster(DistX, DistY: Single): T2DPointArray; overload;
    function Cluster(Dist: Single): T2DPointArray; overload;

    function Partition(Width, Height: Integer): T2DPointArray; overload;
    function Partition(Dist: Integer): T2DPointArray; overload;
    function PartitionEx(StartPoint: TPoint; BoxWidth, BoxHeight: Integer): T2DPointArray; overload;
    function PartitionEx(BoxWidth, BoxHeight: Integer): T2DPointArray; overload;

    function Intersection(Other: TPointArray): TPointArray;
    function SymmetricDifference(Other: TPointArray): TPointArray;
    function Difference(Other: TPointArray): TPointArray;

    function DistanceTransform: TSingleMatrix;
    function QuickSkeleton(): TPointArray;

    function Circularity: Double;

    function ConcaveHull(Epsilon:Double=2.5; kCount:Int32=5): TPolygon;
    function ConcaveHullEx(MaxLeap: Double=-1; Epsilon:Double=2): TPolygonArray;
    function ConvexityDefects(Epsilon: Single; Mode: EConvexityDefects = EConvexityDefects.NONE): TPointArray;

    procedure ToAxes(out X, Y: TIntegerArray);
  end;

  T2DPointArrayHelper = type helper for T2DPointArray
  public
    function Offset(P: TPoint): T2DPointArray;

    function Sort(Weights: TIntegerArray; LowToHigh: Boolean = True): T2DPointArray; overload;
    function Sort(Weights: TDoubleArray; LowToHigh: Boolean = True): T2DPointArray; overload;
    function SortFromSize(Size: Integer): T2DPointArray;
    function SortFromIndex(From: TPoint; Index: Integer = 0): T2DPointArray;
    function SortFromFirstPoint(From: TPoint): T2DPointArray;
    function SortFromFirstPointX(From: TPoint): T2DPointArray;
    function SortFromFirstPointY(From: TPoint): T2DPointArray;

    function SortFrom(From: TPoint): T2DPointArray;

    function SortByArea(LowToHigh: Boolean): T2DPointArray;
    function SortBySize(LowToHigh: Boolean): T2DPointArray;
    function SortByDensity(LowToHigh: Boolean): T2DPointArray;

    function SortByX(LowToHigh: Boolean): T2DPointArray;
    function SortByY(LowToHigh: Boolean): T2DPointArray;

    function SortByShortSide(LowToHigh: Boolean): T2DPointArray;
    function SortByLongSide(LowToHigh: Boolean): T2DPointArray;

    function ExtractSize(Len: Integer; KeepIf: EComparator): T2DPointArray;
    function ExtractSizeEx(MinLen, MaxLen: Integer): T2DPointArray;
    function ExtractDimensions(MinShortSide, MinLongSide, MaxShortSide, MaxLongSide: Integer): T2DPointArray;
    function ExtractDimensionsEx(MinShortSide, MinLongSide: Integer): T2DPointArray;

    function ExcludeSize(Len: Integer; RemoveIf: EComparator): T2DPointArray;
    function ExcludeSizeEx(MinLen, MaxLen: Integer): T2DPointArray;
    function ExcludeDimensions(MinShortSide, MinLongSide, MaxShortSide, MaxLongSide: Integer): T2DPointArray;
    function ExcludeDimensionsEx(MinShortSide, MinLongSide: Integer): T2DPointArray;

    function Bounds: TBox;
    function BoundsArray: TBoxArray;

    function Mean: TPoint;
    function Means: TPointArray;

    function Merge: TPointArray;

    function Smallest: TPointArray;
    function Largest: TPointArray;

    function Intersection: TPointArray;
  end;

implementation

uses
  Math,
  simba.containers, simba.geometry, simba.math,
  simba.container_slacktree,
  simba.vartype_matrix, simba.vartype_ordarray,
  simba.vartype_box, simba.vartype_point, simba.vartype_triangle,
  simba.array_algorithm;

procedure GetAdjacent4(var Adj: TPointArray; const P: TPoint); inline;
begin
  Adj[0].X := P.X - 1;
  Adj[0].Y := P.Y;
  Adj[1].X := P.X;
  Adj[1].Y := P.Y - 1;
  Adj[2].X := P.X + 1;
  Adj[2].Y := P.Y;
  Adj[3].X := P.X;
  Adj[3].Y := P.Y + 1;
end;

procedure GetAdjacent8(var Adj: TPointArray; const P: TPoint); inline;
begin
  Adj[0].X := P.X - 1;
  Adj[0].Y := P.Y;
  Adj[1].X := P.X;
  Adj[1].Y := P.Y - 1;
  Adj[2].X := P.X + 1;
  Adj[2].Y := P.Y;
  Adj[3].X := P.X;
  Adj[3].Y := P.Y + 1;

  Adj[4].X := P.X - 1;
  Adj[4].Y := P.Y + 1;
  Adj[5].X := P.X - 1;
  Adj[5].Y := P.Y - 1;
  Adj[6].X := P.X + 1;
  Adj[6].Y := P.Y - 1;
  Adj[7].X := P.X + 1;
  Adj[7].Y := P.Y + 1;
end;

procedure RotatingAdjecent(var Adj: TPointArray; const Curr:TPoint; const Prev: TPoint); inline;
var
  i: Integer;
  dx,dy,x,y:Single;
begin
  x := Prev.x;
  y := Prev.y;
  Adj[7] := Prev;
  for i:=0 to 6 do
  begin
    dx := x - Curr.x;
    dy := y - Curr.y;
    x := ((dy * 0.7070) + (dx * 0.7070)) + Curr.x;
    y := ((dy * 0.7070) - (dx * 0.7070)) + Curr.y;
    Adj[i].X := Round(x);
    Adj[i].Y := Round(y);
  end;
end;

class function TPointArrayHelper.CreateFromLine(Start, Stop: TPoint): TPointArray;
var
  Buffer: TSimbaPointBuffer;

  procedure Create;

    procedure _Pixel(const X, Y: Integer); inline;
    begin
      Buffer.Add(X, Y);
    end;

    {$i shapebuilder_line.inc}

  begin
    _BuildLine(Start, Stop);
  end;

begin
  Create();

  Result := Buffer.ToArray(False);
end;

class function TPointArrayHelper.CreateFromCircle(Center: TPoint; Radius: Integer; Filled: Boolean): TPointArray;
var
  Buffer: TSimbaPointBuffer;

  procedure Create;

    procedure _Pixel(const X, Y: Integer); inline;
    begin
      Buffer.Add(X, Y);
    end;

    {$i shapebuilder_circle.inc}

  begin
    _BuildCircle(Center.X, Center.Y, Radius);
  end;

  procedure CreateFilled;

    procedure _Row(const Y: Integer; const X1, X2: Integer);
    var
      X: Integer;
    begin
      for X := X1 to X2 do
        Buffer.Add(X, Y);
    end;

    {$i shapebuilder_circlefilled.inc}

  begin
    Buffer.Init(Radius * Radius);

    _BuildCircleFilled(Center.X, Center.Y, Radius);
  end;

begin
  case Filled of
    True:  CreateFilled();
    False: Create();
  end;

  Result := Buffer.ToArray(False);
end;

class function TPointArrayHelper.CreateFromEllipse(Center: TPoint; RadiusX, RadiusY: Integer; Filled: Boolean): TPointArray;
var
  Buffer: TSimbaPointBuffer;

  procedure Create;

    procedure _Pixel(const X, Y: Integer); inline;
    begin
      Buffer.Add(X, Y);
    end;

    {$i shapebuilder_ellipse.inc}

  begin
    _BuildEllipse(Center.X, Center.Y, RadiusX, RadiusY);
  end;

  procedure CreateFilled;

    procedure _Row(const Y: Integer; const X1, X2: Integer);
    var
      X: Integer;
    begin
      for X := X1 to X2 do
        Buffer.Add(X, Y);
    end;

    {$i shapebuilder_ellipsefilled.inc}

  begin
    Buffer.Init(RadiusX * RadiusY);

    _BuildEllipseFilled(Center.X, Center.Y, RadiusX, RadiusY);
  end;

begin
  case Filled of
    True:  CreateFilled();
    False: Create();
  end;

  Result := Buffer.ToArray(False);
end;

class function TPointArrayHelper.CreateFromBox(Box: TBox; Filled: Boolean): TPointArray;
var
  Buffer: TSimbaPointBuffer;

  procedure _Pixel(const X, Y: Integer); inline;
  begin
    Buffer.Add(X, Y);
  end;

  procedure _Row(const Y: Integer; const X1, X2: Integer); inline;
  var
    X: Integer;
  begin
    for X := X1 to X2 do
      Buffer.Add(X, Y);
  end;

  procedure CreateFilled;

    {$i shapebuilder_boxfilled.inc}

  begin
    Buffer.Init(Box.Area);

    _BuildBoxFilled(Box);
  end;

  procedure Create;

    {$i shapebuilder_boxedge.inc}

  begin
    Buffer.Init((Box.Width * 2) + (Box.Height * 2));

    _BuildBoxEdge(Box);
  end;

begin
  case Filled of
    True:  CreateFilled();
    False: Create();
  end;

  Result := Buffer.ToArray(False);
end;

class function TPointArrayHelper.CreateFromPolygon(Poly: TPointArray; Filled: Boolean): TPointArray;

  procedure Create;
  begin
    Result := Poly.Connect();
  end;

  procedure CreateFilled;
  var
    Buffer: TSimbaPointBuffer;

    procedure _Row(const Y: Integer; const X1, X2: Integer);
    var
      X: Integer;
    begin
      for X := X1 to X2 do
        Buffer.Add(X, Y);
    end;

    {$i shapebuilder_polygonfilled.inc}

  begin
    _BuildPolygonFilled(Poly, TRect(Poly.Bounds), TPoint.ZERO);

    Result := Buffer.ToArray(False);
  end;

begin
  case Filled of
    True:  CreateFilled();
    False: Create();
  end;
end;

class function TPointArrayHelper.CreateFromSimplePolygon(Center: TPoint; Sides: Integer; Size: Integer; Filled: Boolean): TPointArray;
var
  i: Integer;
  dx,dy,ptx,pty,SinR,CosR: Double;
  pt : TPoint;
begin
  ptx := Center.X + Size;
  pty := Center.Y + Size;
  SinR := Sin(DegToRad(360.0 / Sides));
  CosR := Cos(DegToRad(360.0 / Sides));

  Result := [Point(Round(ptx),Round(pty))];
  for i:=1 to Sides-1 do
  begin
    dx := ptx - Center.x;
    dy := pty - Center.y;
    ptx := (dy * SinR) + (dx * CosR) + Center.x;
    pty := (dy * CosR) - (dx * SinR) + Center.y;
    pt := Point(Round(ptx),Round(pty));

    Result += [pt];
  end;

  Result := Result.Connect();
  if Filled then
    Result := Result.ShapeFill();
end;

class function TPointArrayHelper.CreateFromAxes(X, Y: TIntegerArray): TPointArray;
var
  I: Integer;
begin
  if (Length(X) <> Length(Y)) then
    SimbaException('TPointArray.CreateFromAxes: X and Y lengths differ (%d,%d)', [Length(X), Length(Y)]);

  SetLength(Result, Length(X));
  for I := 0 to High(Result) do
  begin
    Result[I].X := X[I];
    Result[I].Y := Y[I];
  end;
end;

function TPointArrayHelper.IndexOf(P: TPoint): Integer;
begin
  Result := specialize TArrayIndexOf<TPoint>.IndexOf(P, Self);
end;

function TPointArrayHelper.IndicesOf(P: TPoint): TIntegerArray;
begin
  Result := specialize TArrayIndexOf<TPoint>.IndicesOf(P, Self);
end;

function TPointArrayHelper.Equals(Other: TPointArray): Boolean;
begin
  Result := specialize TArrayEquals<TPoint>.Equals(Self, Other);
end;

function TPointArrayHelper.Sum: TPoint;
begin
  Result := specialize Sum<TPoint, TPoint>(Self);
end;

function TPointArrayHelper.Reversed: TPointArray;
begin
  Result := specialize Reversed<TPoint>(Self);
end;

function TPointArrayHelper.Offset(P: TPoint): TPointArray;
var
  Ptr: PPoint;
  Upper: PtrUInt;
begin
  Result := Copy(Self);
  if (Length(Result) = 0) then
    Exit;

  Ptr := @Result[0];
  Upper := PtrUInt(Ptr) + (Length(Result) * SizeOf(TPoint));
  while (PtrUInt(Ptr) < Upper) do
  begin
    Inc(Ptr^.X, P.X);
    Inc(Ptr^.Y, P.Y);
    Inc(Ptr);
  end;
end;

function TPointArrayHelper.Offset(X, Y: Integer): TPointArray;
begin
  Result := Offset(TPoint.Create(X, Y));
end;

function TPointArrayHelper.Invert(ABounds: TBox): TPointArray;
var
  Matrix: TBooleanMatrix;
  I, W, H, X, Y: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init(ABounds.Area div 2);

  Matrix.SetSize(ABounds.Width, ABounds.Height);
  for i := 0 to High(Self) do
    if (Self[I].X >= ABounds.X1) and (Self[I].Y >= ABounds.Y1) and (Self[I].X <= ABounds.X2) and (Self[I].Y <= ABounds.Y2) then
      Matrix[Self[I].Y - ABounds.Y1][Self[I].X - ABounds.X1] := True;

  W := Matrix.Width - 1;
  H := Matrix.Height - 1;
  for Y := 0 to H do
    for X := 0 to W do
      if not Matrix[Y, X] then
        Buffer.Add(ABounds.X1 + X, ABounds.Y1 + Y);

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.Invert: TPointArray;
begin
  Result := Invert(Self.Bounds);
end;

function TPointArrayHelper.Connect: TPointArray;
var
  I: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init();

  if (Length(Self) > 1) then
  begin
    for I := 0 to High(Self) - 1 do
    begin
      Buffer.Add(TPointArray.CreateFromLine(Self[I], Self[I+1]));
      Buffer.Pop(); // dont duplicate self[I+1]
    end;
    Buffer.Add(TPointArray.CreateFromLine(Self[High(Self)], Self[0]));
    Buffer.Pop(); // dont duplicate self[0]
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.Density: Double;
begin
  if (Length(Self) > 0) then
    Result := Min(Length(Self) / Self.ConvexHull().Area, 1)
  else
    Result := 0;
end;

function TPointArrayHelper.Edges: TPointArray;
var
  Matrix: TIntegerMatrix;
  B: TBox;
  I: Integer;
  P: TPoint;
  W, H: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init();

  B := Self.Bounds();
  Matrix.SetSize(B.Width, B.Height);
  for I := 0 to High(Self) do
    Matrix[Self[I].Y - B.Y1, Self[I].X - B.X1] := 1;

  W := Matrix.Width - 1;
  H := Matrix.Height - 1;

  for I := 0 to High(Self) do
  begin
    P.X := Self[I].X - B.X1;
    P.Y := Self[I].Y - B.Y1;

    if (P.X = 0) or (P.Y = 0) or (P.X = W) or (P.Y = H) then
      Buffer.Add(Self[I])
    else
      if (Matrix[P.Y - 1, P.X - 1] = 0) or (Matrix[P.Y - 1, P.X] = 0) or (Matrix[P.Y - 1, P.X + 1] = 0) or
         (Matrix[P.Y, P.X - 1] = 0)     or (Matrix[P.Y, P.X + 1] = 0) or
         (Matrix[P.Y + 1, P.X - 1] = 0) or (Matrix[P.Y + 1, P.X] = 0) or (Matrix[P.Y + 1, P.X + 1] = 0) then
      Buffer.Add(Self[I]);
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.Border: TPointArray;
var
  I, J, H, X, Y, Hit: Integer;
  Matrix: TIntegerMatrix;
  Adj: TPointArray;
  Start, Prev, Finish: TPoint;
  B: TBox;
  Buffer: TSimbaPointBuffer;
label
  IsSet;
begin
  Buffer.Init();

  if Length(Self) > 0 then
  begin
    B := Self.Bounds();
    B.X2 := (B.X2 - B.X1) + 3; // Width
    B.Y2 := (B.Y2 - B.Y1) + 3; // Height
    B.X1 := B.X1 - 1;
    B.Y1 := B.Y1 - 1;

    Start := Point(B.X2, B.Y2);

    Matrix.SetSize(B.X2+1, B.Y2+1);
    for I := 0 to High(Self) do
      Matrix[Self[I].Y - B.Y1, Self[I].X - B.X1] := 1;

    // find first starting Y coord.
    Start := Point(B.X2, B.Y2);
    for Y := 0 to B.Y2 - 1 do
      for X := 0 to B.X2 - 1 do
        if Matrix[Y][X] <> 0 then
        begin
          Start := Point(X, Y);

          goto IsSet;
        end;

    IsSet:

    H := High(Self) * 4;
    Finish := Start;
    Prev := Point(Start.X, Start.Y - 1);
    Hit := 0;

    SetLength(Adj, 8);
    for I := 0 to H do
    begin
      if ((Finish = Start) and (I > 1)) then
      begin
        if (Hit = 1) then
          Break;

        Inc(Hit);
      end;

      RotatingAdjecent(Adj, Start, Prev);

      for J := 0 to 7 do
      begin
        X := Adj[J].X;
        Y := Adj[J].Y;
        if (X < 0) or (Y < 0) or (X >= B.X2) or (Y >= B.Y2) then
          Continue;

        if Matrix[Y][X] <= 0 then
        begin
          if Matrix[Y][X] = 0 then
          begin
            Buffer.Add(Point(Adj[J].X + B.X1, Adj[J].Y + B.Y1));

            Dec(Matrix[Y][X]);
          end;
        end else
        if Matrix[Y][X] >= 1 then
        begin
          Prev := Start;
          Start := Adj[J];

          Break;
        end;
      end;
    end;
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.Skeleton(FMin: Integer; FMax: Integer): TPointArray;

  function TransitCount(const p2,p3,p4,p5,p6,p7,p8,p9: Integer): Integer; inline;
  begin
    Result := 0;

    if ((p2 = 0) and (p3 = 1)) then Inc(Result);
    if ((p3 = 0) and (p4 = 1)) then Inc(Result);
    if ((p4 = 0) and (p5 = 1)) then Inc(Result);
    if ((p5 = 0) and (p6 = 1)) then Inc(Result);
    if ((p6 = 0) and (p7 = 1)) then Inc(Result);
    if ((p7 = 0) and (p8 = 1)) then Inc(Result);
    if ((p8 = 0) and (p9 = 1)) then Inc(Result);
    if ((p9 = 0) and (p2 = 1)) then Inc(Result);
  end;

var
  j,i,x,y,h,transit,sumn,MarkHigh,hits: Integer;
  p2,p3,p4,p5,p6,p7,p8,p9:Integer;
  Change, PTS: TPointArray;
  Matrix: TBooleanMatrix;
  iter: Boolean;
  B: TBox;
begin
  Result := Default(TPointArray);

  H := High(Self);
  if (H > 0) then
  begin
    B := Self.Bounds;
    B.x1 := B.x1 - 2;
    B.y1 := B.y1 - 2;
    Matrix.SetSize(B.Width + 2, B.Height + 2);

    SetLength(PTS, H + 1);
    for i:=0 to H do
    begin
      x := (Self[i].x-B.x1);
      y := (Self[i].y-B.y1);
      PTS[i].x := X;
      PTS[i].y := Y;
      Matrix[y][x] := True;
    end;
    j := 0;
    MarkHigh := H;
    SetLength(Change, H+1);
    repeat
      iter := (J mod 2) = 0;
      Hits := 0;
      i := 0;
      while (i < MarkHigh) do
      begin
        x := PTS[i].x;
        y := PTS[i].y;
        p2 := Ord(Matrix[y-1,x]);
        p4 := Ord(Matrix[y,x+1]);
        p6 := Ord(Matrix[y+1,x]);
        p8 := Ord(Matrix[y,x-1]);

        if Iter then
        begin
          if (((p4 * p6 * p8) <> 0) or ((p2 * p4 * p6) <> 0)) then
          begin
            Inc(i);
            Continue;
          end;
        end else
        if ((p2 * p4 * p8) <> 0) or ((p2 * p6 * p8) <> 0) then
        begin
          Inc(i);
          Continue;
        end;

        p3 := Ord(Matrix[y-1,x+1]);
        p5 := Ord(Matrix[y+1,x+1]);
        p7 := Ord(Matrix[y+1,x-1]);
        p9 := Ord(Matrix[y-1,x-1]);
        Sumn := (p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9);
        if (SumN >= FMin) and (SumN <= FMax) then
        begin
          Transit := TransitCount(p2,p3,p4,p5,p6,p7,p8,p9);
          if (Transit = 1) then
          begin
            Change[Hits] := PTS[i];
            Inc(Hits);
            PTS[i] := PTS[MarkHigh];
            PTS[MarkHigh] := TPoint.Create(x, y);
            Dec(MarkHigh);
            Continue;
          end;
        end;
        Inc(i);
      end;

      for i:=0 to (Hits-1) do
        Matrix[Change[i].y, Change[i].x] := False;

      inc(j);
    until ((Hits=0) and (Iter=False));

    SetLength(Result, (MarkHigh + 1));
    for i := 0 to MarkHigh do
      Result[i] := TPoint.Create(PTS[i].x+B.x1, PTS[i].y+B.y1);
  end;
end;

function TPointArrayHelper.FloodFill(const StartPoint: TPoint; const EightWay: Boolean): TPointArray;
var
  B: TBox;
  Width, Height: Integer;
  Checked: TBooleanMatrix;
  Queue: TSimbaPointBuffer;
  Arr: TSimbaPointBuffer;

  procedure Push(const X, Y: Integer); inline;
  begin
    if (X >= 0) and (Y >= 0) and (X < Width) and (Y < Height) and (not Checked[Y, X]) then
      Queue.Add(Point(X, Y));
  end;

  procedure CheckNeighbours(const P: TPoint); inline;
  begin
    if (P.X >= 0) and (P.Y >= 0) and (P.X < Width) and (P.Y < Height) then
    begin
      Checked[P.Y, P.X] := True;

      Push(P.X - 1, P.Y);
      Push(P.X, P.Y - 1);
      Push(P.X + 1, P.Y);
      Push(P.X, P.Y + 1);

      if EightWay then
      begin
        Push(P.X - 1, P.Y - 1);
        Push(P.X + 1, P.Y - 1);
        Push(P.X -1, P.Y + 1);
        Push(P.X + 1, P.Y + 1);
      end;

      Arr.Add(Point(P.X + B.X1, P.Y + B.Y1));
    end;
  end;

var
  I: Integer;
begin
  Arr.Init();
  Queue.Init();

  B := Self.Bounds();

  Width := B.Width;
  Height := B.Height;

  Checked.SetSize(Width, Height);
  for I := 0 to High(Self) do
    Checked[Self[I].Y - B.Y1, Self[I].X - B.X1] := True;

  CheckNeighbours(StartPoint.Offset(-B.X1, -B.Y1));
  while (Queue.Count > 0) do
    CheckNeighbours(Queue.Pop());

  Result := Arr.ToArray(False);
end;

function TPointArrayHelper.ShapeFill: TPointArray;
var
  Buffer: TSimbaPointBuffer;

  procedure HorzLine(Y: Integer; XStart, XStop: Integer);
  var
    X: Integer;
  begin
    for X := XStart to XStop do
      Buffer.Add(X, Y);
  end;

var
  Row: TPointArray;
  I: Integer;
begin
  Buffer.Init(Length(Self) * 5);
  Buffer.Add(Self);

  for Row in Rows() do
    for I := 1 to High(Row) do
      if TSimbaGeometry.PointInPolygon((Row[I-1] + Row[I]) div 2, Self) then
        HorzLine(Row[0].Y, Row[I-1].X + 1, Row[I].X - 1);

  Result := Buffer.ToArray(False);
end;

procedure TPointArrayHelper.FurthestPoints(out A, B: TPoint);
begin
  if (Length(Self) <= 1) then
  begin
    A := TPoint.ZERO;
    B := TPoint.ZERO;

    Exit;
  end;

  if (Length(Self) = 2) then
  begin
    A := Self[0];
    B := Self[1];

    Exit;
  end;

  Self.ConvexHull().FurthestPoints(A, B);
end;

function TPointArrayHelper.ConvexHull: TPolygon;
var
  pts: TPointArray;
  h,i,k,u: Integer;
begin
  if (Length(Self) <= 3) then
    Exit(Copy(Self));

  pts := Self.SortByX();

  k := 0;
  H := High(pts);
  SetLength(Result, 2 * (h+1));

  for i:=0 to h do
  begin
    while (k >= 2) and (TSimbaGeometry.CrossProduct(Result[k-2], Result[k-1], pts[i]) <= 0) do
      Dec(k);
    Result[k] := pts[i];
    Inc(k)
  end;

  u := k+1;
  for i:=h downto 0 do
  begin
    while (k >= u) and (TSimbaGeometry.CrossProduct(Result[k-2], Result[k-1], pts[i]) <= 0) do
      Dec(k);
    Result[k] := pts[i];
    Inc(k);
  end;
  SetLength(Result, k-1);
end;

function TPointArrayHelper.Mean: TPoint;
var
  Ptr: PPoint;
  Upper: PtrUInt;
begin
  Result := TPoint.ZERO;
  if (Length(Self) = 0) then
    Exit;

  Ptr := @Self[0];
  Upper := PtrUInt(Ptr) + (Length(Self) * SizeOf(TPoint));
  while (PtrUInt(Ptr) < Upper) do
  begin
    Inc(Result.X, Ptr^.X);
    Inc(Result.Y, Ptr^.Y);
    Inc(Ptr);
  end;

  Result := Result div Length(Self);
end;

function TPointArrayHelper.MinAreaRect: TQuad;
type
  TBoundingBox = record
    CosA: Double;
    CosAP: Double;
    CosAM: Double;
    Area: Double;
    X: Double;
    XH: Double;
    Y: Double;
    YH: Double;
  end;
var
  I, J: Integer;
  X, Y: Double;
  TPA: TPointArray;
  Angles: TDoubleArray;
  Box, BestBox: TBoundingBox;
begin
  Result := Default(TQuad);

  if (Length(Self) > 1) then
  begin
    TPA := Self.ConvexHull();

    SetLength(Angles, Length(TPA));
    for I := 0 to High(TPA) - 1 do
      Angles[I] := TSimbaGeometry.AngleBetween(TPA[I], TPA[I+1]);
    Angles := Angles.Unique();

    BestBox.Area := Double.MaxValue;

    for I := 0 to High(Angles) do
    begin
      Box.CosA  := Cos(Angles[I]);
      Box.CosAP := Cos(Angles[I] + HALF_PI);
      Box.CosAM := Cos(Angles[I] - HALF_PI);
      Box.X := (Box.CosA  * TPA[0].x) + (Box.CosAM * TPA[0].y);
      Box.Y := (Box.CosAP * TPA[0].x) + (Box.CosA  * TPA[0].y);
      Box.XH := Box.X;
      Box.YH := Box.Y;

      for J := 0 to High(TPA) do
      begin
        X := (Box.CosA  * TPA[J].X) + (Box.CosAM * TPA[J].Y);
        Y := (Box.CosAP * TPA[J].X) + (Box.CosA  * TPA[J].Y);
        if (X > Box.XH) then
          Box.XH := X
        else
        if (X < Box.X) then
          Box.X := X;

        if (Y > Box.YH) then
          Box.YH := Y
        else
        if (Y < Box.Y) then
          Box.Y := Y;
      end;

      Box.Area := (Box.XH - Box.X) * (Box.YH - Box.Y);
      if (Box.Area < BestBox.Area) then
        BestBox := Box;
    end;

    with BestBox do
    begin
      Result.Top    := TPoint.Create(Round((CosAP * Y)  + (CosA * X)),  Round((CosA * Y)  + (CosAM * X)));
      Result.Right  := TPoint.Create(Round((CosAP * Y)  + (CosA * XH)), Round((CosA * Y)  + (CosAM * XH)));
      Result.Bottom := TPoint.Create(Round((CosAP * YH) + (CosA * XH)), Round((CosA * YH) + (CosAM * XH)));
      Result.Left   := TPoint.Create(Round((CosAP * YH) + (CosA * X)),  Round((CosA * YH) + (CosAM * X)));
    end;
  end;
end;

function TPointArrayHelper.Bounds: TBox;
var
  Ptr: PPoint;
  Upper: PtrUInt;
begin
  Result := TBox.ZERO;

  if (Length(Self) > 0) then
  begin
    Result := TBox.Create(Self[0].X, Self[0].Y, Self[0].X, Self[0].Y);

    Ptr := @Self[0];
    Upper := PtrUInt(Ptr) + (Length(Self) * SizeOf(TPoint));
    while (PtrUInt(Ptr) < Upper) do
    begin
      if (Ptr^.X > Result.X2) then Result.X2 := Ptr^.X else
      if (Ptr^.X < Result.X1) then Result.X1 := Ptr^.X;
      if (Ptr^.Y > Result.Y2) then Result.Y2 := Ptr^.Y else
      if (Ptr^.Y < Result.Y1) then Result.Y1 := Ptr^.Y;

      Inc(Ptr);
    end;
  end;
end;

function TPointArrayHelper.Area: Double;
begin
  Result := Self.ConvexHull().Area;
end;

function TPointArrayHelper.Erode(Iterations: Integer): TPointArray;
var
  I, J, X, Y: Integer;
  Matrix: TBooleanMatrix;
  QueueA, QueueB: TSimbaPointBuffer;
  face: TPointArray;
  pt: TPoint;
  B: TBox;
begin
  Result := Default(TPointArray);
  if (Length(Self) = 0) or (Iterations = 0) then
    Exit;

  B := Self.Bounds();
  B.X1 := B.x1 - Iterations - 1;
  B.Y1 := B.y1 - Iterations - 1;
  B.X2 := (B.X2 - B.X1) + Iterations + 1;
  B.Y2 := (B.Y2 - B.Y1) + Iterations + 1;

  Matrix.SetSize(B.X2, B.Y2);
  for I:=0 to High(Self) do
    Matrix[Self[I].Y - B.Y1][Self[I].X - B.X1] := True;

  SetLength(face, 4);
  QueueA.InitWith(Self.Edges().Offset(-B.X1, -B.Y1));
  QueueB.Init();
  J := 0;
  repeat
    case (J mod 2) = 0 of
      True:
        while (QueueA.Count > 0) do
        begin
          pt := QueueA.Pop;
          Matrix[pt.y][pt.x] := False;
          GetAdjacent4(face, pt);
          for I:=0 to 3 do
          begin
            pt := face[I];
            if Matrix[pt.y][pt.x] then
            begin
              Matrix[pt.y][pt.x] := False;
              QueueB.Add(pt);
            end;
          end;
        end;

      False:
        while (QueueB.Count > 0) do
        begin
          pt := QueueB.Pop;
          Matrix[pt.y][pt.x] := False;
          GetAdjacent4(face, pt);
          for I:=0 to 3 do
          begin
            pt := face[I];
            if Matrix[pt.y][pt.x] then
            begin
              Matrix[pt.y][pt.x] := False;
              QueueA.Add(pt);
            end;
          end;
        end;
    end;
    Inc(J);
  until (J >= Iterations);

  QueueA.Clear();
  for Y := 0 to B.Y2-1 do
    for X := 0 to B.X2-1 do
      if Matrix[Y, X] then
        QueueA.Add(X + B.X1, Y + B.Y1);
  Result := QueueA.ToArray(False);
end;

function TPointArrayHelper.Grow(Iterations: Integer): TPointArray;
var
  I,J,X,Y: Integer;
  Matrix: TBooleanMatrix;
  QueueA, QueueB: TSimbaPointBuffer;
  face:TPointArray;
  pt:TPoint;
  B: TBox;
begin
  Result := Default(TPointArray);
  if (Length(Self) = 0) or (Iterations = 0) then
    Exit;

  B := Self.Bounds();
  B.x1 := B.x1 - Iterations - 1;
  B.y1 := B.y1 - Iterations - 1;
  B.x2 := (B.x2 - B.x1) + Iterations + 1;
  B.y2 := (B.y2 - B.y1) + Iterations + 1;

  Matrix.SetSize(B.X2, B.Y2);
  for I:=0 to High(Self) do
    Matrix[Self[I].Y - B.Y1][Self[I].X - B.X1] := True;

  SetLength(face,4);
  QueueA.InitWith(Self.Edges().Offset(-B.X1,-B.Y1));
  QueueB.Init();
  J := 0;
  repeat
    case (J mod 2) = 0 of
    True:
      while (QueueA.Count > 0) do
      begin
        GetAdjacent4(face, QueueA.Pop());
        for I:=0 to 3 do
        begin
          pt := face[I];
          if not(Matrix[pt.y][pt.x]) then
          begin
            Matrix[pt.y][pt.x] := True;
            QueueB.Add(pt);
          end;
        end;
      end;

    False:
      while (QueueB.Count > 0) do
      begin
        GetAdjacent4(face, QueueB.Pop());
        for I:=0 to 3 do
        begin
          pt := face[I];
          if not(Matrix[pt.y][pt.x]) then
          begin
            Matrix[pt.y][pt.x] := True;
            QueueA.Add(pt);
          end;
        end;
      end;
    end;
    Inc(J);
  until (J >= Iterations);

  QueueA.Clear();
  for Y := 0 to B.Y2-1 do
    for X := 0 to B.X2-1 do
      if Matrix[Y, X] then
        QueueA.Add(X + B.X1, Y + B.Y1);
  Result := QueueA.ToArray(False);
end;

function TPointArrayHelper.Unique: TPointArray;
var
  Width, Index: Integer;
  Box: TBox;
  BoxArea: Int64;
  Seen: TBooleanArray;
  SrcPtr, DstPtr: PPoint;
  SrcUpper: PtrUInt;
begin
  if (High(Self) < 0) then Exit([]);
  if (High(Self) = 0) then Exit([Self[0]]);

  { Fallback to safe dictionary:
     * Fewer than 1 in area of 5000
     * Larger than 512MB in memory (approx 25K*25K area)
  }
  Box := Self.Bounds;
  BoxArea := Box.Area;
  Width := Box.Width;
  if (BoxArea * SizeOf(TPoint) > $20000000) or
     (Length(Self) / BoxArea < 0.0002) then
    Exit(specialize TArrayUnique<TPoint>.Unique(Self));

  SetLength(Result, Length(Self));
  SetLength(Seen, BoxArea);

  SrcUpper := PtrUInt(@Self[High(Self)]);
  SrcPtr := @Self[0];
  DstPtr := @Result[0];

  while (PtrUInt(SrcPtr) <= SrcUpper) do
  begin
    Index := (SrcPtr^.Y - Box.Y1) * Width + (SrcPtr^.X - Box.X1);
    if not Seen[Index] then
    begin
      Seen[Index] := True;

      DstPtr^ := SrcPtr^;
      Inc(DstPtr);
    end;
    Inc(SrcPtr);
  end;
  SetLength(Result, (PtrUInt(DstPtr) - PtrUInt(@Result[0])) div SizeOf(TPoint));
end;

function TPointArrayHelper.ReduceByDistance(Dist: Integer): TPointArray;
var
  Tree: TSlackTree;
  Nodes: TNodeRefArray;
  I, J, DistSqr: Integer;
  Query: TPoint;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init();

  if (Length(Self) > 1) then
  begin
    Tree.Init(Self.Unique());

    DistSqr := Sqr(Dist);
    for I := 0 to High(Tree.Data) do
      if (not Tree.Data[I].Hidden) then
      with Tree.Data[I].Split do
      begin
        Query := Tree.Data[I].Split;
        Nodes := Tree.RawRangeQuery(
          TBox.Create(Query.X - Dist, Query.Y - Dist, Query.X + Dist, Query.Y + Dist)
        );

        for J := 0 to High(Nodes) do
          with Nodes[J]^.Split do
            Nodes[J]^.Hidden := Sqr(X - Query.X) + Sqr(Y - Query.Y) <= DistSqr;

        Buffer.Add(Tree.Data[I].Split);
      end;
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.ExcludeDist(Center: TPoint; MinDist, MaxDist: Double): TPointArray;
var
  Buffer: TSimbaPointBuffer;
  I: Integer;
  Dist, MinDistSqr, MaxDistSqr: Double;
begin
  Buffer.Init();

  MinDistSqr := Sqr(MinDist);
  MaxDistSqr := Sqr(MaxDist);
  for I := 0 to High(Self) do
  begin
    Dist := Sqr(Self[I].X - Center.X) + Sqr(Self[I].Y - Center.Y);
    if (Dist <= MinDistSqr) or (Dist >= MaxDistSqr) then
      Buffer.Add(Self[I]);
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.ExcludePolygon(Polygon: TPolygon): TPointArray;
var
  I, Count: Integer;
begin
  Count := 0;
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    if not Polygon.Contains(Self[I]) then
    begin
      Result[Count] := Self[I];
      Inc(Count);
    end;
  SetLength(Result, Count);
end;

function TPointArrayHelper.ExcludeBox(Box: TBox): TPointArray;
var
  I, Count: Integer;
begin
  Count := 0;
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    if not Box.Contains(Self[I]) then
    begin
      Result[Count] := Self[I];
      Inc(Count);
    end;
  SetLength(Result, Count);
end;

function TPointArrayHelper.ExcludeQuad(Quad: TQuad): TPointArray;
var
  I, Count: Integer;
begin
  Count := 0;
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    if not Quad.Contains(Self[I]) then
    begin
      Result[Count] := Self[I];
      Inc(Count);
    end;
  SetLength(Result, Count);
end;

function TPointArrayHelper.ExcludePie(StartDegree, EndDegree, MinRadius, MaxRadius: Single; Center: TPoint): TPointArray;
begin
  Result := Self.ExtractPie(StartDegree, EndDegree, MinRadius, MaxRadius, Center).Invert(Self.Bounds());
end;

function TPointArrayHelper.ExcludePoints(Points: TPointArray): TPointArray;
var
  Box: TBox;
  test: TBooleanArray;
  w,h: Integer;
  i,c: Integer;
begin
  Box := Points.Bounds;
  w := box.Width;
  h := box.Height;
  SetLength(test, box.Area);
  for i:=0 to High(Points) do
    test[(Points[i].y - box.y1) * w + (Points[i].x - box.x1)] := True;

  SetLength(Result, Length(Self));
  c := 0;
  for i:=0 to High(Self) do
  begin
    if InRange(Self[i].x - box.x1, 0, w-1) and InRange(Self[i].y - box.y1, 0, h-1) and
      (test[(Self[i].y - box.y1) * w + (Self[i].x - box.x1)]) then
      Continue;
    Result[c] := Self[i];
    Inc(c);
  end;
  SetLength(Result, c);
end;

function TPointArrayHelper.ExtractDist(Center: TPoint; MinDist, MaxDist: Single): TPointArray;
var
  Buffer: TSimbaPointBuffer;
  I: Integer;
  Dist, MinDistSqr, MaxDistSqr: Double;
begin
  Buffer.Init();

  MinDistSqr := Sqr(MinDist);
  MaxDistSqr := Sqr(MaxDist);
  for I := 0 to High(Self) do
  begin
    Dist := Sqr(Self[I].X - Center.X) + Sqr(Self[I].Y - Center.Y);
    if (Dist >= MinDistSqr) and (Dist <= MaxDistSqr) then
      Buffer.Add(Self[I]);
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.ExtractPolygon(Polygon: TPolygon): TPointArray;
var
  I: Integer;
  Buffer: TSimbaPointBuffer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    if Polygon.Contains(Self[I]) then
      Buffer.Add(Self[I]);
  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.ExtractBox(Box: TBox): TPointArray;
var
  I: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init();
  
  for I := 0 to High(Self) do
    if Box.Contains(Self[I]) then
      Buffer.Add(Self[I]);
  
  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.ExtractQuad(Quad: TQuad): TPointArray;
var
  I, Count: Integer;
begin
  Count := 0;
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    if Quad.Contains(Self[I]) then
    begin
      Result[Count] := Self[I];
      Inc(Count);
    end;
  SetLength(Result, Count);
end;

function TPointArrayHelper.ExtractPie(StartDegree, EndDegree, MinRadius, MaxRadius: Single; Center: TPoint): TPointArray;
var
  BminusAx, BminusAy, CminusAx, CminusAy: Double; // don't let the type deceive you. They are vectors!
  StartD, EndD: Double;
  I: Integer;
  Over180: Boolean;
  Buffer: TSimbaPointBuffer;
begin
  StartD := DegNormalize(StartDegree);
  EndD   := DegNormalize(EndDegree);

  if (not SameValue(StartD, EndD)) then // if StartD = EndD, then we have a circle...
  begin
    if (StartDegree > EndDegree) then
      Swap(StartD, EndD);
    if (StartD > EndD) then
      EndD := EndD + 360;

    Over180 := (Max(StartD, EndD) - Min(StartD, EndD)) > 180;
    if Over180 then
    begin
      StartD := StartD + 180;
      EndD   := EndD   + 180;
    end;

    // a is the midPoint, B is the left limit line, C is the right Limit Line, X the point we are checking
    BminusAx := Cos(DegToRad(StartD - 90)); // creating the two unit vectors
    BminusAy := Sin(DegToRad(StartD - 90)); // I use -90 or else it will start at the right side instead of top

    CminusAx := Cos(DegToRad(EndD - 90));
    CminusAy := Sin(DegToRad(EndD - 90));

    Buffer.Init(Length(Self) div 2);
    for I := 0 to High(Self) do
    begin
      if (not (((BminusAx * (Self[i].Y - Center.Y)) - (BminusAy * (Self[i].X - Center.X)) > 0) and
               ((CminusAx * (Self[i].Y - Center.Y)) - (CminusAy * (Self[i].X - Center.X)) < 0)) xor Over180) then
        Continue;

      Buffer.Add(Self[I]);
    end;

    Result := TPointArray(Buffer.ToArray(False)).ExtractDist(Center, MinRadius, MaxRadius);
  end else
    Result := Self.ExtractDist(Center, MinRadius, MaxRadius);
end;

function TPointArrayHelper.Extremes: TPointArray;
var
  Ptr: PPoint;
  Upper: PtrUInt;
begin
  if (Length(Self) > 0) then
  begin
    Result := [Self[0], Self[0], Self[0], Self[0]];

    Ptr := @Self[0];
    Upper := PtrUInt(Ptr) + (Length(Self) * SizeOf(TPoint));
    while (PtrUInt(Ptr) < Upper) do
    begin
      if (Ptr^.X > Result[0].X) then
        Result[0] := Ptr^
      else if (Ptr^.X < Result[2].X) then
        Result[2] := Ptr^;
      if (Ptr^.Y > Result[1].Y) then
        Result[1] := Ptr^
      else if (Ptr^.Y < Result[3].Y) then
        Result[3] := Ptr^;

      Inc(Ptr);
    end;
  end else
    Result := [TPoint.ZERO, TPoint.ZERO, TPoint.ZERO, TPoint.ZERO];
end;

function TPointArrayHelper.Rotate(Radians: Double; Center: TPoint): TPointArray;
begin
  Result := TSimbaGeometry.RotatePoints(Self, Radians, Center.X, Center.Y);
end;

function TPointArrayHelper.RotateEx(Radians: Double): TPointArray;
const
  RAD_360 = 6.283;
var
  I, X, Y, W, H, OldX, OldY, MidX, MidY: Integer;
  Matrix: TBooleanMatrix;
  CosA, SinA: Single;
  OldBounds, NewBounds: TBox;
  Corners: TPointArray;
  Buffer: TSimbaPointBuffer;
begin
  if (Length(Self) > 0) then
  begin
    Radians := RAD_360 - Radians;
    CosA := Cos(Radians);
    SinA := Sin(Radians);

    OldBounds := Self.Bounds();
    W := OldBounds.Width;
    H := OldBounds.Height;
    MidX := (W - 1) div 2;
    MidY := (H - 1) div 2;

    Matrix.SetSize(W, H);
    for I := 0 to High(Self) do
      Matrix[Self[I].Y - OldBounds.Y1, Self[I].X - OldBounds.X1] := True;

    // get new bounds
    SetLength(Corners, 4);
    Corners[0] := TSimbaGeometry.RotatePoint(TPoint.Create(0,   H-1), Radians, MidX, MidY);
    Corners[1] := TSimbaGeometry.RotatePoint(TPoint.Create(W-1, H-1), Radians, MidX, MidY);
    Corners[2] := TSimbaGeometry.RotatePoint(TPoint.Create(W-1, 0),   Radians, MidX, MidY);
    Corners[3] := TSimbaGeometry.RotatePoint(TPoint.Create(0,   0),   Radians, MidX, MidY);

    Buffer.Init(Length(Self) * 2);

    NewBounds := Corners.Bounds();
    for Y := 0 to NewBounds.Height do
      for X := 0 to NewBounds.Width do
      begin
        // get rotated points by looking back, rather then rotating forward
        OldX := Round(MidX + CosA * (X + NewBounds.x1 - MidX) - SinA * (Y + NewBounds.y1 - MidY));
        OldY := Round(MidY + SinA * (X + NewBounds.x1 - MidX) + CosA * (Y + NewBounds.y1 - MidY));
        if (OldX >= 0) and (OldY >= 0) and (OldX < W) and (OldY < H) then
          if Matrix[OldY, OldX] then
            Buffer.Add(X + NewBounds.X1 + OldBounds.X1, Y + NewBounds.Y1 + OldBounds.Y1);
      end;
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.PointsNearby(Other: TPointArray; MinDist, MaxDist: Double): TPointArray;
var
  Tree: TSlackTree;
  I: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init();

  if (Length(Self) > 0) and (Length(Other) > 0) then
  begin
    Tree.Init(Copy(Self));
    for I := 0 to High(Other) do
      Buffer.Add(Tree.RangeQueryEx(Other[I], MinDist, MinDist, MaxDist, MaxDist, True));
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.PointsNearby(Other: TPointArray; MinDistX, MinDistY, MaxDistX, MaxDistY: Double): TPointArray;
var
  Tree: TSlackTree;
  I: Integer;
  Buffer: TSimbaPointBuffer;
begin
  Buffer.Init();

  if (Length(Self) > 0) and (Length(Other) > 0) then
  begin
    Tree.Init(Copy(Self));
    for I := 0 to High(Other) do
      Buffer.Add(Tree.RangeQueryEx(Other[I], MinDistX, MinDistY, MaxDistX, MaxDistY, True));
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.IsPointNearby(Other: TPoint; MinDist, MaxDist: Double): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(Self) do
    if InRange(Distance(Self[I], Other), MinDist, MaxDist) then
      Exit(True);

  Result := False;
end;

function TPointArrayHelper.IsPointNearby(Other: TPoint; MinDistX, MinDistY, MaxDistX, MaxDistY: Double): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(Self) do
    if InRange(Abs(Self[I].X - Other.X), MinDistX, MaxDistX) and
       InRange(Abs(Self[I].Y - Other.Y), MinDistY, MaxDistY) then
      Exit(True);

  Result := False;
end;

function TPointArrayHelper.NearestPoint(Other: TPoint): TPoint;
var
  I: Integer;
  Dist, BestDist: Double;
begin
  if (Length(Self) > 0) then
  begin
    BestDist := Sqr(Self[0].x-Other.x) + Sqr(Self[0].y-Other.y);
    Result := Self[0];

    for I := 1 to High(Self) do
    begin
      Dist := Sqr(Self[I].x-Other.x) + Sqr(Self[I].y-Other.y);
      if (Dist < BestDist) then
      begin
        BestDist := Dist;
        Result := Self[I];
      end;
    end;
  end else
    Result := TPoint.ZERO;
end;

function TPointArrayHelper.FurthestPoint(Other: TPoint): TPoint;
var
  I: Integer;
  Dist, BestDist: Double;
begin
  if (Length(Self) > 0) then
  begin
    BestDist := Sqr(Self[0].x-Other.x) + Sqr(Self[0].y-Other.y);
    Result := Self[0];

    for I := 1 to High(Self) do
    begin
      Dist := Sqr(Self[I].x-Other.x) + Sqr(Self[I].y-Other.y);
      if (Dist > BestDist) then
      begin
        BestDist := Dist;
        Result := Self[I];
      end;
    end;
  end else
    Result := TPoint.ZERO;
end;

function TPointArrayHelper.Sort(Weights: TIntegerArray; LowToHigh: Boolean): TPointArray;
begin
  Result := Copy(Self);
  Weights := Copy(Weights);

  specialize TArraySortWeighted<TPoint, Integer>.QuickSort(Result, Weights, Low(Result), High(Result), LowToHigh);
end;

function TPointArrayHelper.Sort(Weights: TSingleArray; LowToHigh: Boolean): TPointArray;
begin
  Result := Copy(Self);
  Weights := Copy(Weights);

  specialize TArraySortWeighted<TPoint, Single>.QuickSort(Result, Weights, Low(Result), High(Result), LowToHigh);
end;

function TPointArrayHelper.Sort(Weights: TDoubleArray; LowToHigh: Boolean): TPointArray;
begin
  Result := Copy(Self);
  Weights := Copy(Weights);

  specialize TArraySortWeighted<TPoint, Double>.QuickSort(Result, Weights, Low(Result), High(Result), LowToHigh);
end;

function TPointArrayHelper.SortFrom(From: TPoint): TPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Sqr(From.X - Self[i].X) + Sqr(From.Y - Self[i].Y);

  Result := Sort(Weights, True);
end;

function TPointArrayHelper.SortCircular(Center: TPoint; StartDegrees: Integer; Clockwise: Boolean): TPointArray;
var
  I: Integer;
  Weights: TDoubleArray;
begin
  StartDegrees := StartDegrees mod 360;
  if (StartDegrees < 0) then
    StartDegrees := 360 + StartDegrees;
  StartDegrees := 360 - StartDegrees;

  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Round(TSimbaGeometry.AngleBetween(Self[I], Center) + StartDegrees) mod 360;

  Result := Sort(Weights, Clockwise);
end;

function TPointArrayHelper.SortByX(LowToHigh: Boolean): TPointArray;
var
  Weights: TIntegerArray;
  I: Integer;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].X;

  Result := Sort(Weights, LowToHigh);
end;

function TPointArrayHelper.SortByY(LowToHigh: Boolean): TPointArray;
var
  Weights: TIntegerArray;
  I: Integer;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].Y;

  Result := Sort(Weights, LowToHigh);
end;

function TPointArrayHelper.SortByRow(LowToHigh: Boolean = True): TPointArray;
var
  Weights: TIntegerArray;
  Width, I: Integer;
begin
  Width := Self.Bounds.Width;

  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[i] := Self[i].Y * Width + Self[i].X;

  Result := Self.Sort(Weights, LowToHigh);
end;

function TPointArrayHelper.SortByColumn(LowToHigh: Boolean = True): TPointArray;
var
  Weights: TIntegerArray;
  Height, I: Integer;
begin
  Height := Self.Bounds.Height;

  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[i] := Self[i].X * Height + Self[i].Y;

  Result := Self.Sort(Weights, LowToHigh);
end;

function TPointArrayHelper.Rows: T2DPointArray;
var
  TPA: TPointArray;
  I, Len, Start, Current: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  TPA := SortByRow();

  I := 0;
  Len := Length(Self);
  while (I < Len) do
  begin
    Start := I;
    Current := TPA[I].Y;
    while (I < Len) and (TPA[I].Y = Current) do
      Inc(I);

    Buffer.Add(Copy(TPA, Start, I-Start));
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.Columns: T2DPointArray;
var
  TPA: TPointArray;
  I, Len, Start, Current: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  TPA := SortByColumn();

  I := 0;
  Len := Length(Self);
  while (I < Len) do
  begin
    Start := I;
    Current := TPA[I].X;
    while (I < Len) and (TPA[I].X = Current) do
      Inc(I);

    Buffer.Add(Copy(TPA, Start, I-Start));
  end;

  Result := Buffer.ToArray(False);
end;

function TPointArrayHelper.Split(DistX, DistY: Single): T2DPointArray;
var
  PointIndex, LastPointIndex: Integer;
  ProcessedCount: Integer;
  ClusterSize, ClusterPointIndex: Integer;
  Points: TPointArray;
  Current: TSimbaPointBuffer;
  Clusters: TSimbaPointArrayBuffer;
  xsq, ysq, xxyy: Single;
begin
  if (Length(Self) = 0) then
    Result := []
  else
  if (Length(Self) = 1) then
    Result := [Copy(Self)]
  else
  begin
    Clusters.Init(64);
    Current.Init(256);

    xsq := Sqr(DistX);
    ysq := Sqr(DistY);
    xxyy := xsq * ysq;

    Points := Copy(Self);
    LastPointIndex := High(Points);
    ProcessedCount := 0;
    while ((LastPointIndex - ProcessedCount) >= 0) do
    begin
      if (Current.Count > 0) then
        Clusters.Add(Current.ToArray());
      Current.Clear();
      Current.Add(Points[0]);

      Points[0] := Points[LastPointIndex - ProcessedCount];
      Inc(ProcessedCount);
      ClusterSize := 1;
      ClusterPointIndex := 0;

      while (ClusterPointIndex < ClusterSize) do
      begin
        PointIndex := 0;
        while (PointIndex <= (LastPointIndex - ProcessedCount)) do
        begin
          if Sqr(Current[ClusterPointIndex].X - Points[PointIndex].X) * ysq + Sqr(Current[ClusterPointIndex].Y - Points[PointIndex].Y) * xsq <= xxyy then
          begin
            Current.Add(Points[PointIndex]);
            Points[PointIndex] := Points[LastPointIndex - ProcessedCount];
            Inc(ProcessedCount);
            Inc(ClusterSize);
            Dec(PointIndex);
          end;
          Inc(PointIndex);
        end;
        Inc(ClusterPointIndex);
      end;
    end;

    if (Current.Count > 0) then
      Clusters.Add(Current.ToArray());

    Result := Clusters.ToArray(False);
  end;
end;

function TPointArrayHelper.Split(Dist: Single): T2DPointArray;
begin
  Result := Split(Dist, Dist);
end;

function TPointArrayHelper.Cluster(DistX, DistY: Single): T2DPointArray;
type
  TPointScan = record
    SkipRow: Boolean;
    HasPoints: Boolean;
  end;
  TPointScanMatrix = array of array of TPointScan;
var
  I, X, Y, OffsetX, OffsetY, Len: Integer;
  xr, yr: Integer;
  xsq, ysq, xxyy: Single;
  PointScan: TPointScanMatrix;
  Queue: TSimbaPointBuffer;
  TPA: TPointArray;
  ScanBounds: TBox;
  P: TPoint;
  SkipRow: Boolean;
  Buffer: TSimbaPointBuffer;
  ResultBuffer: TSimbaPointArrayBuffer;
begin
  Len := Length(Self);

  if (Len = 0) then
    Result := []
  else
  if (Len = 1) then
    Result := [Copy(Self)]
  else
  if (Len < 700) then // Split is cheaper on small arrays
    Result := Split(DistX, DistY)
  else
  begin
    ResultBuffer.Init(64);
    Buffer.Init(256);
    Queue.Init(256);

    xr := Round(DistX);
    yr := Round(DistY);
    xsq := Sqr(DistX);
    ysq := Sqr(DistY);
    xxyy := xsq * ysq;

    with Self.Bounds() do
    begin
      OffsetX := X1 - xr;
      OffsetY := Y1 - yr;

      SetLength(PointScan,
        Height + (yr * 2),
        Width  + (xr * 2)
      );
    end;

    TPA := Self.Offset(-OffsetX, -OffsetY);
    for I := 0 to High(TPA) do
      PointScan[TPA[I].Y, TPA[I].X].HasPoints := True;

    for I := 0 to High(TPA) do
      if PointScan[TPA[I].Y, TPA[I].X].HasPoints then
      begin
        if (Buffer.Count > 0) then
          ResultBuffer.Add(Buffer.ToArray());

        Buffer.Clear();
        Buffer.Add(TPA[I].X + OffsetX, TPA[I].Y + OffsetY);

        Queue.Clear();
        Queue.Add(TPA[I]);

        PointScan[TPA[I].Y, TPA[I].X].HasPoints := False;

        while (Queue.Count > 0) do
        begin
          P := Queue.Pop;

          ScanBounds.X1 := (P.X - xr);
          ScanBounds.Y1 := (P.Y - yr);
          ScanBounds.X2 := (P.X + xr);
          ScanBounds.Y2 := (P.Y + yr);

          for Y := ScanBounds.Y1 to ScanBounds.Y2 do
          begin
            if PointScan[Y, ScanBounds.X2].SkipRow then
              Continue;

            SkipRow := True;
            for X := ScanBounds.X1 to ScanBounds.X2 do
            begin
              if not PointScan[Y, X].HasPoints then
                Continue;

              if Sqr(X - P.X) * ysq + Sqr(Y - P.Y) * xsq <= xxyy then
              begin
                Buffer.Add(X + OffsetX, Y + OffsetY);
                PointScan[Y, X].HasPoints := False;
                Queue.Add(X, Y);
              end else
                SkipRow := False;
            end;

            if SkipRow then
              PointScan[Y, ScanBounds.X2].SkipRow := True;
          end;
        end;
      end;

    if (Buffer.Count > 0) then
      ResultBuffer.Add(Buffer.ToArray());

    Result := ResultBuffer.ToArray(False);
  end;
end;

function TPointArrayHelper.Cluster(Dist: Single): T2DPointArray;
begin
  Result := Cluster(Dist, Dist);
end;

function TPointArrayHelper.Partition(Width, Height: Integer): T2DPointArray;
type
  TScan = record
    X, Y: Integer;
    Arr: TSimbaPointBuffer;
  end;
  TScanArray = array of TScan;
var
  I, J, Len: Integer;
  Scans: TScanArray;
  ScanCount: Integer;
label
  Next;
begin
  Len := Length(Self);

  if (Len = 0) then
    Result := []
  else
  if (Len = 1) then
    Result := [Copy(Self)]
  else
  begin
    SetLength(Scans, 32);
    ScanCount := 0;

    for I := 0 to Len - 1 do
      with Self[I] do
      begin
        for J := 0 to ScanCount - 1 do
          if (Abs(X - Scans[J].X) <= Width) and (Abs(Y - Scans[J].Y) <= Height) then
          begin
            Scans[J].Arr.Add(X, Y);

            goto Next;
          end;

        if (Length(Scans) = ScanCount) then
          SetLength(Scans, Length(Scans) * 2);

        Scans[ScanCount].X := X;
        Scans[ScanCount].Y := Y;
        Scans[ScanCount].Arr.Add(X, Y);

        Inc(ScanCount);

        Next:
      end;

    SetLength(Result, ScanCount);
    for I := 0 to ScanCount - 1 do
      Result[I] := Scans[I].Arr.ToArray(False);
  end;
end;

function TPointArrayHelper.Partition(Dist: Integer): T2DPointArray;
type
  TScan = record
    X, Y: Integer;
    Arr: TSimbaPointBuffer;
  end;
  TScanArray = array of TScan;
var
  I, J, Len, DistSqr: Integer;
  Scans: TScanArray;
  ScanCount: Integer;
label
  Next;
begin
  Len := Length(Self);

  if (Len = 0) then
    Result := []
  else
  if (Len = 1) then
    Result := [Copy(Self)]
  else
  begin
    DistSqr := Sqr(Dist);

    SetLength(Scans, 32);
    ScanCount := 0;

    for I := 0 to Len - 1 do
      with Self[I] do
      begin
        for J := 0 to ScanCount - 1 do
          if Sqr(X - Scans[J].X) + Sqr(Y - Scans[J].Y) <= DistSqr then
          begin
            Scans[J].Arr.Add(X, Y);

            goto Next;
          end;

        if (Length(Scans) = ScanCount) then
          SetLength(Scans, Length(Scans) * 2);

        Scans[ScanCount].X := X;
        Scans[ScanCount].Y := Y;
        Scans[ScanCount].Arr.Add(X, Y);

        Inc(ScanCount);

        Next:
      end;

    SetLength(Result, ScanCount);
    for I := 0 to ScanCount - 1 do
      Result[I] := Scans[I].Arr.ToArray(False);
  end;
end;

function TPointArrayHelper.PartitionEx(StartPoint: TPoint; BoxWidth, BoxHeight: Integer): T2DPointArray;
var
  I, X, Y, ColCount, RowCount, ResultCount: Integer;
  B: TBox;
  Buffers: array of TSimbaPointBuffer;
begin
  Result := Default(T2DPointArray);

  if (Length(Self) > 0) then
  begin
    with Self.Bounds() do
    begin
      B.X1 := Min(StartPoint.X, X1);
      B.Y1 := Min(StartPoint.Y, Y1);
      B.X2 := X2;
      B.Y2 := Y2;
    end;

    ColCount := Ceil(B.Width / BoxWidth);
    RowCount := Ceil(B.Height / BoxHeight);

    SetLength(Buffers, (ColCount + 1) * (RowCount + 1));
    for I := 0 to High(Self) do
    begin
      X := (Self[I].X - B.X1) div BoxWidth;
      Y := (Self[I].Y - B.Y1) div BoxHeight;

      Buffers[(Y * ColCount) + X].Add(Self[I]);
    end;

    ResultCount := 0;

    SetLength(Result, Length(Buffers));
    for I := 0 to High(Result) do
      if (Buffers[I].Count > 0) then
      begin
        Result[ResultCount] := Buffers[I].ToArray(False);
        Inc(ResultCount);
      end;
    SetLength(Result, ResultCount);
  end;
end;

function TPointArrayHelper.PartitionEx(BoxWidth, BoxHeight: Integer): T2DPointArray;
begin
  Result := PartitionEx(TPoint.Create(Integer.MaxValue, Integer.MaxValue), BoxWidth, BoxHeight);
end;

function TPointArrayHelper.Intersection(Other: TPointArray): TPointArray;
var
  box: TBox;
  test: TBooleanArray;
  tmp,x,y: TPointArray;
  w,h,i,c: Integer;
begin
  // smallest array (x) define bounds and scanline
  x := Self;
  y := Other;
  if Length(x) > Length(y) then
  begin
    tmp := x;
    x   := y;
    y   := tmp;
  end;
  box := x.Bounds();

  { Fallback to safe dictionary:
     * Fewer than 1 in area of 5000
     * Larger than 512MB in memory (approx 25K*25K area) 
  }
  if (box.Area*SizeOf(TPoint) > $20000000) or
     (Length(x)/box.Area < 0.0002) then
  begin
    Exit(specialize TArrayRelationship<TPoint>.Intersection(x, y));
  end;

  SetLength(test, box.Area);

  w := box.Width;
  h := box.Height;
  for i:=0 to High(x) do
    test[(x[i].y - box.y1) * w + (x[i].x - box.x1)] := True;
  
  SetLength(Result, Min(Length(x),Length(y)));
  c := 0;
  for i:=0 to High(y) do
    if InRange(y[i].x - box.x1, 0, w-1) and InRange(y[i].y - box.y1, 0, h-1) and
       (test[(y[i].y - box.y1) * w + (y[i].x - box.x1)]) then
    begin
      Result[c] := y[i];
      Inc(c);
    end;
  SetLength(Result, c); 
end;

function TPointArrayHelper.SymmetricDifference(Other: TPointArray): TPointArray;
begin
  Result := specialize TArrayRelationship<TPoint>.SymmetricDifference(Self, Other);
end;

function TPointArrayHelper.Difference(Other: TPointArray): TPointArray;
var
  box: TBox;
  test: TBooleanArray;
  x,y: TPointArray;
  w,h,i,c: Integer;
begin
  x := Self;
  y := Other;

  box := y.Bounds(); // bounds of the array we're subtracting

  { Fallback to safe dictionary:
     * Fewer than 1 in area of 5000
     * Larger than 512MB in memory (approx 25K*25K area)
  }
  if (box.Area*SizeOf(TPoint) > $20000000) or
     (Length(y)/box.Area < 0.0002) then
  begin
    Exit(specialize TArrayRelationship<TPoint>.Difference(x, y));
  end;

  SetLength(test, box.Area);
  w := box.Width;
  h := box.Height;

  // Mark points of `Other` (y) within the bounds as True in `test`
  for i := 0 to High(y) do
  begin
    if InRange(y[i].x - box.x1, 0, w - 1) and InRange(y[i].y - box.y1, 0, h - 1) then
      test[(y[i].y - box.y1) * w + (y[i].x - box.x1)] := True;
  end;

  SetLength(Result, Length(x));
  c := 0;

  // Iterate through 'Self' (x)
  for i := 0 to High(x) do
  begin
    // Check if the point is within the bounds of 'Other
    // if it's outside the bounds we can add this difference
    if not (InRange(x[i].x - box.x1, 0, w - 1) and InRange(x[i].y - box.y1, 0, h - 1)) then
    begin
      Result[c] := x[i];
      Inc(c);
    end
    else if not test[(x[i].y - box.y1) * w + (x[i].x - box.x1)] then
    begin
      // If it's INSIDE the bounds but NOT marked in 'test', it's also in the difference
      Result[c] := x[i];
      Inc(c);
    end;
  end;
  SetLength(Result, c);
end;

function TPointArrayHelper.DistanceTransform: TSingleMatrix;

  function EucDist(const x1,x2:Int32): Int32; inline;
  begin
    Result := Sqr(x1) + Sqr(x2);
  end;

  function EucSep(const i,j, ii,jj:Int32): Int32; inline;
  begin
    Result := Trunc((sqr(j) - sqr(i) + sqr(jj) - sqr(ii)) / (2*(j-i)));
  end;

  function Transform(const binIm:TIntegerArray; m,n:Int32): TSingleMatrix;
  var
    x,y,h,w,i,wid:Int32;
    tmp,s,t: TIntegerArray;
  begin
    // first pass
    SetLength(tmp, m*n);
    h := n-1;
    w := m-1;
    for x:=0 to w do
    begin
      if binIm[x] = 0 then
        tmp[x] := 0
      else
        tmp[x] := m+n;

      for y:=1 to h do
        if (binIm[y*m+x] = 0) then
          tmp[y*m+x] := 0
        else
          tmp[y*m+x] := 1 + tmp[(y-1)*m+x];

      for y:=h-1 downto 0 do
        if (tmp[(y+1)*m+x] < tmp[y*m+x]) then
          tmp[y*m+x] := 1 + tmp[(y+1)*m+x]
    end;

    // second pass
    SetLength(Result,n,m);
    SetLength(s,m);
    SetLength(t,m);
    wid := 0;
    for y:=0 to h do
    begin
      i := 0;
      s[0] := 0;
      t[0] := 0;

      for x:=1 to W do
      begin
        while (i >= 0) and (EucDist(t[i]-s[i], tmp[y*m+s[i]]) > EucDist(t[i]-x, tmp[y*m+x])) do
          Dec(i);
        if (i < 0) then
        begin
          i := 0;
          s[0] := x;
        end else
        begin
          wid := 1 + EucSep(s[i], x, tmp[y*m+s[i]], tmp[y*m+x]);
          if (wid < m) then
          begin
            Inc(i);
            s[i] := x;
            t[i] := wid;
          end;
        end;
      end;

      for x:=W downto 0 do
      begin
        Result[y,x] := Sqrt(EucDist(x-s[i], tmp[y*m+s[i]]));
        if (x = t[i]) then
          Dec(i);
      end;
    end;
  end;

var
  Data:TIntegerArray;
  w,h,i:Int32;
  B:TBox;
begin
  Result := nil;
  if (Length(Self) = 0) then
    Exit;

  B := Self.Bounds();
  B.Y1 -= 1;
  B.X1 -= 1;
  w := (B.x2 - B.X1) + 2;
  h := (B.y2 - B.Y1) + 2;
  SetLength(Data, h*w);
  for i:=0 to High(Self) do
    Data[(Self[i].y-B.Y1)*w+(Self[i].x-B.X1)] := 1;

  Result := Transform(data,w,h);
end;

function TPointArrayHelper.QuickSkeleton(): TPointArray;
var
  skeletonCore,close,adjacent: TPointArray;
  binary: TIntegerMatrix;
  dt: TSingleMatrix;
  i,j,c,h,w,distance: Int32;
  p,n,b: TPoint;
  base: single;
  validTip,growing: Boolean;
  Res: TSimbaPointBuffer;
begin
  b   := Self.Bounds.Corners[0];
  dt  := Self.DistanceTransform();
  skeletonCore := dt.ArgExtrema($FFFFFFF, True, False);

  // patch skeleton connectivity by examining tip of branches
  // we first have to fine them!
  // Once found we can actually just pick the neighbour pixel that has highest
  // distance score then itself, repeat unless it's in the skeletal core.

  Res.Init();

  SetLength(adjacent, 8);
  SetLength(close, 3);
  binary.SetSize(dt.Width, dt.Height);
  binary.SetValue(skeletonCore, 1);
  w := dt.Width;
  h := dt.Height;
  for i:=0 to High(skeletonCore) do
  begin
    // check if p is a tip of a branch
    // a tip can at most have two neighbours if the two points are nect to each other
    // otherwise a tip will always have one or less neighbours
    p := skeletonCore[i];

    GetAdjacent8(adjacent, p);
    c := 0;
    validTip := True;
    for j:=0 to High(adjacent) do
      if (adjacent[j].y >= 0) and (adjacent[j].y < H) and (adjacent[j].x >= 0) and (adjacent[j].x < W) and
         (binary[adjacent[j].y, adjacent[j].x] = 1) then
      begin
        close[c] := adjacent[j];
        Inc(c);

        if c = 3 then
        begin
         validTip := False;
         break;
        end;

        if (c = 2) then
          if (Abs(close[0].x-close[1].x) + Abs(close[0].y-close[1].y) <= 1) then
            validTip := True
          else begin
            validTip := False;
            break;
          end;
      end;

    if not validTip then continue;

    // Now lets check if we can grow this tip further by looking at neighbours.
    //
    // We trace so long as dt-value is larger, or until we hit an already existing branch
    // Tracing is a simple 8-way pt scan
    growing  := True;
    distance := 0;
    while growing do
    begin
      growing := False;

      GetAdjacent8(adjacent, p);
      base := dt[p.y,p.x];
      for n in adjacent do
        if (n.y >= 0) and (n.y < H) and (n.x >= 0) and (n.x < W) and
           (dt[n.y,n.x] > base) then
        begin
          base := dt[n.y,n.x];

          // if this pt already exists then we dont want it, we might be finished now.
          if (binary[n.y,n.x] = 1) then
          begin
            // this little snippet kills of side-by-side skeltons
            // we are 1 or more distance away from inital growth, might have hit
            // a new branch, if so, we can stop growing
            if (distance >= 1) then
            begin
              growing := False;
              break;
            end;
            continue;
          end else begin
            p := n;
            growing := True;
          end;

        end;
      if growing then
      begin
        binary[p.y,p.x] := 1;
        Res.Add(p);
        Inc(distance);
      end;
    end;
  end;

  Res.Add(skeletonCore);
  Result := Res.ToArray();
  Result := Result.Offset(b.x-1,b.y-1); //disttransform offsets
end;

function TPointArrayHelper.Circularity: Double;
begin
  Result := MinAreaCircle().Circularity(Self);
end;

(*
  Smallest bounding circle algorithm by Slacky
  https://en.wikipedia.org/wiki/Smallest-circle_problem

  Time complexity: O(n log n)
*)
function TPointArrayHelper.MinAreaCircle(): TCircle;
var
  poly: TPolygon;
  p1,p2,p3,p,q,t: TPoint;
begin
  poly := Self.ConvexHull();  // O(n log n)
  poly.FurthestPoints(p1, p2); // O(m^2) call - ugh

  p.x := (p1.x+p2.x) div 2;
  p.y := (p1.y+p2.y) div 2;
  t := TPointArray(poly).FurthestPoint(p);

  // Two Point Circle
  if (p1 = t) or (p2 = t) then
    Exit(TCircle.Create(p.x,p.y, Ceil( p1.DistanceTo(p2) / 2 )));

  // Three Point Circle
  p := TTriangle.Create(p1, p2, t).Circumcircle().Center;
  q := TPointArray(poly).FurthestPoint(p);

  if Sign(TSimbaGeometry.CrossProduct(q,  p1, p2)) = Sign(TSimbaGeometry.CrossProduct(t, p1, p2)) then
    p3 := q
  else
    p3 := t;

  p := TTriangle.Create(p1,p2,p3).Circumcircle().Center;
  q := TPointArray(poly).FurthestPoint(p);
  if (p1 <> q) and (p2 <> q) and (p3 <> q) then
  begin
    p.x := (p3.x+q.x) div 2;
    p.y := (p3.y+q.y) div 2;
    if p1.DistanceTo(p) < p2.DistanceTo(p) then
    begin
      p1 := p2;
      p2 := q;
    end else
      p2 := q;

    p := TTriangle.Create(p1,p2,p3).Circumcircle().Center;
    q := TPointArray(poly).FurthestPoint(p);
    if (p1 <> q) and (p2 <> q) and (p3 <> q) then
      p1 := q;
  end;

  Result := TTriangle.Create(p1,p2,p3).Circumcircle();
end;

(*
  Concave hull approximation using k nearest neighbors
  Instead of describing a specific max distance we assume that the boundary points are evenly spread out
  so we can simply extract a number of neighbors and connect the hull of those.
  Worst case it cuts off points.

  Will reduce the TPA to a simpler shape if it's dense, defined by epsilon.

  If areas are cut off, you have two options based on your needs:
  1. Increase "Epsilon", this will reduce accurate.. But it's faster.
  2. Increase "kCount", this will maintain accuracy.. But it's slower.
*)
function TPointArrayHelper.ConcaveHull(Epsilon:Double=2.5; kCount:Int32=5): TPolygon;
var
  TPA, pts: TPointArray;
  Buffer: TSimbaPointBuffer;
  tree: TSlackTree;
  i: Int32;
  B: TBox;
begin
  B := Self.Bounds();
  TPA := Self.PartitionEx(TPoint.Create(B.X1-Round(Epsilon), B.Y1-Round(Epsilon)), Round(Epsilon*2-1), Round(Epsilon*2-1)).Means();
  if Length(TPA) <= 2 then
    Exit(TPA);

  tree.Init(TPA);
  Buffer.Init(256);
  for i:=0 to High(tree.data) do
  begin
    pts := tree.KNearest(tree.data[i].split, kCount, False);
    if Length(pts) <= 1 then
      Continue;
    pts := TPointArray(pts.ConvexHull()).Connect();

    Buffer.Add(pts);
  end;
  
  Result := TPolygon(TPointArray(Buffer.ToArray(False)).Border()).DouglasPeucker(Max(2, Epsilon/2));
end;

(*
  Concave hull approximation using range query based on given distance "MaxLeap".
  if maxleap doesn't cover all of the input then several output polygons will be created.
  MaxLeap is by default automatically calulcated by the density of the polygon
  described by convexhull. But can be changed.

  Higher maxleap is slower.
  Epsilon describes how accurate you want your output, and have some impact on speed.
*)
function TPointArrayHelper.ConcaveHullEx(MaxLeap: Double=-1; Epsilon:Double=2): TPolygonArray;
var
  TPA, pts: TPointArray;
  tree: TSlackTree;
  i: Int32;
  B: TBox;
  Buffer: TSimbaPointBuffer;
begin
  B := Self.Bounds();
  TPA := Self.PartitionEx(TPoint.Create(B.X1-Round(Epsilon), B.Y1-Round(Epsilon)), Round(Epsilon*2-1), Round(Epsilon*2-1)).Means();
  if Length(TPA) <= 2 then
    Exit([TPA]);
  tree.Init(TPA);

  if MaxLeap = -1 then
    MaxLeap := Ceil(Sqrt(TPA.ConvexHull().Area / Length(TPA)) * Sqrt(2));

  MaxLeap := Max(MaxLeap, Epsilon*2);
  for i:=0 to High(tree.data) do
  begin
    pts := tree.RangeQueryEx(tree.data[i].split, MaxLeap,MaxLeap, False);
    if Length(pts) <= 1 then
      Continue;

    Buffer.Add(TPointArray(pts.ConvexHull()).Connect());
  end;

  pts := Buffer.ToArray(False);
  for pts in pts.Cluster(2) do
    Result := Result + [TPolygon(pts.Border()).DouglasPeucker(Epsilon)];
end;

(*
  Finds the defects in relation to a convex hull of the given concave hull.
  EConvexityDefects.All     -> Keeps all convex points as well.
  EConvexityDefects.Minimal -> Keeps the convex points that was linked to a defect
  EConvexityDefects.None    -> Only defects
*)
function TPointArrayHelper.ConvexityDefects(Epsilon: Single; Mode: EConvexityDefects): TPointArray;
var
  x,y,i,j,k: Int32;
  dist, best: Single;
  pt: TPoint;
  concavePoly: TPointArray;
  convex: TPointArray;
  Buffer: TSimbaPointBuffer;
begin
  concavePoly := Self;
  convex := ConcavePoly.ConvexHull();

  for x:=0 to High(ConcavePoly) do
  begin
    i := convex.IndexOf(ConcavePoly[x]);

    if i <> -1 then
    begin
      j := (i+1) mod Length(convex);
      y := concavePoly.IndexOf(convex[j]);

      best := 0;
      for k:=y to x do
      begin
        dist := TSimbaGeometry.DistToLine(concavePoly[k], convex[i], convex[j]);
        if (dist > best) then
        begin
          best := dist;
          pt := concavePoly[k];
        end;
      end;

      if (best >= Epsilon) then
      begin
        if (Mode = EConvexityDefects.MINIMAL) and ((Buffer.Count = 0) or (Buffer.Last <> convex[j])) then Buffer.Add(convex[j]);
        if (best > 0) then
          Buffer.Add(pt{%H-});
        if (Mode = EConvexityDefects.MINIMAL) then Buffer.Add(convex[i]);
      end;

      if (Mode = EConvexityDefects.ALL) then
        Buffer.Add(convex[i]);
    end;
  end;

  Result := Buffer.ToArray(False);
end;

procedure TPointArrayHelper.ToAxes(out X, Y: TIntegerArray);
var
  I,H:Integer;
begin
  H := High(Self);
  SetLength(X, H+1);
  SetLength(Y, H+1);
  for I := 0 to H do
  begin
    X[I] := Self[I].X;
    Y[I] := Self[I].Y;
  end;
end;

function TPointArrayHelper.Median: TPoint;
var
  X, Y: TIntegerArray;
  Mid: Integer;
begin
  if (Length(Self) = 0) then
    Result := TPoint.ZERO
  else
  if (Length(Self) = 1) then
    Result := Self[0]
  else
  begin
    ToAxes(X, Y);
    X.Sort();
    Y.Sort();

    Mid := Length(Self) div 2;

    if (Length(Self) mod 2) = 0 then
    begin
      Result.X := X[Mid];
      Result.Y := Y[Mid];
    end else
    begin
      Result.X := Round((X[Mid] + X[Mid+1]) / 2);
      Result.Y := Round((Y[Mid] + Y[Mid+1]) / 2);
    end;
  end;
end;

function T2DPointArrayHelper.Sort(Weights: TIntegerArray; LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
begin
  Weights := Copy(Weights);
  SetLength(Result, Length(Self));
  for I := 0 to High(Result) do
    Result[I] := Copy(Self[I]);

  specialize TArraySortWeighted<TPointArray, Integer>.QuickSort(Result, Weights, Low(Result), High(Result), LowToHigh);
end;

function T2DPointArrayHelper.Sort(Weights: TDoubleArray; LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
begin
  Weights := Copy(Weights);
  SetLength(Result, Length(Self));
  for I := 0 to High(Result) do
    Result[I] := Copy(Self[I]);

  specialize TArraySortWeighted<TPointArray, Double>.QuickSort(Result, Weights, Low(Result), High(Result), LowToHigh);
end;

function T2DPointArrayHelper.SortFromSize(Size: Integer): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Abs(Size - Length(Self[I]));

  Result := Self.Sort(Weights, True);
end;

function T2DPointArrayHelper.SortFromIndex(From: TPoint; Index: Integer): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
  begin
    if (Index >= Length(Self[I])) then
      raise Exception.CreateFmt('T2DPointArray.SortFromIndex: Index %d out of range', [Index]);

    Weights[I] := Sqr(From.X - Self[I][Index].X) + Sqr(From.Y - Self[I][Index].Y);
  end;

  Result := Self.Sort(Weights, True);
end;

function T2DPointArrayHelper.SortFromFirstPoint(From: TPoint): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  Result := Self.ExtractSize(0, __GT__);

  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Sqr(From.X - Self[I][0].X) + Sqr(From.Y - Self[I][0].Y);

  specialize TArraySortWeighted<TPointArray, Integer>.QuickSort(Result, Weights, Low(Result), High(Result), True);
end;

function T2DPointArrayHelper.SortFromFirstPointX(From: TPoint): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  Result := Self.ExtractSize(0, __GT__);

  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Sqr(From.X - Self[I][0].X);

  specialize TArraySortWeighted<TPointArray, Integer>.QuickSort(Result, Weights, Low(Result), High(Result), True);
end;

function T2DPointArrayHelper.SortFromFirstPointY(From: TPoint): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  Result := Self.ExtractSize(0, __GT__);

  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Sqr(From.Y - Self[I][0].Y);

  specialize TArraySortWeighted<TPointArray, Integer>.QuickSort(Result, Weights, Low(Self), High(Self), True);
end;

function T2DPointArrayHelper.SortFrom(From: TPoint): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    with Self[I].Mean() do
      Weights[I] := Sqr(From.X - X) + Sqr(From.Y - Y);

  Result := Sort(Weights, True);
end;

function T2DPointArrayHelper.Offset(P: TPoint): T2DPointArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Result) do
    Result[I] := Self[I].Offset(P);
end;

function T2DPointArrayHelper.SortByArea(LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
  Weights: TDoubleArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].Area();

  Result := Sort(Weights, LowToHigh);
end;

function T2DPointArrayHelper.SortBySize(LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Length(Self[I]);

  Result := Sort(Weights, LowToHigh);
end;

function T2DPointArrayHelper.SortByDensity(LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
  Weights: TDoubleArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].Density();

  Result := Sort(Weights, LowToHigh);
end;

function T2DPointArrayHelper.SortByX(LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].Bounds.X1;

  Result := Sort(Weights, LowToHigh);
end;

function T2DPointArrayHelper.SortByY(LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].Bounds.Y1;

  Result := Sort(Weights, LowToHigh);
end;

function T2DPointArrayHelper.SortByShortSide(LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].MinAreaRect().ShortSideLen;

  Result := Sort(Weights, LowToHigh);
end;

function T2DPointArrayHelper.SortByLongSide(LowToHigh: Boolean): T2DPointArray;
var
  I: Integer;
  Weights: TIntegerArray;
begin
  SetLength(Weights, Length(Self));
  for I := 0 to High(Self) do
    Weights[I] := Self[I].MinAreaRect().LongSideLen;

  Result := Sort(Weights, LowToHigh);
end;

function T2DPointArrayHelper.ExtractSize(Len: Integer; KeepIf: EComparator): T2DPointArray;
var
  I: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  Buffer.Init(Length(Self));

  for I := 0 to High(Self) do
    case KeepIf of
      __LT__: if (Length(Self[I]) <  Len) then Buffer.Add(Copy(Self[I]));
      __GT__: if (Length(Self[I]) >  Len) then Buffer.Add(Copy(Self[I]));
      __EQ__: if (Length(Self[I]) =  Len) then Buffer.Add(Copy(Self[I]));
      __LE__: if (Length(Self[I]) <= Len) then Buffer.Add(Copy(Self[I]));
      __GE__: if (Length(Self[I]) >= Len) then Buffer.Add(Copy(Self[I]));
      __NE__: if (Length(Self[I]) <> Len) then Buffer.Add(Copy(Self[I]));
    end;

  Result := Buffer.ToArray(False);
end;

function T2DPointArrayHelper.ExtractSizeEx(MinLen, MaxLen: Integer): T2DPointArray;
var
  I: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  Buffer.Init(Length(Self));

  for I := 0 to High(Self) do
    if InRange(Length(Self[I]), MinLen, MaxLen) then
      Buffer.Add(Copy(Self[I]));

  Result := Buffer.ToArray(False);
end;

function T2DPointArrayHelper.ExtractDimensions(MinShortSide, MinLongSide, MaxShortSide, MaxLongSide: Integer): T2DPointArray;
var
  I: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  Buffer.Init(Length(Self));

  for I := 0 to High(Self) do
    with Self[I].MinAreaRect() do
      if InRange(ShortSideLen, MinShortSide, MaxShortSide) and InRange(LongSideLen, MinLongSide, MaxLongSide) then
        Buffer.Add(Copy(Self[I]));

  Result := Buffer.ToArray(False);
 end;

function T2DPointArrayHelper.ExtractDimensionsEx(MinShortSide, MinLongSide: Integer): T2DPointArray;
begin
  Result := Self.ExtractDimensions(MinShortSide, MinLongSide, Integer.MaxValue, Integer.MaxValue);
end;

function T2DPointArrayHelper.ExcludeSize(Len: Integer; RemoveIf: EComparator): T2DPointArray;
var
  I: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  Buffer.Init(Length(Self));

  for I := 0 to High(Self) do
    case RemoveIf of
      __LT__: if not (Length(Self[I]) <  Len) then Buffer.Add(Copy(Self[I]));
      __GT__: if not (Length(Self[I]) >  Len) then Buffer.Add(Copy(Self[I]));
      __EQ__: if not (Length(Self[I]) =  Len) then Buffer.Add(Copy(Self[I]));
      __LE__: if not (Length(Self[I]) <= Len) then Buffer.Add(Copy(Self[I]));
      __GE__: if not (Length(Self[I]) >= Len) then Buffer.Add(Copy(Self[I]));
      __NE__: if not (Length(Self[I]) <> Len) then Buffer.Add(Copy(Self[I]));
    end;

  Result := Buffer.ToArray(False);
end;

function T2DPointArrayHelper.ExcludeSizeEx(MinLen, MaxLen: Integer): T2DPointArray;
var
  I: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  Buffer.Init(Length(Self));

  for I := 0 to High(Self) do
    if not InRange(Length(Self[I]), MinLen, MaxLen) then
      Buffer.Add(Copy(Self[I]));

  Result := Buffer.ToArray(False);
end;

function T2DPointArrayHelper.ExcludeDimensions(MinShortSide, MinLongSide, MaxShortSide, MaxLongSide: Integer): T2DPointArray;
var
  I: Integer;
  Buffer: TSimbaPointArrayBuffer;
begin
  Buffer.Init(Length(Self));

  for I := 0 to High(Self) do
    with Self[I].MinAreaRect() do
      if not (InRange(ShortSideLen, MinShortSide, MaxShortSide) and InRange(LongSideLen, MinLongSide, MaxLongSide)) then
        Buffer.Add(Copy(Self[I]));

  Result := Buffer.ToArray(False);
 end;

function T2DPointArrayHelper.ExcludeDimensionsEx(MinShortSide, MinLongSide: Integer): T2DPointArray;
begin
  Result := Self.ExcludeDimensions(MinShortSide, MinLongSide, Integer.MaxValue, Integer.MaxValue);
end;

function T2DPointArrayHelper.Bounds: TBox;
var
  I: Integer;
begin
  if (Length(Self) = 0) then
    Result := TBox.ZERO
  else
  begin
    Result := Self[0].Bounds();
    for I := 1 to High(Self) do
      if (Length(Self[I]) > 0) then
        Result := Result.Combine(Self[I].Bounds());
  end;
end;

function T2DPointArrayHelper.BoundsArray: TBoxArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    Result[I] := Self[I].Bounds();
end;

function T2DPointArrayHelper.Mean: TPoint;
begin
  Result := Self.Merge().Mean();
end;

function T2DPointArrayHelper.Means: TPointArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Self));
  for I := 0 to High(Self) do
    Result[I] := Self[I].Mean();
end;

function T2DPointArrayHelper.Merge: TPointArray;
var
  I, Len, Count: Integer;
begin
  Count := 0;
  Len := 0;
  for I := 0 to High(Self) do
    Len := Len + Length(Self[I]);

  SetLength(Result, Len);
  for I := 0 to High(Self) do
  begin
    Len := Length(Self[I]);
    if (Len > 0) then
      Move(Self[I, 0], Result[Count], Len * SizeOf(TPoint));

    Count := Count + Len;
  end;
end;

function T2DPointArrayHelper.Smallest: TPointArray;
var
  I: Integer;
begin
  if (Length(Self) = 0) then
    Exit(Default(TPointArray));

  Result := Self[0];
  for I := 1 to High(Self) do
    if (Length(Self[I]) < Length(Result)) Then
      Result := Self[I];
end;

function T2DPointArrayHelper.Largest: TPointArray;
var
  I: Integer;
begin
  if (Length(Self) = 0) then
    Exit(Default(TPointArray));

  Result := Self[0];
  for I := 1 to High(Self) do
    if (Length(Self[I]) > Length(Result)) Then
      Result := Self[I];
end;

function T2DPointArrayHelper.Intersection: TPointArray;
var
  I: Integer;
begin
  if (Length(Self) = 0) then
    Exit(Default(TPointArray));
  if (Length(Self) = 1) then
    Exit(Self[0]);

  Result := Self[0].Intersection(Self[1]);

  if (Length(Result) > 0) and (Length(Self) > 1) then
  begin
    for I := 2 to High(Self) do
      Result := Result + Result.Intersection(Self[i]);
    Result := Result.Unique();
  end;
end;

end.

