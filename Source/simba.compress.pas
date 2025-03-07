{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.compress;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base, simba.encoding;

// TByteArray
function CompressBytes(const Data: TByteArray): TByteArray;
function DecompressBytes(const Data: TByteArray): TByteArray;

// String
function CompressString(S: String; Encoding: EBaseEncoding = EBaseEncoding.b64): String;
function DecompressString(S: String; Encoding: EBaseEncoding = EBaseEncoding.b64): String;

implementation

uses
  basenenc_simba, ZStream;

function CompressBytes(const Data: TByteArray): TByteArray;
var
  InStream: TCompressionstream;
  OutStream: TMemoryStream;
begin
  Result := [];

  OutStream := TMemoryStream.Create();
  InStream := TCompressionStream.Create(clDefault, OutStream);
  try
    InStream.Write(Data[0], Length(Data));
    InStream.Flush();

    SetLength(Result, OutStream.Position);
    if (Length(Result) > 0) then
      Move(OutStream.Memory^, Result[0], Length(Result));
  finally
    InStream.Free();
    OutStream.Free();
  end;
end;

function DecompressBytes(const Data: TByteArray): TByteArray;
var
  InStream: TBytesStream;
  OutStream: Tdecompressionstream;
  ReadCount, TotalCount: Integer;
  Chunk: array[0..2048-1] of Byte;
begin
  TotalCount := 0;

  InStream := TBytesStream.Create(Data);
  OutStream := TDeCompressionStream.Create(InStream);
  try
    repeat
      ReadCount := OutStream.Read(Chunk[0], Length(Chunk));
      if (ReadCount > 0) then
      begin
        if (TotalCount + ReadCount > High(Result)) then
          SetLength(Result, 4 + (High(Result) * 2) + ReadCount);
        Move(Chunk[0], Result[TotalCount], ReadCount);
        Inc(TotalCount, ReadCount);
      end;
    until (ReadCount = 0);
  finally
    InStream.Free();
    OutStream.Free();
  end;

  SetLength(Result, TotalCount);
end;

function CompressString(S: String; Encoding: EBaseEncoding): String;
begin
  Result := BaseEncodeBytes(Encoding, CompressBytes(GetRawStringBytes(S)));
end;

function DecompressString(S: String; Encoding: EBaseEncoding): String;
begin
  Result := GetRawStringFromBytes(DeCompressBytes(BaseDecodeBytes(Encoding, S)));
end;

end.

