unit main;

//{$mode objfpc}{$H+}
{$mode delphi}{$H+}
interface

uses
  Classes, SysUtils, Forms, Controls, LCLIntf, LCLType, Buttons, StdCtrls,
  cyRunTimeResize, vinfo, debug, capture, transparency, graphics,
  ExtCtrls, Clipbrd,
   windows, messages, unit1;

type

  { TForm1 }

  TForm1 = class(TForm)
    cyRunTimeResize1: TcyRunTimeResize;
    RadioButton1: TRadioButton;
    Save: TBitBtn;
    ImageList1: TImageList;
    Timer1: TTimer;

    procedure Hook;
    procedure Unhook;
    procedure FormActivate(Sender: TObject);
    procedure AddBuildBumber(Title: string);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    function GetInstanceCount(): word;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    function RandomColour(): tColor;

    procedure RadioButton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SaveClick(Sender: TObject);
    procedure SaveKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SaveKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SaveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SaveMouseLeave(Sender: TObject);
    procedure SaveMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure Timer1Timer(Sender: TObject);
    procedure DrawBorders(aColour: tColor = $00EA8E44);
    procedure SaveDisplayIcon();
    procedure SetTransparancy();
    procedure Timer2StopTimer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure UniqueInstance1OtherInstance(Sender: TObject;
      ParamCount: Integer; Parameters: array of String);
  private
    { private declarations }
     printscreenMode : Boolean;


        FNextClipboardOwner: HWnd;   // handle to the next viewer
    // Here are the clipboard event handlers
   function WMChangeCBChain(wParam: WParam; lParam: LParam):LRESULT;
  function WMDrawClipboard(wParam: WParam; lParam: LParam):LRESULT;

    procedure KeyDownCommon(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  Form2: unit1.TForm2 ;
  gSound: Boolean;
  stopCapturing: boolean;

 procedure TakeCapture(IncludeCursor: Boolean = False; FromClipBoard: Boolean = false) ;
 procedure TimerMode();
 procedure OpenFolderMode();
 function EnuWin(Wnd: hWnd;LParam: LPARAM): WINBOOL; stdcall;

implementation

{$R *.lfm}

var
  PrevWndProc:windows.WNDPROC;

function WndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam;
  lParam: LParam): LRESULT; stdcall;
begin
  if uMsg = WM_CHANGECBCHAIN then begin
    Result := Form1.WMChangeCBChain(wParam, lParam);
    Exit;
  end
  else if uMsg=WM_DRAWCLIPBOARD then begin
    Result := Form1.WMDrawClipboard(wParam, lParam);
    Exit;
  end;
  Result := CallWindowProc(PrevWndProc, Ahwnd, uMsg, WParam, LParam);
end;

{ TForm1 }

procedure TForm1.AddBuildBumber(Title: string);
 Var
  BuildNum : String[12];
  Info: TVersionInfo;
  i: byte;
begin

     Info := TVersionInfo.Create;
     Info.Load(HINSTANCE);

     BuildNum := 'v';
     for i:=0 to 3 do
         begin
              BuildNum :=BuildNum +  IntToStr(Info.FixedInfo.FileVersion[i] )+ '.';
         end;

  // Update the title string - include the version & ver #
  form1.Caption := Title + ' ' + buildnum ;
   Info.Free;
///////////////////////////

   save.Hint:=Title + ' ' + buildnum + chr(10) + chr(13)  + save.hint;

end;

procedure TForm1.FormCreate(Sender: TObject);
//var
 //instances: byte;

begin

     self.AddBuildBumber('ScreenDump');



     //
     randomize();
     form1.Constraints.MinHeight:= save.Top + save.height  + save.Top;
     form1.Constraints.MinWidth:=save.left + Save.Width + save.Left + radiobutton1.Width + save.left;
     form1.Height:=Form1.Constraints.MinHeight;
     form1.Width:=form1.Constraints.MinWidth;
     form1.Top:=100;
     form1.Left:=100;
     form1.AlphaBlendValue:=120;
     form1.RadioButton1.Top:=save.Top;
     form1.RadioButton1.left:=form1.Width - form1.RadioButton1.Width - save.Left  ;
     form1.Timer1.Enabled:=false;
     stopCapturing:=false;
     form1.ImageList1.GetBitmap(0,form1.Save.Glyph);
     form1.cyRunTimeResize1.Control:=tControl(self);
     form1.cyRunTimeResize1.Options.ResizeBorderSize:=self.Save.Left * 2 ;
     gSound:=true;
