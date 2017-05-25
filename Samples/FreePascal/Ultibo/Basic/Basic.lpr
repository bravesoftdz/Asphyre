program Basic;
{$mode delphi}{$H+}

uses
 QEMUVersatilePB,GlobalConfig,GlobalConst,GlobalTypes,
 Console,FATFS,FileSystem,Logging,
 Platform,SysUtils,Threads,VirtualDisk;

var
 ImageNo:Integer;
 MountImageBoolean:Boolean;
 MonitorThread:TThreadHandle;
 MainThread:TThreadHandle;
 OutputWindow:TWindowHandle;

procedure Output(S:String);
begin
 LoggingOutput(S);
 ConsoleWindowWriteLn(OutputWindow,S);
end;

function Monitor(Parameter:Pointer):PtrInt;
var
 SnapShot,Current:PThreadSnapShot;
begin
   Output('monitor thread started ... sleeping for 5 seconds');
   Sleep(5 * 1000);
   Output('monitor thread assuming failure');
   SnapShot:=ThreadSnapShotCreate;
   Current:=SnapShot;
   while Assigned(Current) do
    if Current.Handle = MainThread then
     begin
      Output(Format('main thread %s',[ThreadStateToString(Current.State)]));
      Current:=nil;
     end
    else
     begin
      Current:=Current.Next;
     end;
   ThreadSnapShotDestroy(SnapShot);
 Monitor:=0;
end;

begin
 try
  try
   LOGGING_INCLUDE_COUNTER:=False;
   LOGGING_INCLUDE_TICKCOUNT:=True;
   CONSOLE_REGISTER_LOGGING:=True;
   CONSOLE_LOGGING_POSITION:=CONSOLE_POSITION_RIGHT;
   LoggingConsoleDeviceAdd(ConsoleDeviceGetDefault);
   CONSOLE_REGISTER_LOGGING:=False;
   LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_CONSOLE));
   OutputWindow:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_LEFT,True);
   Output('program start');
   Output('calling FileSysDriver.CreateImage ...');
   ImageNo:=FileSysDriver.CreateImage(0,'RAM Disk',itMEMORY,mtREMOVABLE,ftUNKNOWN,iaDisk or iaReadable or iaWriteable,512,10240,0,0,0,pidUnused);
   Output(Format('ImageNo %d',[ImageNo]));
   MainThread:=ThreadGetCurrent;
   MonitorThread:=BeginThread(@Monitor,nil,MonitorThread,THREAD_STACK_DEFAULT_SIZE);
   Sleep(1 * 1000);
   Output('calling FileSysDriver.MountImage ...');
   MountImageBoolean:=FileSysDriver.MountImage(ImageNo);
   if not MountImageBoolean then
    Output(Format('test failed - MountImage failed',[]))
   else
    Output(Format('test succeeded - MountImage succeeded',[]));
  except on E:Exception do
   begin
    Output(Format('Exception: %s',[E.Message]));
   end;
  end;
 finally
  Output('program stop');
  ThreadHalt(1 * 1000);
 end;
end.
