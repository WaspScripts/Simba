unit simba.import_kdtree;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base, simba.script;

procedure ImportKDTree(Script: TSimbaScript);

implementation

uses
  lptypes,
  simba.container_kdtree;

(*
    function RefArray(): TKDNodeRefArray;
    function GetItem(i:Int32): PKDNode;
    function InitBranch(): Int32;
    function Copy(): TKDTree;
    procedure Init(const AData: TKDItems);
    function IndexOf(const Value: TSingleArray): Int32;
    function KNearest(Vector: TSingleArray; K: Int32; NotEqual: Boolean = False): TKDItems;
    function RangeQuery(Low, High: TSingleArray): TKDItems;
    function RangeQueryEx(Center: TSingleArray; Radii: TSingleArray; Hide: Boolean): TKDItems;
    function KNearestClassify(Vector: TSingleArray; K: Int32): Int32;
    function WeightedKNearestClassify(Vector: TSingleArray; K: Int32; NotEqual: Boolean = False): Int32;
*)

procedure _LapeKDTreeRefArray(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDNodeRefArray(Result^) := TKDTree(Params^[0]^).RefArray();
end;

procedure _LapeKDTreeGetItem(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PKDNode(Result^) := TKDTree(Params^[0]^).GetItem(Int32(Params^[1]^));
end;

procedure _LapeKDTreeCopy(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDTree(Result^) := TKDTree(Params^[0]^).Copy();
end;

procedure _LapeKDTreeInit(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  TKDTree(Params^[0]^).Init(TKDItems(Params^[1]^));
end;

procedure _LapeKDTreeIndexOf(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := TKDTree(Params^[0]^).IndexOf(TSingleArray(Params^[1]^));
end;

procedure _LapeSlackTreeKNearest(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDItems(Result^) := TKDTree(Params^[0]^).KNearest(TSingleArray(Params^[1]^), Int32(Params^[2]^), Boolean(Params^[3]^));
end;

procedure _LapeSlackTreeRangeQuery(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDItems(Result^) := TKDTree(Params^[0]^).RangeQuery(TSingleArray(Params^[1]^), TSingleArray(Params^[2]^));
end;

procedure _LapeSlackTreeRangeQueryEx(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDItems(Result^) := TKDTree(Params^[0]^).RangeQueryEx(TSingleArray(Params^[1]^), TSingleArray(Params^[2]^), Boolean(Params^[3]^));
end;

procedure _LapeSlackTreeKNearestClassify(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  Int32(Result^) := TKDTree(Params^[0]^).KNearestClassify(TSingleArray(Params^[1]^), Int32(Params^[2]^));
end;

procedure _LapeSlackTreeWeightedKNearestClassify(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  Int32(Result^) := TKDTree(Params^[0]^).WeightedKNearestClassify(TSingleArray(Params^[1]^), Int32(Params^[2]^));
end;



procedure ImportKDTree(Script: TSimbaScript);
begin
  with Script.Compiler do
  begin
    addGlobalType('record Ref: Int32; Vector: TSingleArray; end;', 'TKDItem');
    addGlobalType('array of TKDItem;', 'TKDItems');
    
    addGlobalType('record Split: TKDItem; L, R: Integer; Hidden: Boolean; end;', 'TKDNode');
    addGlobalType('^TKDNode', 'PKDNode');
    
    addGlobalType('array of TKDNode;', 'TKDNodeArray');
    addGlobalType('array of PKDNode;', 'TKDNodeRefArray');
    
    addGlobalType('record Dimensions: Int32; Data: TKDNodeArray; Size: Integer; end;', 'TKDTree');

    addGlobalFunc('function TKDTree.RefArray(): TKDNodeRefArray;', @_LapeKDTreeRefArray);
    addGlobalFunc('function TKDTree.GetItem(i:Int32): PKDNode;', @_LapeKDTreeGetItem);
    addGlobalFunc('function TKDTree.Copy(): TKDTree;', @_LapeKDTreeCopy);
    addGlobalFunc('procedure TKDTree.Init(const AData: TKDItems);', @_LapeKDTreeInit);
    addGlobalFunc('function TKDTree.IndexOf(const Value: TSingleArray): Int32;', @_LapeKDTreeIndexOf);
    addGlobalFunc('function TKDTree.KNearest(Vector: TSingleArray; K: Int32; NotEqual: Boolean = False): TKDItems;', @_LapeSlackTreeKNearest);
    addGlobalFunc('function TKDTree.RangeQuery(Low, High: TSingleArray): TKDItems;', @_LapeSlackTreeRangeQuery);
    addGlobalFunc('function TKDTree.RangeQueryEx(Center: TSingleArray; Radii: TSingleArray; Hide: Boolean): TKDItems;', @_LapeSlackTreeRangeQueryEx);
    addGlobalFunc('function TKDTree.KNearestClassify(Vector: TSingleArray; K: Int32): Int32;', @_LapeSlackTreeKNearestClassify);
    addGlobalFunc('function TKDTree.WeightedKNearestClassify(Vector: TSingleArray; K: Int32): Int32;', @_LapeSlackTreeWeightedKNearestClassify);
  end;
end;

end.

