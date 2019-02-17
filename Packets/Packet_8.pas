unit Packet_8; // Position and Orientation

interface

Uses
  System.Classes,
  System.SysUtils,
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
  Position: Vector3D;
begin
  with Con.Connection.IOHandler do
  begin
    ReadByte; // похуй на этот ID т.к это двигается локальный игрок 255
    Position.X := ReadInt16();
    Position.Y := ReadInt16();
    Position.Z := ReadInt16();
    Position.Yaw := ReadByte;
    Position.Pitch := ReadByte;
  end;

  if not CompareMem(@Position, @TCliContext(Con).Client.Pos, SizeOf(Position))
  then
    TCliContext(Con).OnChangePos(Position);

end;

procedure TPacket8.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  try
    Buffer.Write(Data);
    Buffer.ExtractToBytes(OutBuffer);
    TCliContext(Con).SendPacket(8, OutBuffer);
  finally
    Buffer.Free;
    SetLength(OutBuffer, 0);
  end;
end;

initialization

RegisterClass(TPacket8);

end.
