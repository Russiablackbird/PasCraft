unit PlayerManager;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  IdTCPServer,
  IdContext,
  IdGlobal,
  IdBuffer,
  Log;

type
  PClient = ^TPlayer;

  TPlayer = record
    Con: TIdContext;
    Spawned: Boolean;
    UserName: String;
    Hash: string;
    Op: Byte;
    Vers: Byte;
    Player_ID: Byte;
    X: SmallInt;
    Y: SmallInt;
    Z: SmallInt;
    Yaw: Byte;
    Pitch: Byte;
  end;

type
  TPlayerManager = class
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Connect(Con: TIdContext);
    procedure Disconnect(Con: TIdContext);
    procedure Kick(Con: TIdContext; Reasons: String);
  private
    procedure LoadFClient(Player: PClient);
    procedure SaveFClient(Player: PClient);
  end;

implementation

Uses
  Server,
  PacketManager;

constructor TPlayerManager.Create;

begin

end;

destructor TPlayerManager.Destroy;
begin
  // PlayerList.Clear;
  // PlayerList.Free;
end;

procedure TPlayerManager.Connect(Con: TIdContext);
// var
// Client: ^TPlayer;
// Packet: TPacket;
begin
  // Client := Pointer(TCliContext(Con).Client);

  // if Client.Vers <> ServerVersion then
  // begin
  // Raise Exception.Create('This version dont support');
  // end;

  // Client.Player_ID := ClientID.PopItem;

  // PlayerList.Add(Client.UserName, PClient(Client));
  // Server Identification
  // Packet := TCliContext(Con).PacketMgr.GetPacket(0);
  // Packet.Write(Con, nil);
  // Packet.Destroy;
  //
  // Level Initialize
  // Packet := TCliContext(Con).PacketMgr.GetPacket(2);
  // Packet.Write(Con, nil);
  // Packet.Destroy;
  //
  // Send Map to client
  // WorldMgr.SendMap(Con);
  //
  // Load local player from file
  // Self.LoadFClient(Pointer(Client));
  //
  // Spawn Player
  // Packet := TCliContext(Con).PacketMgr.GetPacket(7);
  // Packet.Write(Con, nil);
  // Packet.Destroy;
  //
  // Client.Spawned := True;
  // Logger.Show('Joined: ' + Client.UserName.TrimRight, 0);

end;

procedure TPlayerManager.Disconnect(Con: TIdContext);
// var
// Client: ^TPlayer;
begin
  // Client := Pointer(TCliContext(Con).Client);
  // ClientID.PushItem(Client.Player_ID);
  // Self.SaveFClient(Pointer(Client));
  // PlayerList.Remove(Client.UserName);
  // Logger.Show('Disconnect: ' + Client.UserName.TrimRight, 0);
end;

procedure TPlayerManager.Kick(Con: TIdContext; Reasons: string);
// var
// Packet: TPacket;
// Buffer: TIdBytes;
begin
  // SetLength(Buffer, 64);
  // CopyTIdString(Reasons, Buffer, 0, 64);
  // Packet := TCliContext(Con).PacketMgr.GetPacket(14);
  // Packet.Write(Con, Buffer);
  // SetLength(Buffer, 0);
  // Packet.Destroy;
end;

procedure TPlayerManager.LoadFClient(Player: PClient);
var
  FPlayer: TMemoryStream;
begin
  FPlayer := TMemoryStream.Create;
  try
    FPlayer.LoadFromFile('Players/' + Player.UserName.Trim + '.DAT');
    FPlayer.Position := 0;
    FPlayer.Read(Player.Op, 1);
    FPlayer.Read(Player.X, 2);
    FPlayer.Read(Player.Y, 2);
    FPlayer.Read(Player.Z, 2);
    FPlayer.Read(Player.Yaw, 1);
    FPlayer.Read(Player.Pitch, 1);
  except

  end;
  FPlayer.Free;
end;

procedure TPlayerManager.SaveFClient(Player: PClient);
var
  FPlayer: TMemoryStream;
begin
  FPlayer := TMemoryStream.Create;
  try
    FPlayer.Write(Player.Op, 1);
    FPlayer.Write(Player.X, 2);
    FPlayer.Write(Player.Y, 2);
    FPlayer.Write(Player.Z, 2);
    FPlayer.Write(Player.Yaw, 1);
    FPlayer.Write(Player.Pitch, 1);
    FPlayer.SaveToFile('Players/' + Player.UserName.Trim + '.DAT');
  except

  end;
  FPlayer.Free;
end;

end.
