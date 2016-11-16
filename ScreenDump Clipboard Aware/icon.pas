unit icon;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, windows, Graphics, forms, mouse, lclintf;



procedure DrawCursor (ACanvas:TCanvas; Position:TPoint) ;
// procedure DrawCursor2 (ACanvas:TCanvas; Position:TPoint) ;
 procedure DrawCursor3(ACanvas:TCanvas; Position:TPoint);
 procedure DrawCursor4(ACanvas:TCanvas; Position:TPoint);
 function GetCursorInfo2(position: Tpoint): TCursorInfo;

implementation

procedure DrawCursor (ACanvas:TCanvas; Position:TPoint) ;

 begin
    //shows what the cursor would be if over this application
    //not accurate to the application the cursor is currently interacting with
    DrawIconEx(ACanvas.Handle, Position.X, Position.Y,
              windows.GetCursor, 32, 32, 0, 0, DI_NORMAL) ;
 end;
 {
procedure DrawCursor2(ACanvas:TCanvas; Position:TPoint) ;

   var
   theCursorInfo: TCursorInfo;
  theIcon: TIcon;
  theIconInfo: TIconInfo;
 begin

    theIcon := TIcon.Create;
    theCursorInfo.cbSize := SizeOf(theCursorInfo);
     GetCursorInfo(theCursorInfo);
     theIcon.Handle := CopyIcon(theCursorInfo.hCursor);
     GetIconInfo(theIcon.Handle, theIconInfo);
     aCanvas.Draw(position.x, position.y, theicon);
     DeleteObject(theIconInfo.hbmMask);
     DeleteObject(theIconInfo.hbmColor);



      theIcon.Free;

 end;
 }
procedure DrawCursor3(ACanvas:TCanvas; Position:TPoint);

 var
    HCursor : THandle;
 begin
    //always shows the default pointer cursor
    HCursor := Screen.Cursors [Ord(Screen.Cursor)];
    DrawIconEx(ACanvas.Handle, Position.X, Position.Y, HCursor, 32, 32, 0, 0, DI_NORMAL) ;

end;

procedure DrawCursor4(ACanvas:TCanvas; Position:TPoint);
var
   myCursor: TIcon;
   CursorInfo: TCursorInfo;
   IconInfo: TIconInfo;
begin

   myCursor:=TIcon.Create;
   Cursorinfo:=GetCursorInfo2(position);

   if Cursorinfo.hCursor <> 0 then
   begin
     myCursor.Handle:=cursorinfo.hCursor;
     //Get hotspot info
     windows.GetIconInfo(Cursorinfo.hCursor, IconInfo);
     aCanvas.Draw(position.x, position.y, mycursor);
   end;
     MyCursor.ReleaseHandle;
      MyCursor.Free;

end;

function GetCursorInfo2(position: Tpoint): TCursorInfo;
var
   hWindow: HWND;
   dwThreadID, dwCurrentThreadID: DWORD;
begin
   hWindow:= lclintf.WindowFromPoint(position);
   if lclintf.IsWindow(hwindow) then
   begin
     //get thread ID of cursor owner
     dwThreadID := windows.GetWindowThreadProcessId(hWindow,nil);
     //get the threadID for the current thread
     dwCurrentthreadID := windows.GetCurrentThreadId;
      // If the cursor owner is not us then we must attach to
      // the other thread in so that we can use GetCursor() to
      // return the correct hCursor


      if (dwCurrentThreadID <> dwThreadID) then
      begin
        if AttachThreadInput(dwCurrentThreadID, dwThreadID, True) then
        begin
          // Get the handle to the cursor
          Result.hCursor := GetCursor;
          AttachThreadInput(dwCurrentThreadID, dwThreadID, False);
        end;
      end
      else
      begin
        Result.hCursor := GetCursor;
      end;

   end;
end;

end.


