unit Packet_14; // Disconnect Client

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
  TPacket14 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket14.Read(Con: TIdContext);
begin

end;

procedure TPacket14.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  try
    Buffer.Write(Data);
    Buffer.ExtractToBytes(OutBuffer);
    TCliContext(Con).SendPacket(14, OutBuffer);
  finally
    Buffer.Free;
    SetLength(OutBuffer, 0);
  end;
end;

initialization

RegisterClass(TPacket14);

end.
