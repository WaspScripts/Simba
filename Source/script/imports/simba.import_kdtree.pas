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
  Exposed:

  function TKDTree.RefArray(): TKDNodeRefArray;
  function TKDTree.GetItem(i:Int32): PKDNode;
  function TKDTree.InitBranch(): Int32;
  function TKDTree.Copy(): TKDTree;
  procedure TKDTree.Init(const AData: TKDItems);
  function TKDTree.IndexOf(const Value: TSingleArray): Int32;
  function TKDTree.KNearest(Vector: TSingleArray; K: Int32; NotEqual: Boolean = False): TKDItems;
  function TKDTree.RangeQuery(Low, High: TSingleArray): TKDItems;
  function TKDTree.RangeQueryEx(Center: TSingleArray; Radii: TSingleArray; Hide: Boolean): TKDItems;
  function TKDTree.KNearestClassify(Vector: TSingleArray; K: Int32): Int32;
  function TKDTree.WeightedKNearestClassify(Vector: TSingleArray; K: Int32; NotEqual: Boolean = False): Int32;
  function TKDTree.Clusters(Radii: TSingleArray): T2DKDItems;
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

procedure _LapeKDTreeKNearest(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDItems(Result^) := TKDTree(Params^[0]^).KNearest(TSingleArray(Params^[1]^), Int32(Params^[2]^), Boolean(Params^[3]^));
end;

procedure _LapeKDTreeRangeQuery(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDItems(Result^) := TKDTree(Params^[0]^).RangeQuery(TSingleArray(Params^[1]^), TSingleArray(Params^[2]^));
end;

procedure _LapeKDTreeRangeQueryEx(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  TKDItems(Result^) := TKDTree(Params^[0]^).RangeQueryEx(TSingleArray(Params^[1]^), TSingleArray(Params^[2]^), Boolean(Params^[3]^));
end;

procedure _LapeKDTreeKNearestClassify(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  Int32(Result^) := TKDTree(Params^[0]^).KNearestClassify(TSingleArray(Params^[1]^), Int32(Params^[2]^));
end;

procedure _LapeKDTreeWeightedKNearestClassify(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  Int32(Result^) := TKDTree(Params^[0]^).WeightedKNearestClassify(TSingleArray(Params^[1]^), Int32(Params^[2]^));
end;

procedure _LapeKDTreeClusters(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  T2DKDItems(Result^) := TKDTree(Params^[0]^).Clusters(TSingleArray(Params^[1]^));
end;


procedure ImportKDTree(Script: TSimbaScript);
begin
  with Script.Compiler do
  begin
    addGlobalType('record Ref: Int32; Vector: TSingleArray; end;', 'TKDItem');
    addGlobalType('array of TKDItem;',  'TKDItems');
    addGlobalType('array of TKDItems;', 'T2DKDItems');
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
    addGlobalFunc('function TKDTree.KNearest(Vector: TSingleArray; K: Int32; NotEqual: Boolean = False): TKDItems;', @_LapeKDTreeKNearest);
    addGlobalFunc('function TKDTree.RangeQuery(Low, High: TSingleArray): TKDItems;', @_LapeKDTreeRangeQuery);
    addGlobalFunc('function TKDTree.RangeQueryEx(Center: TSingleArray; Radii: TSingleArray; Hide: Boolean): TKDItems;', @_LapeKDTreeRangeQueryEx);
    addGlobalFunc('function TKDTree.KNearestClassify(Vector: TSingleArray; K: Int32): Int32;', @_LapeKDTreeKNearestClassify);
    addGlobalFunc('function TKDTree.WeightedKNearestClassify(Vector: TSingleArray; K: Int32): Int32;', @_LapeKDTreeWeightedKNearestClassify);
    addGlobalFunc('function TKDTree.Clusters(Radii: TSingleArray): T2DKDItems;', @_LapeKDTreeClusters);
  end;
end;

end.

