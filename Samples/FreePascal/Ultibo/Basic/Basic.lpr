program Basic;
{$mode delphi}{$H+}

uses
 Console,GlobalConfig,GlobalConst,GlobalTypes,Logging,
 Platform,QEMUVersatilePB,Serial,SysUtils,Threads;

procedure Log(S:String);
begin
 ConsoleWriteLn(S);
 LoggingOutput(S);
end;

procedure Delay(Milliseconds:Integer);
begin
 Log(Format('program delay %3.1f seconds started',[Milliseconds / 1000.0]));
 Sleep(Milliseconds);
 Log(Format('program delay %3.1f seconds finished',[Milliseconds / 1000.0]));
end;

begin
 try
  try
   LOGGING_INCLUDE_COUNTER:=False;
   LOGGING_INCLUDE_TICKCOUNT:=True;
   SERIAL_REGISTER_LOGGING:=True;
   SerialLoggingDeviceAdd(SerialDeviceGetDefault);
   SERIAL_REGISTER_LOGGING:=False;
   LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_SERIAL));
   ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_FULLSCREEN,True);
   Log('program start');
   Delay(0 * 1000);
   Log('Starting create ram disk test');
   Log('test succeeded');
  except on E:Exception do
   begin
    Log(Format('Exception: %s',[E.Message]));
   end;
  end;
 finally
  Log('program stop');
  ThreadHalt(1 * 1000);
 end;
end.
