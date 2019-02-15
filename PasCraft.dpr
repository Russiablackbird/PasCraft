program PasCraft;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Server in 'Server.pas',
  PlayerManager in 'PlayerManager.pas',
  PacketManager in 'PacketManager.pas',
  Packet_0 in 'Packets\Packet_0.pas',
  Packet_1 in 'Packets\Packet_1.pas',
  Packet_2 in 'Packets\Packet_2.pas',
  Packet_3 in 'Packets\Packet_3.pas',
  Packet_4 in 'Packets\Packet_4.pas',
  WorldManager in 'WorldManager.pas',
  Packet_7 in 'Packets\Packet_7.pas',
  Packet_5 in 'Packets\Packet_5.pas',
  Packet_6 in 'Packets\Packet_6.pas',
  Packet_8 in 'Packets\Packet_8.pas',
  Log in 'Log.pas',
  Packet_14 in 'Packets\Packet_14.pas',
  ClientManager in 'ClientManager.pas';

var
  PasServer: TGameServer;

begin
  try
    PasServer := TGameServer.Create;
    PasServer.Start;
    while True do
    begin
      sleep(1);
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
