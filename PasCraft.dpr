program PasCraft;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Packet_0 in 'Packets\Packet_0.pas',
  Packet_1 in 'Packets\Packet_1.pas',
  Packet_2 in 'Packets\Packet_2.pas',
  Packet_3 in 'Packets\Packet_3.pas',
  Packet_4 in 'Packets\Packet_4.pas',
  Packet_7 in 'Packets\Packet_7.pas',
  Packet_5 in 'Packets\Packet_5.pas',
  Packet_6 in 'Packets\Packet_6.pas',
  Packet_8 in 'Packets\Packet_8.pas',
  Packet_14 in 'Packets\Packet_14.pas',
  Server in 'Server.pas',
  WorldManager in 'WorldManager.pas',
  PlayerManager in 'PlayerManager.pas',
  PacketManager in 'PacketManager.pas',
  ClientManager in 'ClientManager.pas',
  Log in 'Log.pas',
  Packet_12 in 'Packets\Packet_12.pas',
  Packet_13 in 'Packets\Packet_13.pas';

var
  PasServer: TGameServer;
  cmd: string;

begin

  ReportMemoryLeaksOnShutdown := true;

  try
    PasServer := TGameServer.Create;
    PasServer.Start;
    PasServer.Status := true;
    while PasServer.Status = true do
    begin
      // sleep(1);

      Readln(cmd);

      if cmd = 'exit' then
      begin
        PasServer.Status := False;
        PasServer.Stop;
        PasServer.Free;
      end;

    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);

  end;

end.
