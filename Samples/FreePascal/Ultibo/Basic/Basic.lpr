program Basic;
{$mode delphi}{$H+}

uses
  Console,FATFS,FileSystem,GlobalConfig,GlobalConst,GlobalTypes,Logging,
  Platform,QEMUVersatilePB,Serial,SysUtils,Threads,VirtualDisk;

var
 ImageNo:Integer;
 MountImageBoolean:Boolean;

procedure Log(S:String);
begin
 ConsoleWriteLn(S);
 LoggingOutput(S);
end;

begin
 try
  try
   SERIAL_REGISTER_LOGGING:=True;
   SerialLoggingDeviceAdd(SerialDeviceGetDefault);
   SERIAL_REGISTER_LOGGING:=False;
   LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_SERIAL));
   ConsoleWindowCreate(ConsoleDeviceGetDefault, CONSOLE_POSITION_FULLSCREEN, True);
   Log('program start');
// Sleep(3 * 1000);
   Log('Starting create ram disk test');
   ImageNo:=FileSysDriver.CreateImage(0,'RAM Disk',itMEMORY,mtREMOVABLE,ftUNKNOWN,iaDisk or iaReadable or iaWriteable,512,20480,0,0,0,pidUnused);
   Log(Format('ImageNo %d',[ImageNo]));
   Log('Calling FileSysDriver.MountImage ...');
   MountImageBoolean:=FileSysDriver.MountImage(ImageNo);
   if not MountImageBoolean then
    Log('MountImage failed')
   else
    Log('MountImage succeeded');
   Log('Test completed');
   Log('program stop');
  except on E:Exception do
   begin
    Log(Format('Exception: %s',[E.Message]));
   end;
  end;
 finally
  ThreadHalt(0);
 end;
end.