end;

procedure TForm1.FormDeactivate(Sender: TObject);
begin

end;

//-----------------------------------------------------------------------------------------

procedure TForm1.Hook;
begin

    if not self.printscreenMode  then
      begin
    PrevWndProc := Windows.WNDPROC(SetWindowLong(Self.Handle, GWL_WNDPROC, PtrInt(@WndCallback)));
    FNextClipboardOwner := SetClipboardViewer(Self.Handle);
    printscreenMode := true;
    self.Repaint;
      end;
end;

procedure TForm1.Unhook;
begin
    if self.printscreenMode then;
     begin
          clipbrd.FreeAllClipboards;
          ChangeClipboardChain(Handle, FNextClipboardOwner);
     end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin

  form1.SetTransparancy();
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Debug.Print('ScreenDump App closed', false);
  unhook;
end;

  procedure TForm1.KeyDownCommon(Sender: TObject; var Key: Word;
   Shift: TShiftState);

var
 moveAmount: Byte;
begin

  if ssCtrl in Shift then
  begin
       moveAmount:= 60;
  end
  Else
  begin
      moveAmount:= 30;
  end;

case key of
     lcltype.VK_SPACE,
     lcltype.VK_RETURN   :begin
                            TakeCapture(false);
                            end;

     lcltype.SM_CYFRAME,
     lcltype.VK_UP       :begin
                               if  ssShift in shift then
                                   begin
                                        form1.Top:=Form1.Top - moveAmount;
                                   end
                               else
                                   begin
                                        form1.Height:=Form1.Height - moveAmount;
                                   end;
                             end;

     lcltype.SM_CXMINTRACK,
     lcltype.VK_DOWN     :begin
                                if  ssShift in shift then
                                   begin
                                        form1.Top:=Form1.Top + moveAmount;
                                   end
                               else
                                   begin
                                        form1.Height:=Form1.Height + moveAmount;
                                   end;
                                end;

     lcltype.VK_LEFT     :begin
                               if  ssShift in shift then
                                   begin
                                        form1.Left:=Form1.Left - moveAmount;
                                   end
                               else
                                   begin
                                        form1.Width:=Form1.width - moveAmount;
                                   end;
                               end;

     lcltype.VK_RIGHT    :begin
                               if  ssShift in shift then
                                   begin
                                        form1.Left:=Form1.Left + moveAmount;
                                   end
                               else
                                   begin
                                        form1.width:=Form1.width + moveAmount;;
                                   end;
                               end;

     lcltype.vk_S        :begin
                               gSound:= not(gSound);
                               end;

     lcltype.vk_p         : hook;


end;


 end;
 //-----------------------------------------------------------------------------------------

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    self.DrawBorders(clfuchsia);
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
     form1.KeyDownCommon(sender, Key, shift);
end;

procedure TForm1.FormMouseEnter(Sender: TObject);
begin

end;

procedure TForm1.FormMouseLeave(Sender: TObject);
begin

  self.DrawBorders();
end;

//-----------------------------------------------------------------------------------------

procedure TForm1.SaveKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  form1.KeyDownCommon(sender, Key, shift);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  form1.Cursor:=crDrag;
  self.DrawBorders(clFuchsia);

  self.cyRunTimeResize1.StartJob(x,y);
end;
//-----------------------------------------------------------------------------------------

function TForm1.RandomColour: tColor;
var
red, green, blue: byte;
begin
     red:= random(254);
     green:=random(254);
     blue:=random(254);

     result:= graphics.RGBToColor(red, green, blue);

end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  self.cyRunTimeResize1.DoJob(x,y);
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  self.DrawBorders();

  self.cyRunTimeResize1.EndJob(x,y);
  self.Cursor:=crHandPoint;
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

if ssCtrl in Shift then
   begin
         form1.Height:=Form1.Height - ((wheelDelta div 10) *2);
   end
   Else
   Begin
         form1.Height:=Form1.Height - (wheelDelta div 10);
   end;


