unit PacketManager;

interface

uses

  System.Classes, IdContext, IdGlobal;

type
  TPacket = class(TPersistent)
  public
    procedure Read(ACon: TIdContext); virtual; abstract;
    procedure Write(ACon: TIdContext; Data: TIdBytes); virtual; abstract;
  end;

implementation

end.
