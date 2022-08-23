unit Unit3; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ColorBox, Unit4;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Label5: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label57: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo10: TMemo;
    Memo11: TMemo;
    Memo12: TMemo;
    Memo13: TMemo;
    Memo14: TMemo;
    Memo15: TMemo;
    Memo16: TMemo;
    Memo17: TMemo;
    Memo18: TMemo;
    Memo19: TMemo;
    Memo2: TMemo;
    Memo20: TMemo;
    Memo21: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    Memo7: TMemo;
    Memo8: TMemo;
    Memo9: TMemo;
    Shape1: TShape;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form3: TForm3; 

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.Button1Click(Sender: TObject);
begin
case ComboBox1.ItemIndex of
0:Form4.Memo1.Text := Memo1.Text;
1:Form4.Memo1.Text := Memo2.Text;
2:Form4.Memo1.Text := Memo3.Text;
3:Form4.Memo1.Text := Memo4.Text;
4:Form4.Memo1.Text := Memo5.Text;
5:Form4.Memo1.Text := Memo12.Text;
6:Form4.Memo1.Text := Memo13.Text;
7:Form4.Memo1.Text := Memo6.Text;
8:Form4.Memo1.Text := Memo7.Text;
9:Form4.Memo1.Text := Memo14.Text;
10:Form4.Memo1.Text := Memo8.Text;
11:Form4.Memo1.Text := Memo9.Text;
12:Form4.Memo1.Text := Memo15.Text;
13:Form4.Memo1.Text := Memo16.Text;
14:Form4.Memo1.Text := Memo17.Text;
15:Form4.Memo1.Text := Memo18.Text;
end;
if CheckBox1.Checked = true then
Form4.Memo2.Text := Memo10.Text;
Form4.Show;
end;

procedure TForm3.Button2Click(Sender: TObject);
var
  i:integer;
begin
for i:=0 to Memo6.Lines.Count-1 do
Memo9.Lines.add(floattostr(strtofloat(Memo6.Lines[i])+strtofloat(Memo7.Lines[i])+strtofloat(Memo8.Lines[i])+strtofloat(Memo14.Lines[i])));
end;

procedure TForm3.Button3Click(Sender: TObject);
begin

end;

procedure TForm3.Button4Click(Sender: TObject);
begin
  Edit17.Text:=floattostrf(strtofloat(Memo3.Lines[Memo3.lines.count-1])
  +strtofloat(Memo5.Lines[Memo5.lines.count-1])
  +strtofloat(Memo13.Lines[Memo13.lines.count-1])
  +strtofloat(Edit18.Text),ffGeneral,7,7);
  Edit16.Text:=floattostrf(strtofloat(Memo2.Lines[Memo2.lines.count-1])
  +strtofloat(Memo4.Lines[Memo4.lines.count-1])
  +strtofloat(Memo12.Lines[Memo12.lines.count-1]),ffGeneral,7,7);
end;

end.

