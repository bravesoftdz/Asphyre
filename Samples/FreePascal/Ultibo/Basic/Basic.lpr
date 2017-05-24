program Basic;

uses
 QEMUVersatilePB,GlobalConfig,GlobalConst,GlobalTypes,Console,Serial,Platform,Logging;

var
 LeftStatus,LeftOutput,RightStatus,RightOutput:TWindowHandle;

procedure Status(Window:TWindowHandle;S:String);
begin
 ConsoleWindowWriteLn(Window,S);
end;

procedure Log(Window:TWindowHandle;S:String);
begin
 LoggingOutput(S);
 ConsoleWindowWriteLn(Window,S);
end;

procedure Success(Window:TWindowHandle);
begin
 ConsoleWindowSetBackColor(Window,COLOR_GREEN);
 ConsoleWindowClear(Window);
end;

begin
 LeftStatus:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_TOPLEFT,True);
 RightStatus:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_TOPRIGHT,True);
 LeftOutput:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_BOTTOMLEFT,True);
 RightOutput:=ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_BOTTOMRIGHT,True);
 SERIAL_REGISTER_LOGGING:=True;
 SerialLoggingDeviceAdd(SerialDeviceGetDefault);
 LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_SERIAL));
 Log(LeftOutput,'program start');
 Success(LeftStatus);
 Success(RightStatus);
 Log(LeftOutput,'program stop');
 while True do
  ;
end.
