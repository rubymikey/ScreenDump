unit transparency;

//{$mode objfpc}{$H+}
{$mode delphi}
interface

uses
  windows, graphics;

  type
  _MARGINS = packed record
    cxLeftWidth    : Integer;
    cxRightWidth   : Integer;
    cyTopHeight    : Integer;
    cyBottomHeight : Integer;
  end;

  PMargins = ^_MARGINS;
  TMargins = _MARGINS;

  DwmIsCompositionEnabledFunc      = function(pfEnabled: PBoolean): HRESULT; stdcall;
  DwmExtendFrameIntoClientAreaFunc = function(destWnd: HWND; const pMarInset: PMargins): HRESULT; stdcall;
  SetLayeredWindowAttributesFunc   = function(destWnd: HWND; cKey: TColor; bAlpha: Byte; dwFlags: DWord): BOOL; stdcall;

const
  WS_EX_LAYERED = $80000;
  LWA_COLORKEY  = 1;



function IsAeroEnabled: Boolean;
function WindowsAeroGlassCompatible(): Boolean;
procedure SetTransParent(aHandle: HWND; aColor: TColor);

implementation

function  ISAeroEnabled: Boolean;
var
  hDwmDLL: Cardinal;
  fDwmIsCompositionEnabled:  DwmIsCompositionEnabledFunc;
  fDwmExtendFrameIntoClientArea: DwmExtendFrameIntoClientAreaFunc;
  fSetLayeredWindowAttributesFunc: SetLayeredWindowAttributesFunc;
  bCmpEnable: Boolean;
 // mgn: TMargins;
begin
  result:=false;
  { Continue if Windows version is compatible }
  if WindowsAeroGlassCompatible then begin
    { Continue if 'dwmapi' library is loaded }
    hDwmDLL := LoadLibrary('dwmapi.dll');
    if hDwmDLL <> 0 then begin
      { Get values }
      @fDwmIsCompositionEnabled        := GetProcAddress(hDwmDLL, 'DwmIsCompositionEnabled');
      @fDwmExtendFrameIntoClientArea   := GetProcAddress(hDwmDLL, 'DwmExtendFrameIntoClientArea');
      @fSetLayeredWindowAttributesFunc := GetProcAddress(GetModulehandle(user32), 'SetLayeredWindowAttributes');
      { Continue if values are <> nil }
      if (
      (@fDwmIsCompositionEnabled <> nil) and
      (@fDwmExtendFrameIntoClientArea <> nil) and
      (@fSetLayeredWindowAttributesFunc <> nil)
      )
      then begin
        { Continue if composition is enabled }
        fDwmIsCompositionEnabled(@bCmpEnable);
        if bCmpEnable = True then begin
              result := true;
        end;

      end;
      { Free loaded 'dwmapi' library }
      FreeLibrary(hDWMDLL);
    end;
  end;
end;



function WindowsAeroGlassCompatible(): Boolean;
var
  osVinfo: TOSVERSIONINFO;
begin

  ZeroMemory(@osVinfo, SizeOf(osVinfo));
  OsVinfo.dwOSVersionInfoSize := SizeOf(TOSVERSIONINFO);
  if (
  (GetVersionEx(osVInfo)   = True) and
  (osVinfo.dwPlatformId    = VER_PLATFORM_WIN32_NT) and
  (osVinfo.dwMajorVersion >= 6)
  )
  then Result:=True
  else Result:=False;
end;


procedure SetTransParent(aHandle: HWND; aColor: TColor);
begin

    windows.SetWindowLong(aHandle, GWL_EXSTYLE, Getwindowlong(aHandle, GWL_EXSTYLE) or WS_EX_LAYERED);
    windows.SetLayeredWindowAttributes(aHandle, aColor,255, LWA_COLORKEY);

end;

end.

