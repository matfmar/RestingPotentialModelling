unit Unit4; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm4 }

  TForm4 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    procedure maxmin(var max,min:real);
    { public declarations }
  end; 

var
  Form4: TForm4; 

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.maxmin(var max,min:real);
var
  i: integer;
  a:real;
begin
max :=strtofloat(Memo1.Lines[0]);min:=strtofloat(Memo1.Lines[0]);
for i:=0 to Memo1.Lines.Count-1 do
begin
a:=strtofloat(memo1.lines[i]);
if a<min then min := a;
if a>max then max:=a;
end;
end;

procedure TForm4.Button1Click(Sender: TObject);
var
  x,y,max,min:real;
  i,l:integer;
begin
l := Memo1.Lines.Count;
Form4.maxmin(max,min);
if CheckBox1.Checked = true then max:=0.0;
Canvas.pen.Color:=clblue;
canvas.pen.Width:=8;
canvas.MoveTo(8,48);
x:=8;
y:=696-((((strtofloat(memo1.lines[0])-min)*(648))/(max-min))+48)+48;
canvas.moveto(Round(x),Round(y));
for i:=0 to Memo1.Lines.Count-1 do
begin
x:=(i*1200/l)+8;
y:=696-((((strtofloat(memo1.lines[i])-min)*(648))/(max-min))+48)+48;
canvas.LineTo(Round(x),Round(y));
end;
canvas.pen.color:=clred;
canvas.pen.width:=3;
canvas.MoveTo(8,45);
canvas.LineTo(1208,45);
canvas.moveto(8,696);
canvas.lineto(1208,696);
label1.Caption:=floattostr(max);
label2.Caption:=floattostr(min);
label4.caption:=inttostr(l);
label1.left:=8;label1.top:=48;
label2.left:=8;label2.top:=704;
label4.left:=1208;label4.top:=704;
label1.visible:=true;
label2.visible:=true;
label4.visible:=true;
label7.visible:=true;
label7.Caption:='Nachylenie wykresu wynosi: '+ floattostr((max-min)/l);

if Memo2.Lines.Text <> '' then
begin

  l := Memo2.Lines.Count;
  Canvas.pen.Color:=clgreen;
  canvas.pen.width:=6;
  canvas.MoveTo(8,48);
  x:=8;
  y:=696-((((strtofloat(memo2.lines[0])-min)*(648))/(max-min))+48)+48;
  canvas.moveto(Round(x),Round(y));
  for i:=0 to Memo2.Lines.Count-1 do
  begin
  x:=(i*1200/l)+8;
  y:=696-((((strtofloat(memo2.lines[i])-min)*(648))/(max-min))+48)+48;
  canvas.LineTo(Round(x),Round(y));
  end;
  canvas.pen.color:=clyellow;
  canvas.MoveTo(8,45);
  canvas.LineTo(1208,45);
  canvas.moveto(8,696);
  canvas.lineto(1208,696);
end;

end;

procedure TForm4.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
end;

end.

