program Basic;

uses
 QEMUVersatilePB,GlobalConfig,GlobalConst,Serial,Platform,Logging;

begin
 SERIAL_REGISTER_LOGGING:=True;
 SerialLoggingDeviceAdd(SerialDeviceGetDefault);
 LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_SERIAL));
 LoggingOutput('program start');
 LoggingOutput('program stop');
 while True do
  ;
end.
