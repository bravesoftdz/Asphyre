program Basic;
{$mode delphi}{$H+}

uses
 GlobalConfig,GlobalConst,GlobalTypes,Logging,
 Platform,QEMUVersatilePB,Serial,SysUtils,Threads;

procedure Delay(Milliseconds:Integer);
begin
 LoggingOutput(Format('program delay %3.1f seconds started',[Milliseconds / 1000.0]));
 Sleep(Milliseconds);
 LoggingOutput(Format('program delay %3.1f seconds finished',[Milliseconds / 1000.0]));
end;

begin
 try
  try
   LOGGING_INCLUDE_COUNTER:=False;
   LOGGING_INCLUDE_TICKCOUNT:=True;
   SERIAL_REGISTER_LOGGING:=True;
   SerialLoggingDeviceAdd(SerialDeviceGetDefault);
   LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_SERIAL));
   LoggingOutput('program start');
   LoggingOutput('test succeeded');
  except on E:Exception do
   begin
    LoggingOutput(Format('Exception: %s',[E.Message]));
   end;
  end;
 finally
  LoggingOutput('program stop');
  ThreadHalt(1 * 1000);
 end;
end.
