program Basic;
{$mode delphi}{$H+}

uses
 Console,FATFS,FileSystem,GlobalConfig,GlobalConst,GlobalTypes,Logging,
 Platform,QEMUVersatilePB,SysUtils,Threads,VirtualDisk;

var
 ImageNo:Integer;
 MountImageBoolean:Boolean;
 MonitorThread:TThreadHandle;
 MainThread:TThreadHandle;
 LeftStatus,LeftOutput,RightStatus,RightOutput:TWindowHandle;

procedure Log(Window:TWindowHandle;S:String);
begin
 LoggingOutput(S);
 ConsoleWindowWriteLn(Window,S);
end;

function Monitor(Parameter:Pointer):PtrInt;
var
 SnapShot,Current:PThreadSnapShot;
begin
   Log(RightOutput,'Monitor thread started');
   Sleep(3 * 1000);
   Log(RightOutput,'Monitor thread assuming failure');
   SnapShot:=ThreadSnapShotCreate;
   Current:=SnapShot;
   while Assigned(Current) do
    if Current.Handle = MainThread then
     begin
      Log(RightOutput,Format('program %s',[ThreadStateToString(Current.State)]));
      Current:=nil;
     end
    else
     begin
      Current:=Current.Next;
     end;
   ThreadSnapShotDestroy(SnapShot);
   Log(RightOutput,Format('test failed - did not return',[]));
   Log(RightOutput,'program stop');
 Monitor:=0;
end;

procedure Delay(Milliseconds:Integer);
begin
 Log(LeftOutput,Format('program delay %3.1f seconds started',[Milliseconds / 1000.0]));
 Sleep(Milliseconds);
 Log(LeftOutput,Format('program delay %3.1f seconds finished',[Milliseconds / 1000.0]));
end;

procedure Success(Window:TWindowHandle);
begin
 ConsoleWindowSetBackColor(Window,COLOR_GREEN);
 ConsoleWindowClear(Window);
end;

begin
 try
  try
   LOGGING_INCLUDE_COUNTER:=False;
   LOGGING_INCLUDE_TICKCOUNT:=True;
// LeftStatus:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_TOPLEFT,True);
   CONSOLE_REGISTER_LOGGING:=True;
   CONSOLE_LOGGING_POSITION:=CONSOLE_POSITION_TOPLEFT;
   LoggingConsoleDeviceAdd(ConsoleDeviceGetDefault);
   CONSOLE_REGISTER_LOGGING:=False;
   LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_CONSOLE));
   RightStatus:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_TOPRIGHT,True);
   LeftOutput:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_BOTTOMLEFT,True);
   RightOutput:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_BOTTOMRIGHT,True);
   Log(LeftOutput,'program start');
// Delay(3 * 1000);
   MainThread:=ThreadGetCurrent;
   Log(LeftOutput,'Calling FileSysDriver.CreateImage ...');
   MonitorThread:=BeginThread(@Monitor,nil,MonitorThread,THREAD_STACK_DEFAULT_SIZE);
   ImageNo:=FileSysDriver.CreateImage(0,'RAM Disk',itMEMORY,mtREMOVABLE,ftUNKNOWN,iaDisk or iaReadable or iaWriteable,512,10240,0,0,0,pidUnused);
// ImageNo:=-1000;
   Sleep(1 * 1000);
   ThreadTerminate(MonitorThread,ERROR_SUCCESS);
   Log(LeftOutput,Format('ImageNo %d',[ImageNo]));
   Log(LeftOutput,'Calling FileSysDriver.MountImage ...');
   MountImageBoolean:=FileSysDriver.MountImage(ImageNo);
// MountImageBoolean:=True;
   if not MountImageBoolean then
    begin
     Log(LeftOutput,Format('test failed - MountImage failed',[]));
    end
   else
    begin
     Success(LeftStatus);
     Success(RightStatus);
    end;
  except on E:Exception do
   begin
    Log(LeftOutput,Format('Exception: %s',[E.Message]));
   end;
  end;
 finally
  Log(LeftOutput,'program stop');
  ThreadHalt(1 * 1000);
 end;
end.
