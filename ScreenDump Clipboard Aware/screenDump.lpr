program screenDump;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, pl_excontrols, main, debug, capture, transparency,
  icon, vinfo, unit1;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  if Form1.GetInstanceCount() < 3 then
  begin
     Application.Run;
  end
  else
  begin
    form1.Close;
  end;

end.

