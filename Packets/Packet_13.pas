unit Packet_13; // Message

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
  TPacket13 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket13.Read(Con: TIdContext);
var
  Msg: string;
begin
  with Con.Connection.IOHandler do
  begin
    ReadByte;
    Msg := ReadString(64);
  end;
  TCliContext(Con).OnMessage(Msg);
end;

procedure TPacket13.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  try
    Buffer.Write(Data);
    Buffer.ExtractToBytes(OutBuffer);
    TCliContext(Con).SendPacket(13, OutBuffer);
  finally
    Buffer.Free;
    SetLength(OutBuffer, 0);
  end;
end;

initialization

RegisterClass(TPacket13);

end.
