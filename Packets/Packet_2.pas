unit Packet_2; // Level Initialize

interface

Uses System.Classes,
  IdContext,
  IdBuffer,
  IdGlobal,
  Server,
  PacketManager,
  ClientManager;

type
  TPacket2 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket2.Read(Con: TIdContext);
begin

end;

procedure TPacket2.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  Buffer.ExtractToBytes(OutBuffer);
  TCliContext(Con).SendPacket(2, OutBuffer);
  Buffer.Free;
end;

initialization

RegisterClass(TPacket2);

end.
