unit ClientManager;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  IdTCPServer,
  IdCustomTCPServer,
  IdTCPConnection,
  IdYarn,
  IdContext,
  IdGlobal,
  IdThreadSafe,
  IdBuffer,

  PacketManager,
  WorldManager;

type
  TClient = record
    Con: TIdContext;
    UserName: String;
    Hash: string;
    Player_ID: Byte;
    Op: Byte;
    Vers: Byte;
    X: SmallInt;
    Y: SmallInt;
    Z: SmallInt;
    Yaw: Byte;
    Pitch: Byte;
    procedure ChangeBlock(X, Y, Z: Int16; BlockID: Byte);
  end;

type
  TCliContext = class(TIdServerContext)
  public
    procedure OnConnect;
    procedure OnDisconnect;
    procedure OnJoin;
    procedure OnLoadWorld;
    procedure OnSpawn;
    procedure OnDespawn;
    procedure OnChangeBlock(X, Y, Z: Int16; Mode, BlockType: Byte);
    procedure OnChangePos(X, Y, Z: Int16; Yaw, Pitch: Byte);
    procedure OnMessage(Msg: String);
    procedure OnCommand;
    procedure OnChangeOp(Op: Boolean);
    procedure OnKick(Reasons: String);

    procedure ReadPacket(Con: TIdContext; PacketID: Byte);
    procedure SendPacket(ID: Byte; Data: TIdBytes);
    function GetPacket(ID: Byte): TPacket;

    constructor Create(AConnection: TIdTCPConnection; AYarn: TIdYarn;
      AList: TIdContextThreadList = nil); override;
    destructor Destroy; override;

  var
    Client: TClient;
    PacketQueue: TThreadedQueue<TIdBytes>;
  end;

var
  PlayerList: TDictionary<string, TClient>;

implementation

Uses
  Server;

constructor TCliContext.Create(AConnection: TIdTCPConnection; AYarn: TIdYarn;
  AList: TIdContextThreadList);
begin
  inherited;
  PacketQueue := TThreadedQueue<TIdBytes>.Create(5000, 25000);
end;

destructor TCliContext.Destroy;
begin
  PacketQueue.Free;
  inherited;
end;

function TCliContext.GetPacket(ID: Byte): TPacket;
begin
  try
    Result := FindClass('TPacket' + ID.ToString).Create as TPacket;
  except
    begin
      Raise Exception.Create('Bad Packet ID');
    end;
  end;
end;

procedure TCliContext.OnConnect;
begin
  Client.Con := TIdContext(Self);
  Client.Op := $0;
  Client.X := 3000;
  Client.Y := 3000;
  Client.Z := 3000;
  Client.Yaw := 0;
  Client.Pitch := 0;
end;

procedure TCliContext.OnDisconnect;
begin

end;

procedure TCliContext.OnChangeBlock(X, Y, Z: Int16; Mode, BlockType: Byte);
var
  LocalClient: TClient;
  Data: TIdBytes;
  Packet: TPacket;
begin
  if Mode = 0 then
    BlockType := 0;

  Self.Client.ChangeBlock(X, Y, Z, BlockType);
  SetLength(Data, 7);

  for LocalClient in PlayerList.Values do
  begin
    CopyTIdInt16(Swap(X), Data, 0);
    CopyTIdInt16(Swap(Y), Data, 2);
    CopyTIdInt16(Swap(Z), Data, 4);
    Data[6] := BlockType;
    Packet := Self.GetPacket(6);
    Packet.Write(LocalClient.Con, Data);
    Packet.Free;
  end;
end;

procedure TCliContext.OnChangePos(X, Y, Z: Int16; Yaw, Pitch: Byte);
begin
  Client.X := X;
  Client.Y := Y;
  Client.Z := Z;
  Client.Yaw := Yaw;
  Client.Pitch := Pitch;
end;

procedure TCliContext.OnJoin;
var
  Packet: TPacket;
begin
  if Self.Client.Vers <> 7 then
  begin
    Raise Exception.Create('This version dont support');
  end;
  if PlayerList.ContainsKey(Client.UserName) then
  begin
    Raise Exception.Create('Such player is already connected');
  end;
  // Server Identification
  Packet := TCliContext(Client.Con).GetPacket(0);
  Packet.Write(Client.Con, nil);
  Packet.Destroy;
  // Send Map to client
  Self.OnLoadWorld;
  // Load local player from file
  // Self.LoadFClient(Pointer(Client));
  Self.OnSpawn;
end;

procedure TCliContext.OnSpawn;
var
  Packet: TPacket;
  LocalClient: TClient;
  Data: TIdBytes;
  Buffer: TIdBuffer;
