unit Packet_3; // Level Data Chunk

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
  TPacket3 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket3.Read(Con: TIdContext);
begin

end;

procedure TPacket3.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  Buffer.Write(Data);
  Buffer.ExtractToBytes(OutBuffer);
  TCliContext(Con).SendPacket(3, OutBuffer);
  Buffer.Free;
end;

initialization

RegisterClass(TPacket3);

end.
