unit Packet_6; // Set Block

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
  TPacket6 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket6.Read(Con: TIdContext);
begin

end;

procedure TPacket6.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  Buffer.Write(Data);
  Buffer.ExtractToBytes(OutBuffer);
  TCliContext(Con).SendPacket(6, OutBuffer);
  SetLength(OutBuffer, 0);
  Buffer.Free;
end;

initialization

RegisterClass(TPacket6);

end.
