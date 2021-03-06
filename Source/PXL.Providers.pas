unit PXL.Providers;
{
  This file is part of Asphyre Framework, also known as Platform eXtended Library (PXL).
  Copyright (c) 2000 - 2016  Yuriy Kotsarenko

  The contents of this file are subject to the Mozilla Public License Version 2.0 (the "License");
  you may not use this file except in compliance with the License. You may obtain a copy of the
  License at http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
  KIND, either express or implied. See the License for the specific language governing rights and
  limitations under the License.
}
{< Device-bound factory implementation that creates secondary components such as canvas and textures. }
interface

{$INCLUDE PXL.Config.inc}

uses
  PXL.Devices, PXL.Textures, PXL.Canvas;

type
  { Abstract device provider that is able to create new instances of important rendering classes such as canvas and
    textures. }
  TGraphicsDeviceProvider = class abstract(TCustomDeviceProvider)
  public
    { This function creates new canvas instance that is tied to the given device. }
    function CreateCanvas(const Device: TCustomDevice): TCustomCanvas; virtual;

    { This function creates new lockable texture instance that is tied to the given device. }
    function CreateLockableTexture(const Device: TCustomDevice;
      const AutoSubscribe: Boolean = True): TCustomLockableTexture; virtual;

    { This function creates new drawable texture instance that is tied to the given device.
      If drawable textures are not supported in this provider, @nil is returned. }
    function CreateDrawableTexture(const Device: TCustomDevice;
      const AutoSubscribe: Boolean = True): TCustomDrawableTexture; virtual;
  end;

implementation

function TGraphicsDeviceProvider.CreateCanvas(const Device: TCustomDevice): TCustomCanvas;
begin
  Result := nil;
end;

function TGraphicsDeviceProvider.CreateLockableTexture(const Device: TCustomDevice;
  const AutoSubscribe: Boolean): TCustomLockableTexture;
begin
  Result := nil;
end;

function TGraphicsDeviceProvider.CreateDrawableTexture(const Device: TCustomDevice;
  const AutoSubscribe: Boolean): TCustomDrawableTexture;
begin
  Result := nil;
end;

end.
