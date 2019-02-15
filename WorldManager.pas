unit WorldManager;

interface

Uses
  System.SysUtils,
  System.Classes,
  IdCompressorZLib,
  IdGlobal,
  IdBuffer,
  IdContext,
  PacketManager;

type
  TWorldManager = class
  public
    constructor Create();
    destructor Destroy(); override;
    function CompressChunk: TIdBytes;
    procedure AddBlock(X, Y, Z: Int16; BlockID: Byte);
    function BlockIndex(X, Y, Z: Int16): Int64;

  type
    TSpawnPos = record
      X: Word;
      Y: Word;
      Z: Word;
    end;

  type
    TMapSize = record
      X: SmallInt;
      Y: SmallInt;
      Z: SmallInt;
    end;

  var
    MapSize: TMapSize;
    SpawnPos: TSpawnPos;
    BlockCount: Integer;
    BlockArray: array of Byte;

  private
    procedure LoadMap();
    procedure SaveMap();
    procedure GenerationMap();

  const
    GZipHeader: array [0 .. 7] of Byte = ($1F, $8B, $08, $0, $0, $0, $0, $0);
  end;

var
  MapCompress, MapDecompress: TMemoryStream;
  Compressor: TIdCompressorZLib;

implementation

uses
  Server;

constructor TWorldManager.Create;
begin
  MapCompress := TMemoryStream.Create;
  MapDecompress := TMemoryStream.Create;
  Self.LoadMap;
end;

destructor TWorldManager.Destroy;
begin
  SaveMap;
  MapCompress.Clear;
  MapDecompress.Clear;
  MapCompress.Free;
  MapDecompress.Free;
  Compressor.Free;
end;

procedure TWorldManager.LoadMap;
begin
  MapCompress.LoadFromFile('maps\world.btm');
  Compressor := TIdCompressorZLib.Create();
  Compressor.DecompressDeflateStream(MapCompress, MapDecompress);
  MapCompress.Clear;
  MapDecompress.Position := 0;
{$REGION 'ReadMapSize'}
  MapDecompress.Read(MapSize.X, 2);
  MapSize.X := Swap(MapSize.X);
  MapDecompress.Read(MapSize.Y, 2);
  MapSize.Y := Swap(MapSize.Y);
  MapDecompress.Read(MapSize.Z, 2);
  MapSize.Z := Swap(MapSize.Z);
{$ENDREGION}
{$REGION 'ReadSpawnPos'}
  MapDecompress.Read(SpawnPos.X, 2);
  SpawnPos.X := Swap(SpawnPos.X);
  MapDecompress.Read(SpawnPos.Y, 2);
  SpawnPos.Y := Swap(SpawnPos.Y);
  MapDecompress.Read(SpawnPos.Z, 2);
  SpawnPos.Z := Swap(SpawnPos.Z);
{$ENDREGION}
  MapDecompress.ReadData(BlockCount, 4);
  SetLength(BlockArray, BlockCount);
  MapDecompress.ReadData(BlockArray, BlockCount);
  MapDecompress.Clear;
end;

procedure TWorldManager.SaveMap;
begin
  Compressor.CompressHTTPDeflate(MapDecompress, MapCompress, 9);
  MapCompress.SaveToFile('maps\ww.gg');
end;

procedure TWorldManager.GenerationMap;
begin

end;

function TWorldManager.CompressChunk: TIdBytes;
var
  LvlCompress: TMemoryStream;
  LvlDecompress: TMemoryStream;
  Data: array [0 .. 3] of Byte;
  CompressData: TIdBytes;
begin
  LvlCompress := TMemoryStream.Create;
  LvlDecompress := TMemoryStream.Create;
  Data[0] := (((BlockCount) and (MapSize.X * MapSize.Y * MapSize.Z)) shr 24);
  Data[1] := (((BlockCount) and (MapSize.X * MapSize.Y * MapSize.Z)) shr 16);
  Data[2] := (((BlockCount) and (MapSize.X * MapSize.Y * MapSize.Z)) shr 8);
  Data[3] := (((BlockCount) and (MapSize.X * MapSize.Y * MapSize.Z)) shr 0);
  LvlDecompress.WriteData(Data);
  LvlDecompress.WriteData(BlockArray, BlockCount);
  LvlDecompress.Position := 0;
  LvlCompress.WriteData(GZipHeader, 8);
  Compressor.DeflateStream(LvlDecompress, LvlCompress, 1);
  LvlCompress.Position := 0;
  SetLength(CompressData, LvlCompress.Size);
  LvlCompress.ReadData(CompressData, LvlCompress.Size);
  Result := CompressData;
  SetLength(CompressData, 0);
  LvlCompress.Clear;
  LvlDecompress.Clear;
  LvlCompress.Free;
  LvlDecompress.Free;
end;

procedure TWorldManager.AddBlock(X, Y, Z: Int16; BlockID: Byte);
begin
  Self.BlockArray[WorldMgr.BlockIndex(X, Y, Z)] := BlockID;
end;

function TWorldManager.BlockIndex(X, Y, Z: Int16): Int64;
begin
  Result := X + Z * MapSize.Z + Y * MapSize.Z * MapSize.X;
end;

end.
