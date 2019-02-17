unit Server;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  IdTCPServer,
  IdCustomTCPServer,
  IdTCPConnection,
  IdYarn,
  IdContext,
  IdGlobal,
  IdThreadSafe,
  IdBuffer,

  ClientManager,
  PacketManager,
  WorldManager,
  Log;

const
  Port = 8888;
  MaxClient = 100;
  Timeout = 1000;
  ServerName = 'PasCraft';
  ServerVersion: Byte = 7;
  MOTD = 'Welcome to the Delphi Server';

type
  TGameServer = class(TObject)
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Start();
    procedure Stop();
  private
    procedure OnClientCycle(Con: TIdContext);
    procedure OnConnect(Con: TIdContext);
    procedure OnDisconnect(Con: TIdContext);
    procedure OnException(Con: TIdContext; AException: Exception);
  end;

var
  ClientID: TThreadedQueue<Byte>;
  TCPServer: TIdTCPServer;
  WorldMgr: TWorldManager;

implementation

constructor TGameServer.Create();
var
  I: Byte;
begin

  PlayerList := TDictionary<string, TClient>.Create;

  ClientID := TThreadedQueue<Byte>.Create(256, 2500);

  WorldMgr := TWorldManager.Create;

  for I := 0 to 254 do
  begin
    ClientID.PushItem(I);
  end;

  TCPServer := TIdTCPServer.Create(nil);
  TCPServer.Bindings.Clear;
  TCPServer.DefaultPort := Port;
  TCPServer.Bindings.Add.Port := Port;
  TCPServer.Bindings.Add.IP := '127.0.0.1';
  TCPServer.ListenQueue := 1;
  TCPServer.MaxConnections := MaxClient - 1;
  TCPServer.TerminateWaitTime := Timeout;
  TCPServer.OnConnect := OnConnect;
  TCPServer.OnExecute := OnClientCycle;
  TCPServer.OnDisconnect := OnDisconnect;
  TCPServer.OnException := OnException;
  TCPServer.ContextClass := TCliContext;
end;

destructor TGameServer.Destroy;
begin
  TCPServer.StopListening;
  TCPServer.Active := False;
  TCPServer.Free;
end;

procedure TGameServer.Start;
begin
  TCPServer.Active := True;
end;

procedure TGameServer.Stop;
begin
  Self.Free;
end;

procedure TGameServer.OnClientCycle(Con: TIdContext);
var
  PacketID: Byte;
  Buffer: TIdBytes;
begin

  Sleep(10);

  if not Con.Connection.IOHandler.InputBufferIsEmpty then
  begin
    with Con.Connection.IOHandler do
    begin
      PacketID := ReadByte;
      TCliContext(Con).ReadPacket(Con, PacketID);
    end;
  end;

  while TCliContext(Con).PacketQueue.QueueSize > 0 do
  begin
    with TCliContext(Con).Connection.IOHandler do
    begin
      Buffer := TCliContext(Con).PacketQueue.PopItem;
      Write(Buffer);
      SetLength(Buffer, 0);
    end;
  end;

end;

procedure TGameServer.OnConnect(Con: TIdContext);
begin
  TCliContext(Con).OnConnect;
end;

procedure TGameServer.OnDisconnect(Con: TIdContext);
begin
  TCliContext(Con).OnDisconnect;
end;

procedure TGameServer.OnException(Con: TIdContext; AException: Exception);
begin
  // Logger.Show(AException.Message, 2);
  // PlayerMgr.Kick(Con, AException.Message);
end;

end.
