unit debug;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SHFolder;


  function GetCurrentFolderPath(): string;
  procedure Print(Text : String; ClearFile: Boolean);
  procedure Print(Text: String);
  Procedure Print(Point: TPoint);
  procedure Print(text: String; aRect: tRect);
  procedure Print(text: String; number: Integer) ;
  function GetSpecialFolderPath(folder : integer) : string;



implementation

function GetCurrentFolderPath() :String ;
var

  folderExists: Boolean;

begin
  GetcurrentfolderPath:= GetSpecialFolderPath(CSIDL_MYPICTURES)+ '\ScreenDumps\'
                         + FormatDateTime('MMMM YYYY\DD MMMM YYYY',Now)  ;

  folderExists:=DirectoryExists(GetCurrentFolderPath);

  IF NOT folderExists THEN
        begin
            forcedirectories(GetCurrentFolderPath);
        end;
end;

function GetSpecialFolderPath(folder : integer) : string;

 const
   SHGFP_TYPE_CURRENT = 0;
   { Folder Types
   CSIDL_ADMINTOOLS
   CSIDL_APPDATA
   CSIDL_COMMON_ADMINTOOLS
   CSIDL_COMMON_APPDATA
   CSIDL_COMMON_DOCUMENTS
   CSIDL_COOKIES
   CSIDL_FLAG_CREATE
   CSIDL_FLAG_DONT_VERIFY
   CSIDL_HISTORY
   CSIDL_INTERNET_CACHE
   CSIDL_LOCAL_APPDATA
   CSIDL_MYPICTURES
   CSIDL_PERSONAL
   CSIDL_PROGRAM_FILES
   CSIDL_PROGRAM_FILES_COMMON
   CSIDL_SYSTEM
   CSIDL_WINDOWS
   }
 var
   path: array [0..MAX_PATH] of char;
 begin

   SHGetFolderPath(0,folder,0,SHGFP_TYPE_CURRENT,@path[0]) ;
     Result := path  ;

 end;


//DEBUG LOGGING
procedure Print(text: String; aRect: tRect);
begin
    debug.Print       (Text + chr(9)
                     + chr(9) + ' TopLeft: ' + inttostr(arect.topleft.x) + ',' + inttostr(arect.topleft.y)
                     + chr(9) + ' BottomRight: ' + inttostr(arect.BottomRight.x) + ',' + inttostr(arect.bottomright.y)
                     + chr(9) + ' Width: ' + inttostr(arect.Right - arect.Left)
                     + chr(9) + ' Height: ' + inttostr(arect.Bottom - arect.Top))
end;

procedure Print(text: String; number: Integer) ;
begin
  Debug.Print(Text + inttoStr(number));
end;

procedure Print(Text: String);
begin
  Debug.Print(Text, False);
end;

Procedure Print(Point: TPoint);
begin
     Debug.print('x: ' + inttostr(Point.x) + '  y: ' + inttostr(Point.y));
end;

procedure Print(Text : String; ClearFile: Boolean);

 var
   file1: Textfile;

 begin


   if false then
         begin
              AssignFile(File1, Getcurrentfolderpath() +  '\Debug.txt');
              Try
                 begin
                     if (ClearFile) then
                        begin
                             rewrite(file1);
                        end
                     else
                         begin
                          append(File1);
                          end;

                     Writeln(File1,FormatDateTime('hh.mm.ss',Now) + ' - ' + Text);
                 end;

              except

              End;

               CloseFile(File1);
         end;

 end;


end.

