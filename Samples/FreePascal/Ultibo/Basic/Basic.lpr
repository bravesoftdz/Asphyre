program Basic;
{$mode delphi}{$H+}

uses
  GlobalConst,Threads,Console,SysUtils,
  QEMUVersatilePB,FATFS,FileSystem,VirtualDisk;

var
 ImageNo:Integer;
 MountImageBoolean:Boolean;

begin
 try
  try
// Sleep(3 * 1000);
   ConsoleWindowCreate(ConsoleDeviceGetDefault, CONSOLE_POSITION_FULLSCREEN, True);
   ConsoleWriteLn('Starting create ram disk test');
   ImageNo:=FileSysDriver.CreateImage(0,'RAM Disk',itMEMORY,mtREMOVABLE,ftUNKNOWN,iaDisk or iaReadable or iaWriteable,512,20480,0,0,0,pidUnused);
   ConsoleWriteLn(Format('ImageNo %d',[ImageNo]));
   ConsoleWriteLn('Calling FileSysDriver.MountImage ...');
   MountImageBoolean:=FileSysDriver.MountImage(ImageNo);
   if not MountImageBoolean then
    ConsoleWriteLn('MountImage failed')
   else
    ConsoleWriteLn('MountImage succeeded');
   ConsoleWriteLn('Test completed');
  except on E:Exception do
   begin
    ConsoleWriteLn(Format('Exception: %s',[E.Message]));
   end;
  end;
 finally
  ThreadHalt(0);
 end;
end.
