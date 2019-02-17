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
  WorldManager,
  Log;

type
  Vector3D = record
    X: Int16;
    Y: Int16;
    Z: Int16;
    Yaw: Byte;
    Pitch: Byte;
  end;

type
  TClient = record
    Con: TIdContext;
    UserName: String;
    Hash: string;
    Player_ID: Byte;
    Op: Byte;
    Vers: Byte;
    Spawned: Boolean;
    Pos: Vector3D;
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
    procedure OnChangePos(Pos: Vector3D);
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
  Client.Op := $64;
  Client.Pos.X := 3000;
  Client.Pos.Y := 3000;
  Client.Pos.Z := 3000;
  Client.Pos.Yaw := 0;
  Client.Pos.Pitch := 0;
  Client.Spawned := False;
end;

procedure TCliContext.OnDisconnect;
begin
  if Client.Spawned = True then
    Self.OnDespawn;
end;

procedure TCliContext.OnChangeBlock(X, Y, Z: Int16; Mode, BlockType: Byte);
var
  LocalClient: TClient;
  Data: TIdBytes;
  Packet: TPacket;
  Buffer: TIdBuffer;
begin

  if Mode = 0 then
    BlockType := 0;

  Self.Client.ChangeBlock(X, Y, Z, BlockType);

  Buffer := TIdBuffer.Create;
  try
    for LocalClient in PlayerList.Values do
    begin
      Buffer.Write(UInt16(X));
      Buffer.Write(UInt16(Y));
      Buffer.Write(UInt16(Z));
      Buffer.Write(BlockType);
      Buffer.ExtractToBytes(Data);
      Packet := Self.GetPacket(6);
      Packet.Write(LocalClient.Con, Data);
      Packet.Free;
      SetLength(Data, 0);
    end;
  finally
    Buffer.Free;
  end;

end;

procedure TCliContext.OnChangePos(Pos: Vector3D);
var
  Packet: TPacket;
  LocalClient: TClient;
  Buffer: TIdBuffer;
  Data: TIdBytes;
begin
  Client.Pos.X := Pos.X;
  Client.Pos.Y := Pos.Y;
  Client.Pos.Z := Pos.Z;
  Client.Pos.Yaw := Pos.Yaw;
  Client.Pos.Pitch := Pos.Pitch;

  Buffer := TIdBuffer.Create;
  Packet := Self.GetPacket(8);
  try
    for LocalClient in PlayerList.Values do
    begin
      if LocalClient.Con = Client.Con then
        Continue;
      Buffer.Write(Client.Player_ID);
      Buffer.Write(UInt16(Client.Pos.X));
      Buffer.Write(UInt16(Client.Pos.Y));
      Buffer.Write(UInt16(Client.Pos.Z));
      Buffer.Write(Client.Pos.Yaw);
      Buffer.Write(Client.Pos.Pitch);
      Buffer.ExtractToBytes(Data);
      Packet.Write(LocalClient.Con, Data);
      SetLength(Data, 0);
    end;
  finally
    Packet.Free;
    Buffer.Free;
  end;

end;

procedure TCliContext.OnJoin;
var
  Packet: TPacket;
