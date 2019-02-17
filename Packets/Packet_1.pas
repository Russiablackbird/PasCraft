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
  try
    Buffer.Write(Data);
    Buffer.ExtractToBytes(OutBuffer);
    TCliContext(Con).SendPacket(1, OutBuffer);
  finally
    Buffer.Free;
    SetLength(OutBuffer, 0);
  end;
end;

initialization

RegisterClass(TPacket1);

end.
