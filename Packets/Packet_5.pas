unit Packet_5; // Set Block

interface

Uses
  System.Classes,
  IdContext,
  IdBuffer,
  IdGlobal,
  Server,
  ClientManager,
  PacketManager;

type
  TPacket5 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket5.Read(Con: TIdContext);
var
  X, Y, Z: Int16;
  Mode: Byte;
  BlockType: Byte;
begin
  with Con.Connection.IOHandler do
  begin
    X := ReadInt16();
    Y := ReadInt16();
    Z := ReadInt16();
    Mode := ReadByte;
    BlockType := ReadByte;
  end;
  TCliContext(Con).OnChangeBlock(X, Y, Z, Mode, BlockType);
end;

procedure TPacket5.Write(Con: TIdContext; Data: TIdBytes);
begin

end;

initialization

RegisterClass(TPacket5);

end.
