unit capture;

{$mode objfpc}{$H+}

interface


uses
  Classes, forms, SysUtils, Graphics, lclintf, lcltype, clipbrd, math, mouse ,icon, debug, extctrls;
type
    tScreenCapture = class



       public
       MousePosition: TPoint;

       procedure CaptureAreaFromClipboard(area: tRect; showMouse: boolean = false);
       procedure CaptureScreenFromClipboard(showMouse: boolean = false);

       procedure CaptureScreen(showMouse: boolean = false);
       procedure CaptureArea(area: tRect; showMouse: boolean = false);
       procedure SaveCapture();

       protected

       image: TBitmap;
       //jpg: TJpegImage;
       targetRect: tRect;
       sourceRect: tRect;
       fileName: ansistring;
       MouseShow: Boolean;

       procedure AreaCapInit(area: tRect);
       procedure ScreenCapInit();

       procedure CreateFileName();
       Procedure TakeCapture();
       procedure SaveToClipboard;
       //procedure ImageChangeEvent(Sender: TObject);
      end;


implementation
{
procedure tScreenCapture.ImageChangeEvent(Sender: TObject);
begin
    // SaveToClipboard;
    // saveCapture;

end; }



//AREA MODE/////////////////////////////////////////////////////////////////////////////

procedure tScreenCapture.areaCapInit(area: tREct);
begin

     self.image:=tBitmap.Create;

     self.sourceRect.Left:= math.Max(area.Left, screen.Desktoprect.Left);
     self.SourceRect.Top:= math.Max(area.Top  , screen.DesktopRect.top);

     self.SourceRect.Right:= math.Min(area.Right , screen.DesktopRect.right);
     self.SourceRect.Bottom:= math.Min(area.Bottom , screen.DesktopRect.Bottom);

     self.image.Width:= (SourceRect.Right - SourceRect.left );
     self.image.Height:= (SourceRect.Bottom - SourceRect.Top);

     self.targetRect:= Rect(0,0,self.image.Width, self.image.Height);

     self.CreateFileName();

end;

procedure tScreenCapture.CaptureAreaFromClipboard(area: tRect; showMouse: boolean = false) ;
var
  tempImage: tBitmap;

begin

     self.AreaCapInit(area);

     tempImage:= tBitmap.Create;

     tempImage.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));

     Image.Canvas.CopyRect(self.targetRect, tempImage.Canvas, self.sourceRect);;

     if showMouse then
     begin
       icon.DrawCursor3(self.image.Canvas, self.mouseposition);
     end;

   freeandnil(tempImage);
end;





procedure tScreenCapture.CaptureArea(area: tRect; showMouse: boolean = false );


begin

     self.AreaCapInit(area);

     self.TakeCapture();

     if showMouse then
     begin
       icon.DrawCursor3(self.image.Canvas, self.mouseposition);
     end;

end;


//SCREEN MODE///////////////////////////////////////////////////////////////////

procedure tScreenCapture.ScreenCapInit();
begin

          //Bitmap copy
     self.sourceRect:=screen.DesktopRect;
     self.image:=tBitmap.Create;
     self.image.Width:= (screen.DesktopRect.Right - screen.DesktopRect.Left);
     self.image.Height:= (screen.DesktopRect.Bottom - screen.DesktopRect.Top);
     self.targetRect:= Rect(0,0,self.image.Width, self.image.Height);

     self.sourceRect:= screen.DesktopRect;

end;

procedure tScreenCapture.CaptureScreenFromClipboard(showMouse: boolean = false);




begin
     self.ScreenCapInit();


    //self.image.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfPixmap));
    self.image.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));

    // if Clipboard.FindPictureFormatID = PredefinedClipboardFormat(pcfDelphiBitmap) then
    // begin
     //     self.image.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfDelphiBitmap));
  //end;


     if showMouse then
        begin
             icon.DrawCursor3(self.image.Canvas, self.MousePosition );
        end;
end;

procedure tScreenCapture.CaptureScreen(showMouse: boolean = false);
begin

     self.ScreenCapInit();

     self.TakeCapture();

     if showMouse then
     begin
       icon.DrawCursor3(self.image.Canvas, self.MousePosition );
     end;

end;


////////////////////////////////////////////////////////////////////////////////////

procedure tScreenCapture.TakeCapture();
var
  c: TCanvas;

begin

     c:= TCanvas.Create;
     c.Handle := GetDC(0);

     self.image.Canvas.CopyRect(self.targetRect, c, self.sourceRect); //BITMAP

     ReleaseDC(0, c.Handle);

     freeandnil(c);
end;


Procedure tScreenCapture.CreateFileName();
 var
    aFilePath: String;
    aFileName: String;
    aFileRevision: byte;
    aFullFilePathName: String;
 begin
   try
     begin
        aFilePath:=debug.GetCurrentFolderPath();
        aFileRevision:=0;

        aFileName:= FormatDateTime('\hh.mm.ss',Now)  ;

        aFullFilePathName:=aFilePath + aFileName +  '.jpg';

        while fileExists(aFullFilePathName) do
            begin
                 aFileRevision:=(aFileRevision + 1);
                 aFullFilePathName:=aFilePath + aFileName + '(' + IntToStr(aFileRevision) + ')' + '.jpg';
            end;
     end;
   finally
   end;
   self.fileName:=aFullFilePathName;
   aFileName:='';
   aFullFilePathName:='';


 end;

procedure tScreenCapture.SaveCapture();
Var

  aJPG: TJpegImage;

Begin
     self.CreateFileName();

     aJPG:=TJpegImage.Create;
     aJPG.Assign(self.image);



     aJPG.SaveToFile(self.fileName);
     self.SaveToClipboard;

     self.image.FreeImage;
     self.image.Free;
     self.image:=nil;

     freeandnil(aJPG);

end;

procedure tScreenCapture.SaveToClipboard();
begin
     Clipboard.Assign(self.Image);
end;




end.