begin
  if ServerVersion <> 7 then
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
  Packet.Free;
  // Send Map to client
  Self.OnLoadWorld;
  // Load local player from file
  // Self.LoadFClient(Pointer(Client));
  Client.Player_ID := ClientID.PopItem;
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
  Packet := Self.GetPacket(7);
  try
    // Self spawn
    begin
      Buffer.Write(Byte(255));
      Buffer.Write(Client.UserName);
      Buffer.Write(UInt16(Client.Pos.X));
      Buffer.Write(UInt16(Client.Pos.Y));
      Buffer.Write(UInt16(Client.Pos.Z));
      Buffer.Write(Client.Pos.Yaw);
      Buffer.Write(Client.Pos.Pitch);
      Buffer.ExtractToBytes(Data);
      Packet.Write(Client.Con, Data);
      SetLength(Data, 0);
    end;

    // заспауним остальных пидоров у себя в клиенте
    for LocalClient in PlayerList.Values do
    begin
      Buffer.Write(LocalClient.Player_ID);
      Buffer.Write(LocalClient.UserName);
      Buffer.Write(UInt16(LocalClient.Pos.X));
      Buffer.Write(UInt16(LocalClient.Pos.Y));
      Buffer.Write(UInt16(LocalClient.Pos.X));
      Buffer.Write(LocalClient.Pos.Yaw);
      Buffer.Write(LocalClient.Pos.Pitch);
      Buffer.ExtractToBytes(Data);
      Packet.Write(Client.Con, Data);
      SetLength(Data, 0);
    end;

    // спаунимся у остальных пидоров
    for LocalClient in PlayerList.Values do
    begin
      Buffer.Write(Client.Player_ID);
      Buffer.Write(Client.UserName);
      Buffer.Write(UInt16(Client.Pos.X));
      Buffer.Write(UInt16(Client.Pos.Y));
      Buffer.Write(UInt16(Client.Pos.Z));
      Buffer.Write(Client.Pos.Yaw);
      Buffer.Write(Client.Pos.Pitch);
      Buffer.ExtractToBytes(Data);
      Packet.Write(LocalClient.Con, Data);
      SetLength(Data, 0);
    end;
    PlayerList.Add(Client.UserName, Self.Client);
    Client.Spawned := True;

  finally
    Buffer.Free;
    Packet.Free;
  end;

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
  finally
    SetLength(DataBuffer, 0);
    Buffer.Free;
  end;
end;

procedure TCliContext.OnDespawn;
var
  LocalClient: TClient;
  Data: TIdBytes;
  Packet: TPacket;
  Buffer: TIdBuffer;
begin

  Buffer := TIdBuffer.Create;
  try
    PlayerList.Remove(Client.UserName);
    for LocalClient in PlayerList.Values do
    begin
      Buffer.Write(Client.Player_ID);
      Buffer.ExtractToBytes(Data);
      Packet := Self.GetPacket(12);
      Packet.Write(LocalClient.Con, Data);
      Packet.Free;
      SetLength(Data, 0);
    end;
    Logger.Show('Disconnect: ' + Client.UserName.Trim, 0);
  finally
    Buffer.Free;
  end;

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

  Data := TIdBuffer.Create;
  Packet := TCliContext(Client.Con).GetPacket(3);

  GZipData := WorldMgr.CompressChunk;
  Point := 0;
  while (length(GZipData) > Point) do
  begin
    SetLength(ChunkData, 1024);
    Percent := round(Point / length(GZipData) * 100);
    if (Point + 1024 < length(GZipData)) then
    begin
      CopyTIdBytes(GZipData, Point, ChunkData, 0, 1024);
      Data.Write(UInt16(1024));
      Data.Write(ChunkData);
      Data.Write(UInt8(Percent));
    end
    else
    begin
      CopyTIdBytes(GZipData, Point, ChunkData, 0, length(GZipData) - Point);
      Data.Write(UInt16(1024));
      Data.Write(ChunkData);
      Data.Write(UInt8(100));
    end;

    Data.ExtractToBytes(Buffer);
    Packet.Write(Client.Con, Buffer);
    Point := Point + 1024;
    SetLength(Buffer, 0);
    SetLength(ChunkData, 0);
  end;

  Data.Free;
  Packet.Free;
  SetLength(GZipData, 0);

  Packet := TCliContext(Client.Con).GetPacket(4);
  Packet.Write(Client.Con, nil);
  Packet.Free;

end;

procedure TCliContext.OnMessage(Msg: String);
var
  Packet: TPacket;
  LocalClient: TClient;
  Data: TIdBytes;
  Buffer: TIdBuffer;
begin

  Buffer := TIdBuffer.Create;
  try
    for LocalClient in PlayerList.Values do
    begin
      Buffer.Write(Client.Player_ID);
      Buffer.Write(Msg);
      Buffer.ExtractToBytes(Data);
      Packet := Self.GetPacket(13);
      Packet.Write(LocalClient.Con, Data);
      Packet.Free;
      SetLength(Data, 0);
    end;
  finally
    Buffer.Free;
  end;

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
