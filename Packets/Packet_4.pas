unit Packet_4; // Level Finalize

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
  TPacket4 = class(TPacket)
    procedure Read(Con: TIdContext); override;
    procedure Write(Con: TIdContext; Data: TIdBytes); override;
  end;

implementation

procedure TPacket4.Read(Con: TIdContext);
begin

end;

procedure TPacket4.Write(Con: TIdContext; Data: TIdBytes);
var
  Buffer: TIdBuffer;
  OutBuffer: TIdBytes;
begin
  Buffer := TIdBuffer.Create;
  Buffer.Write(UInt16(WorldMgr.MapSize.X));
  Buffer.Write(UInt16(WorldMgr.MapSize.Y));
  Buffer.Write(UInt16(WorldMgr.MapSize.Z));
  Buffer.ExtractToBytes(OutBuffer);
  TCliContext(Con).SendPacket(4, OutBuffer);
  Buffer.Free;

  /// надо переделать этот участок

end;

initialization

RegisterClass(TPacket4);

end.
