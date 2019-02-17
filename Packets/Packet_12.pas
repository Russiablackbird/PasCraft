unit Packet_12; // Despawn Client

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
  TPacket12 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket12.Read(Con: TIdContext);
begin

end;

procedure TPacket12.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  try
    Buffer.Write(Data);
    Buffer.ExtractToBytes(OutBuffer);
    TCliContext(Con).SendPacket(12, OutBuffer);
  finally
    Buffer.Free;
    SetLength(OutBuffer, 0);
  end;
end;

initialization

RegisterClass(TPacket12);

end.
