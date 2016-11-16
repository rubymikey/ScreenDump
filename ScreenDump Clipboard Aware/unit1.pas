unit Unit1;

{$mode objfpc}{$H+}

interface

uses
    cyEditInteger
  , Forms
  , StdCtrls
  , ButtonPanel
  ,  ExtCtrls
  ;

type

  { TForm2 }

  TForm2 = class(TForm )
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    cyEditInteger1: TcyEditInteger;
    Image1: TImage;
    Label1: TLabel;

    procedure CancelButtonClick(Sender: TObject);
      procedure RadioButton1Change(Sender: TObject);
  private
    { private declarations }
  public

    { public declarations }
  end;





implementation

{$R *.lfm}

{ TForm2 }



procedure TForm2.CancelButtonClick(Sender: TObject);
begin
  self.cyEditInteger1.Value:=0;
end;


procedure TForm2.RadioButton1Change(Sender: TObject);
begin
  self.Close;
end;

end.

