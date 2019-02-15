unit Packet_1; // Ping

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
  TPacket1 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket1.Read(Con: TIdContext);
begin

end;

procedure TPacket1.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  Buffer.ExtractToBytes(OutBuffer);
  TCliContext(Con).SendPacket(1, OutBuffer);
  Buffer.Free;
end;

initialization

RegisterClass(TPacket1);

end.
