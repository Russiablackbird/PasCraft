unit Packet_8; // Position and Orientation

interface

Uses
  System.Classes,
  IdContext,
  IdBuffer,
  IdGlobal,
  Server,
  PacketManager,
  ClientManager;

type
  TPacket8 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket8.Read(Con: TIdContext);
var
  Client: ^TClient;
begin
  Client := @TCliContext(Con).Client;

  with Con.Connection.IOHandler do
  begin
    ReadByte;
    Client.X := ReadInt16();
    Client.Y := ReadInt16();
    Client.Z := ReadInt16();
    Client.Yaw := ReadByte;
    Client.Pitch := ReadByte;
  end;

end;

procedure TPacket8.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  Buffer.ExtractToBytes(OutBuffer);
  TCliContext(Con).SendPacket(8, OutBuffer);
  Buffer.Free;
end;

initialization

RegisterClass(TPacket8);

end.
