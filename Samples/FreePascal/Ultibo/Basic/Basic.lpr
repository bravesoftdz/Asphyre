program Basic;
{$mode delphi}{$H+}

uses
 Console,FATFS,FileSystem,GlobalConfig,GlobalConst,GlobalTypes,Logging,
 Platform,QEMUVersatilePB,Serial,SysUtils,Threads,VirtualDisk;

var
 ImageNo:Integer;
 MountImageBoolean:Boolean;
 MonitorThread:TThreadHandle;
 MainThread:TThreadHandle;

procedure Log(S:String);
begin
 ConsoleWriteLn(S);
 LoggingOutput(S);
end;

function Monitor(Parameter:Pointer):PtrInt;
var
 SnapShot,Current:PThreadSnapShot;
begin
   Sleep(1 * 1000);
   SnapShot:=ThreadSnapShotCreate;
   Current:=SnapShot;
   while Assigned(Current) do
    if Current.Handle = MainThread then
     begin
      Log(Format('program %s',[ThreadStateToString(Current.State)]));
      Current:=nil;
     end
    else
     begin
      Current:=Current.Next;
     end;
   ThreadSnapShotDestroy(SnapShot);
   Log(Format('test failed - did not return',[]));
   Log('program stop');
 Monitor:=0;
end;

procedure Delay(Milliseconds:Integer);
begin
 Log(Format('program delay %3.1f seconds started',[Milliseconds / 1000.0]));
 Sleep(Milliseconds);
 Log(Format('program delay %3.1f seconds finished',[Milliseconds / 1000.0]));
end;

var
 I:Integer;
 Succeeded:Boolean;

begin
 Succeeded:=True;
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
   MainThread:=ThreadGetCurrent;
   Log('Starting create ram disk test');
   for I:=1 to 1 do
    begin
     Log('Calling FileSysDriver.CreateImage ...');
     MonitorThread:=BeginThread(@Monitor,nil,MonitorThread,THREAD_STACK_DEFAULT_SIZE);
     ImageNo:=FileSysDriver.CreateImage(0,'RAM Disk',itMEMORY,mtREMOVABLE,ftUNKNOWN,iaDisk or iaReadable or iaWriteable,512,10240,0,0,0,pidUnused);
//   ImageNo:=-1000;
     Log(Format('ImageNo %d',[ImageNo]));
     Log('Calling FileSysDriver.MountImage ...');
     MountImageBoolean:=FileSysDriver.MountImage(ImageNo);
//   MountImageBoolean:=True;
     if not MountImageBoolean then
      begin
       Succeeded:=False;
       Log(Format('test failed - MountImage %d failed',[I]));
       break;
      end;
    end;
  except on E:Exception do
   begin
    Log(Format('Exception: %s',[E.Message]));
   end;
  end;
 finally
  if Succeeded then
   Log('test succeeded');
  Log('program stop');
  ThreadHalt(1 * 1000);
 end;
end.
