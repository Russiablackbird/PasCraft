unit Packet_0; // Server Identification

interface

Uses SysUtils,
  System.Classes,
  IdContext,
  IdBuffer,
  IdGlobal,
  Server,
  ClientManager,
  PacketManager;

type
  TPacket0 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket0.Read(Con: TIdContext);
var
  Client: ^TClient;
begin
  Client := @TCliContext(Con).Client;
  with Con.Connection.IOHandler do
  begin
    Client.Vers := ReadByte;
    Client.UserName := ReadString(64);
    Client.Hash := ReadString(64);
    ReadByte;
  end;
  TCliContext(Con).OnJoin;
end;

procedure TPacket0.Write(Con: TIdContext; Data: TIdBytes);
var
  Client: ^TClient;
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Client := @TCliContext(Con).Client;
  Buffer := TIdBuffer.Create;
  Buffer.Write(UInt8(ServerVersion));
  Buffer.Write(ServerName.PadRight(64));
  Buffer.Write(MOTD.PadRight(64));
  Buffer.Write(UInt8(Client.Op));
  Buffer.ExtractToBytes(OutBuffer);

  TCliContext(Con).SendPacket(0, OutBuffer);

  Buffer.Free;
end;

initialization

RegisterClass(TPacket0);

finalization

UnRegisterClass(TPacket0);

end.