end;
//-----------------------------------------------------------------------------------------

procedure TForm1.DrawBorders(aColour: tColor);
 var
  currentRect: trect;
  rounding: byte;
 begin
      currentRect := form1.GetClientRect;
      if self.printscreenMode then
        begin
             self.Canvas.Pen.Color:= clLime;
        end else
        begin
      self.Canvas.Pen.Color:= aColour;

        end;
      rounding:=cyRunTimeResize1.Options.ResizeBorderSize;
      self.Canvas.RoundRect(currentRect, rounding, rounding);
      self.Canvas.Rectangle(currentRect);
      self.Canvas.Pen.Width:=1;
      form1.Save.SetFocus;

end;
//-----------------------------------------------------------------------------------------

procedure TForm1.FormPaint(Sender: TObject);
begin

drawborders();
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.SetTransparancy;
begin
     if ((Form1.Width <= Form1.Constraints.MinWidth) and (Form1.Height <= Form1.Constraints.MinHeight))  then
       begin
           transparency.SetTransParent(Form1.Handle, $000FF);
           form1.AlphaBlend:=false;
       end
  else
      begin
            if   (transparency.IsAeroEnabled or ((form1.Width = form1.Constraints.MinWidth) and (form1.Height = form1.Constraints.MinHeight))) then
                 begin
                      transparency.SetTransParent(Form1.Handle, Form1.Color);
                 end
            else
                begin
                      form1.AlphaBlend:=true;
                end;
      end;
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.Timer2StopTimer(Sender: TObject);
begin
  form1.DrawBorders();
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  form1.DrawBorders(form1.RandomColour());
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.UniqueInstance1OtherInstance(Sender: TObject;
  ParamCount: Integer; Parameters: array of String);
begin
  stopcapturing:=true;
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.FormResize(Sender: TObject);

begin
     form1.SetTransparancy() ;
end;


//-----------------------------------------------------------------------------------------

procedure TForm1.RadioButton1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

     If Button = TMouseButton.mbLeft then
       begin
           self.Close;
       end;

end;

procedure TForm1.SaveClick(Sender: TObject);
begin

end;

//-----------------------------------------------------------------------------------------

procedure TForm1.SaveKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SaveDisplayIcon;
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.SaveMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin


  case Button of
    mbLeft:
           begin
               TakeCapture(false);
           end;
    mbMiddle:
           Begin
                TimerMode;
           end;

    mbRight:
            begin
                OpenFolderMode;
            end;
   end;
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.SaveMouseLeave(Sender: TObject);
begin
    SaveDisplayIcon;
end;

procedure TForm1.SaveMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    SaveDisplayIcon;
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.SaveDisplayIcon();
begin
      if form1.Timer1.Enabled then
      begin
          form1.Save.Caption:='Timer';
         form1.ImageList1.GetBitmap(1, form1.Save.Glyph);
      end
   else
       begin
           form1.Save.Caption:='Save';
         form1.ImageList1.GetBitmap(0, form1.Save.Glyph);
       end;
end;
//-----------------------------------------------------------------------------------------

procedure TForm1.Timer1Timer(Sender: TObject);

var
  ss_Running: Boolean;
begin
 SystemParametersInfo (lcltype.SPI_GETSCREENSAVERRUNNING, 0,
   @SS_Running, 0);

   if ss_Running then
        begin
           debug.Print('ScreenSaver Active');
        end
     else
         begin
           TakeCapture(True);
         end;
    SaveDisplayIcon ;
end;
//-----------------------------------------------------------------------------------------


procedure TakeCapture(IncludeCursor: Boolean = False; FromClipBoard: Boolean = false) ;
 var

  aCapture: capture.tScreenCapture;