begin
  Buffer := TIdBuffer.Create;

  // заспаунимся сами локально в клиенте
  begin
    Buffer.Write(Byte(255));
    Buffer.Write(Client.UserName);
    Buffer.Write(UInt16(Client.X));
    Buffer.Write(UInt16(Client.Y));
    Buffer.Write(UInt16(Client.Z));
    Buffer.Write(Client.Yaw);
    Buffer.Write(Client.Pitch);
    Buffer.ExtractToBytes(Data);

    Packet := Self.GetPacket(7);
    Packet.Write(Client.Con, Data);
    Packet.Free;
    SetLength(Data, 0);
  end;

  // спаунимся у остальных пидоров
  for LocalClient in PlayerList.Values do
  begin
    Buffer.Write(Client.Player_ID);
    Buffer.Write(Client.UserName);
    Buffer.Write(UInt16(Client.X));
    Buffer.Write(UInt16(Client.Y));
    Buffer.Write(UInt16(Client.Z));
    Buffer.Write(Client.Yaw);
    Buffer.Write(Client.Pitch);
    Buffer.ExtractToBytes(Data);

    Packet := Self.GetPacket(7);
    Packet.Write(LocalClient.Con, Data);
    Packet.Free;
    SetLength(Data, 0);

  end;

  // заспауним пидоров у себя в клиенте
  for LocalClient in PlayerList.Values do
  begin
    Buffer.Write(LocalClient.Player_ID);
    Buffer.Write(LocalClient.UserName);
    Buffer.Write(UInt16(LocalClient.X));
    Buffer.Write(UInt16(LocalClient.Y));
    Buffer.Write(UInt16(LocalClient.Z));
    Buffer.Write(LocalClient.Yaw);
    Buffer.Write(LocalClient.Pitch);
    Buffer.ExtractToBytes(Data);

    Packet := Self.GetPacket(7);
    Packet.Write(Client.Con, Data);
    Packet.Free;
    SetLength(Data, 0);
  end;

  PlayerList.Add(Client.UserName, Self.Client);

end;

procedure TCliContext.ReadPacket(Con: TIdContext; PacketID: Byte);
var
  Packet: TPacket;
begin
  Packet := GetPacket(PacketID);
  Packet.Read(Con);
  Packet.Free;
end;

procedure TCliContext.SendPacket(ID: Byte; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  DataBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  try
    Buffer.Write(UInt8(ID));
    Buffer.Write(Data);
    Buffer.ExtractToBytes(DataBuffer);
    Self.PacketQueue.PushItem(DataBuffer);
    SetLength(DataBuffer, 0);
  finally
    Buffer.Free;
  end;
end;

procedure TCliContext.OnDespawn;
begin

end;

procedure TCliContext.OnKick(Reasons: String);
begin

end;

procedure TCliContext.OnLoadWorld;
var
  GZipData: TIdBytes;
  ChunkData: TIdBytes;
  Buffer: TIdBytes;
  Point: Int64;
  Percent: Byte;
  Data: TIdBuffer;
  Packet: TPacket;
begin
  // Level Initialize
  Packet := TCliContext(Client.Con).GetPacket(2);
  Packet.Write(Client.Con, nil);
  Packet.Destroy;

  Point := 0;
  Data := TIdBuffer.Create;
  Packet := TCliContext(Client.Con).GetPacket(3);

  GZipData := WorldMgr.CompressChunk;
  while (length(GZipData) > Point) do
  begin
    Percent := round(Point / length(GZipData) * 100);
    if (Point + 1024 < length(GZipData)) then
    begin
      SetLength(ChunkData, 1024); // +1  percent
      CopyTIdBytes(GZipData, Point, ChunkData, 0, 1024);
      Data.Write(UInt16(1024));
      Data.Write(ChunkData);
      Data.Write(UInt8(Percent));
      Data.ExtractToBytes(Buffer);
      Packet.Write(Client.Con, Buffer);
      SetLength(Buffer, 0);
      SetLength(ChunkData, 0);
    end
    else
    begin
      SetLength(ChunkData, 1024);
      CopyTIdBytes(GZipData, Point, ChunkData, 0, length(GZipData) - Point);
      Data.Write(UInt16(1024));
      Data.Write(ChunkData);
      Data.Write(UInt8(100));
      Data.ExtractToBytes(Buffer);
      Packet.Write(Client.Con, Buffer);
      SetLength(Buffer, 0);
      SetLength(ChunkData, 0);
    end;
    Point := Point + 1024;
  end;
  Packet.Destroy;
  SetLength(GZipData, 0);

  Packet := TCliContext(Client.Con).GetPacket(4);
  Packet.Write(Client.Con, nil);
  Packet.Destroy;

end;

procedure TCliContext.OnMessage(Msg: String);
begin

end;

procedure TCliContext.OnCommand;
begin

end;

procedure TCliContext.OnChangeOp(Op: Boolean);
begin

end;
{ TClient }

procedure TClient.ChangeBlock(X, Y, Z: Int16; BlockID: Byte);
begin
  WorldMgr.AddBlock(X, Y, Z, BlockID);
end;

end.
