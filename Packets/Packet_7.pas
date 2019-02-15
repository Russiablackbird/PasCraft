unit Packet_7; // Spawn player

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
  TPacket7 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket7.Read(Con: TIdContext);
begin

end;

procedure TPacket7.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
  // Client: ^TClient;
begin
  Buffer := TIdBuffer.Create;
  // Client := @TCliContext(Con).Client;

  Buffer.Write(Data);
  Buffer.ExtractToBytes(OutBuffer);
  TCliContext(Con).SendPacket(7, OutBuffer);
  Buffer.Free;
end;

initialization

RegisterClass(TPacket7);

end.