begin
  stopcapturing:=true;

    Debug.Print('Taking Capture', false);
    form1.Save.Caption:='Save';

    form1.Visible:=false;

   aCapture:=tScreenCapture.Create;

   getCursorPos(aCapture.MousePosition); //Add current cursor position compared to screen coords


    if ((Form1.Width <= Form1.Constraints.MinWidth) and (Form1.Height <= Form1.Constraints.MinHeight))  then
       begin
          if FromClipBoard then
             begin
                aCapture.CaptureScreenFromClipboard(IncludeCursor);
             end
          else
              begin
                aCapture.CaptureScreen(IncludeCursor);
              end;


       end
    else
        begin

           if FromClipBoard then
             begin
                aCapture.MousePosition:= Form1.ScreenToClient(aCapture.MousePosition);
                aCapture.CaptureAreaFromClipboard(form1.BoundsRect, IncludeCursor);
             end
          else
              begin
                //update mousePosition to Form
                aCapture.MousePosition:= Form1.ScreenToClient(aCapture.MousePosition);
                aCapture.CaptureArea(form1.BoundsRect, IncludeCursor);
              end;

        end;

        form1.Visible:=true;
        if form1.Timer1.Enabled = false then
           begin
           Form1.BringToFront;
           end;


        if gSound then
           begin
           if not(Form1.Timer1.enabled) then
              begin
                   sysutils.Beep;
              end;
           end;



      aCapture.SaveCapture();

      freeandnil(aCapture);
    stopcapturing:=false;
    end;
//-----------------------------------------------------------------------------------------

procedure TimerMode();

var
 //timeStr: String;
 timeInt: word;

 begin

        try

           if form1.Timer1.Enabled then
              begin
                   form1.Save.Caption:='Save';

                   Form1.Timer1.Enabled:=false;
              end
           else
              begin
                   form1.Save.Caption:='Timer';

                   form2.ShowModal;

                  timeint:=form2.cyEditInteger1.Value;

                   if timeInt > 0 then
                      begin
                           Form1.Timer1.Interval:=1000 * timeInt;

                           form1.ImageList1.GetBitmap(1, form1.Save.Glyph);
                           form1.Timer1.Enabled:=true;
                      end
                   else
                   begin
                        form1.Timer1.Enabled:=false;
                         form1.SaveDisplayIcon();
                   end;
              end;

        finally
        end;

 end;
//-----------------------------------------------------------------------------------------

procedure OpenFolderMode();
begin
    Debug.Print('Opening Document', false);
    form1.Save.Caption:='Open';
    form1.ImageList1.GetBitmap(2, form1.Save.Glyph);
    opendocument(DEBUG.GetCurrentFolderPath());

end;

function EnuWin(Wnd: hWnd;LParam: LPARAM): WINBOOL; stdcall;
 begin
   TList(LParam).Add(Pointer(Wnd));
   Result:=true;
 end;

function TForm1.WMChangeCBChain(wParam: WParam; lParam: LParam): LRESULT;
var
  Remove, Next: THandle;
begin
  Remove := WParam;
  Next := LParam;
  if FNextClipboardOwner = Remove then FNextClipboardOwner := Next
    else if FNextClipboardOwner <> 0 then
      SendMessage(FNextClipboardOwner, WM_ChangeCBChain, Remove, Next)


end;
//-----------------------------------------------------------------------------------------

function TForm1.WMDrawClipboard(wParam: WParam; lParam: LParam): LRESULT;
begin


  if Clipboard.HasFormat(CF_BITMAP) and ( not(stopCapturing)) and (form1.Visible) Then Begin

     if self.GetInstanceCount() = 1 then //used to stop multiple instances going into loop
       begin
           stopCapturing:=true;
           TakeCapture(true, true);
       end;

  end;
  SendMessage(FNextClipboardOwner, WM_DRAWCLIPBOARD, 0, 0);   // VERY IMPORTANT
  Result := 0;
  stopCapturing:=false
end;
//-----------------------------------------------------------------------------------------

function TForm1.GetInstanceCount: word;
var
  i: byte;
    j: Integer;
   L: TList;
   s: array[0..128] of char;
begin

    i:=0;
    L:=TList.Create;
   Windows.EnumWindows(@EnuWin,LParam(L));
   for j := 0 to L.Count-1 do begin
        windows.getwindowtext(HWND(L[j]), s, 128);
        if (sysutils.TrimRight(s) = Form1.Caption )then
          begin
            i:= (i + 1);
          end;
   end;
   //showmessage(inttostr(i));
   freeandnil(L);
   getinstancecount:=i  ;

end;
//-----------------------------------------------------------------------------------------



end.


