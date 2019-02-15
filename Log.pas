unit Log;

interface

uses
  System.SysUtils, Winapi.Windows;

type
  TLogger = class(TObject)
    procedure Show(Msg: string; MsgType: Byte);
  end;

var
  Logger: TLogger;

implementation

procedure TLogger.Show(Msg: string; MsgType: Byte);
var
  hCon: Cardinal;
begin
  hCon := GetStdHandle(STD_OUTPUT_HANDLE);
  SetConsoleTextAttribute(hCon, $7F);
  Write(FormatDateTime('c', Now));

  case MsgType of
    0:
      begin
        SetConsoleTextAttribute(hCon, $7A);
        Write(' [Info] ');
        SetConsoleTextAttribute(hCon, $7F);
        WriteLn(Msg);
      end;
    1:
      begin
        SetConsoleTextAttribute(hCon, $7E);
        Write(' [Warning] ');
        SetConsoleTextAttribute(hCon, $7F);
        WriteLn(Msg);
      end;
    2:
      begin
        SetConsoleTextAttribute(hCon, $7C);
        Write(' [Error] ');
        SetConsoleTextAttribute(hCon, $7F);
        WriteLn(Msg);
      end;
  end;

end;

end.
