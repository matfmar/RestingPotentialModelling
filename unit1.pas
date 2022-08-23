unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Unit2, Unit3;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{ TForm1 }

const
  R=8.31;
  F=96500;
  EPS0=8.85e-12;

var
  Nastepny:boolean;    {jak chcemy dalej kontynuowac z poprzednimi parametrami to true}

function SprawdzWartosci(Cli3,Cl,Vi,Vo,W,b,K,Na:double) : boolean;
var
  Clo2,Wo2,Wi2,X,Ki2,Ko2,Nai2,Nao2:double;
begin
 Clo2:=(Cl-(Cli3*Vi))/Vo;
 Wo2:=(W-(Cli3*Vi)-(b*Vi))/Vo;
 Wi2:=b+Cli3;
 X:=Wo2/Wi2;
 Ki2:=K/(Vi+(X*Vo));
 Ko2:=X*Ki2;
 Nai2:=Na/(Vi+(X*Vo));
 Nao2:=X*Nai2;
 if ((Clo2<0)or(Cli3<0)or(Wo2<0)or(Wi2<0)or(Ki2<0)or(Ko2<0)or(Nai2<0)or(Nao2<0)) then SprawdzWartosci:=false
 else SprawdzWartosci:=true;
end;

procedure BialkoLicz(T1,Vi,Vo,b:double;var cCli,cClo,cNai,cNao,cKi,cKo,E:double);
{kolejno: temperatura,obj in,obj out,stężenia,potencjal}
var
  Wi,Wo:real;       {te wszystkie zmienne są potrzebne do tego, by wyliczyć z ukladu rownan bialka}
  K,Na,Cl,W:real;
  Cli2,Clo2,Nai2,Nao2,Ki2,Ko2,Wi2,Wo2:real;
  A,B2,C:real;
  X,delta:real;
  pr1,pr2:real;
begin
  Vi:=Vi*1e12;
  Vo:=Vo*1e12;
  Wi:=cKi+cNai;
  Wo:=cKo+cNao;
  Cl:=(cCli*Vi)+(cClo*Vo);
  Na:=(cNai*Vi)+(cNao*Vo);
  K:=(cKi*Vi)+(cKo*Vo);
  W:=(Wi*Vi)+(Wo*Vo);
  A:=(Vi*Vi)-(Vo*Vo);
  B2:=(b*((Vi*Vi)-(Vo*Vo)))-(Vi*(W+Cl));
  C:=Cl*(W-(b*Vi));
  delta:=(B2*B2)-(4*A*C);
  if A<0 then
  begin
   if b<=Wi+((Vo/Vi)*Wo) then
   Cli2:=(-B2-sqrt(delta))/(2*A)
   else
   begin
    pr1:=(-B2+sqrt(delta))/(2*A);
    pr2:=(-B2-sqrt(delta))/(2*A);
    if SprawdzWartosci(pr1,Cl,Vi,Vo,W,b,K,Na)=false then
     Cli2:=pr2
    else
     Cli2:=pr1;
   end
  end
  else if ((A>0) and (C<=0)) then
  Cli2:=(-B2+sqrt(delta))/(2*A)
  else if ((A>0) and (C>0)) then
    begin
    pr1:=(-B2+sqrt(delta))/(2*A);
    pr2:=(-B2-sqrt(delta))/(2*A);
    if SprawdzWartosci(pr1,Cl,Vi,Vo,W,b,K,Na)=false then
     Cli2:=pr2
    else
     Cli2:=pr1;
    end
  else Cli2:=-C/B2;
  Clo2:=(Cl-(Cli2*Vi))/Vo;
  Wo2:=(W-(Cli2*Vi)-(b*Vi))/Vo;
  Wi2:=b+Cli2;
  X:=Wo2/Wi2;
  Ki2:=K/(Vi+(X*Vo));
  Ko2:=X*Ki2;
  Nai2:=Na/(Vi+(X*Vo));
  Nao2:=X*Nai2;
  E:=(R*T1/F)*ln(Wo2/Wi2);
  cCli:=Cli2;cClo:=Clo2;
  cNai:=Nai2;cNao:=Nao2;
  cKi:=Ki2;cKo:=Ko2;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  E : double; {potencjal}
  Eghk : double;{potencjal ghk}
  Eghk2:double; {potencjal ghk II}
  E_III,E_IV,E_V:double; {potencjaly dr Zielinskiego}
  zatrz,bialko,koncowy,nieczysc,osm,wkonc,warunek:boolean; {zatrzymuję pompę czy nie?/uwzgledniam bialka czy nie?}
  PNa,PK,PCl:double; {przepuszczalnosc blony dla Na i K i Cl}
  t,wNa,wK:double;    {czas dzialania pompy;waga jonów Na;waga jonów K}
  ileK,ileNa:shortint;   {co pompujemy}
  ENa,EK,ECl:double;      {Nernst}
  cKi,cNai,cKo,cNao,cCli,cClo:double;  {stężenia jonów}
  T1:double;        {temperatura}
  qNa,qK,qCl,qH2O:double;     {przewodnosci}
  k1:double;          {stala pompy}
  dt,tmax,tzat:double;  {odstęp czasowy;czas dzialania pompy;po jakim czasie stop}
  V,Vecm:double;    {objetosci komorki/ecm}
  iNa,iK,iPompa,iCl,wkoncI:double; {prady}
  iPompa0:double; {prad pompy jalowej}
  C,eps,S,d:double; {do liczenia pojemnosci}
  bialkoi,bialkoo:double; {stezenia bialek}
  ladunekbialka, ladunekbialka2:double;{ladunek mola bialek (w Eq)}
  cisnosm,fH2O,dV,osmIN,osmOUT:double; {różnica w cisnieniach osmotycznych,przeplyw wody,dV obj. kom.}
  obrot,ktory:integer;
  przysp:double; {do przyspieszenia dzialania programu}
  ocNa,ocK,ocCl,ocB:double; {'osmotic coefficient' dla Na,K,Cl i bialek}
  cowyswietlac:array[1..20]of boolean;
  listaplikow:array[1..20]of string;
  plik:Textfile;
  i,j:integer;
begin
  listaplikow[1]:='NaOUT.txt';        {uzupelniamy liste plikow do ktorych zapisujemy wyniki}
  listaplikow[2]:='NaIN.txt';
  listaplikow[3]:='KOUT.txt';
  listaplikow[4]:='KIN.txt';
  listaplikow[5]:='ClOUT.txt';
  listaplikow[6]:='ClIN.txt';
  listaplikow[7]:='GHKI.txt';
  listaplikow[8]:='GHKII.txt';
  listaplikow[9]:='potencjal.txt';
  listaplikow[10]:='iPompa.txt';
  listaplikow[11]:='iNa.txt';
  listaplikow[12]:='iK.txt';
  listaplikow[13]:='iCl.txt';
  listaplikow[14]:='OsmIN.txt';
  listaplikow[15]:='OsmOUT.txt';
  listaplikow[16]:='flowWody.txt';
  listaplikow[17]:='ObjetoscKomorki.txt';
  listaplikow[18]:='Potencjal_III.txt';
  listaplikow[19]:='Potencjal_IV.txt';
  listaplikow[20]:='Potencjal_V.txt';
  nieczysc:=Form2.CheckBox4.Checked;
  if nieczysc = false then   {Gdy użytkownik chce wyczyscic pola przed uzyciem}
   begin
   {czyszczenie pól tekstowych} obrot:=0;
   Form3.Memo12.Lines.Clear;
   Form3.Memo13.Lines.Clear;
   Form3.Memo14.Lines.Clear;                 {czyscimy wszystkie pola z wynikami !!!}
   Form3.Memo11.Lines.Clear;
   Form3.Memo1.Lines.Clear;
   Form3.Memo2.Lines.Clear;
   Form3.Memo3.Lines.Clear;
   Form3.Memo4.Lines.Clear;
   Form3.Memo5.Lines.Clear;
   Form3.Memo6.Lines.Clear;
   Form3.Memo7.Lines.Clear;
   Form3.Memo8.Lines.Clear;
   Form3.Memo9.Lines.Clear;
   Form3.Memo10.Lines.Clear;
   Form3.Memo15.Lines.Clear;
   Form3.Memo16.Lines.Clear;
   Form3.Memo17.Lines.Clear;
   Form3.Memo18.Lines.Clear;
   Form3.Memo19.Lines.Clear;
   Form3.Memo20.Lines.Clear;
   Form3.Memo21.Lines.Clear;
   Form3.Edit2.Text:='0';
   Form3.Edit3.Text:='';
   Form3.Edit4.Text:='';
   Form3.Edit5.Text:='';
   Form3.Edit6.Text:='';
   Form3.Edit7.Text:='';
   Form3.Edit8.Text:='';
   Form3.Edit9.Text:='';
   Form3.Edit10.Text:='';
   Form3.Edit11.Text:='';
   Form3.Edit12.Text:='';
   form3.Edit16.text:='';
   form3.Edit17.text:='';
   form3.edit13.text:='0';
   end;
  Label1.caption:='ITERATIONS';

  {pobieranie danych}
  cowyswietlac[1]:=form2.checkbox5.checked;         {co wyswietlac-ktore wyniki ?}
  cowyswietlac[2]:=form2.checkbox6.checked;          {na podstawie zaznaczen z okienka 'parametry'}
  cowyswietlac[3]:=form2.checkbox7.checked;
  cowyswietlac[4]:=form2.checkbox8.checked;
  cowyswietlac[5]:=form2.checkbox9.checked;
  cowyswietlac[6]:=form2.checkbox10.checked;
  cowyswietlac[7]:=form2.checkbox11.checked;
  cowyswietlac[8]:=form2.checkbox12.checked;
  cowyswietlac[9]:=form2.checkbox13.checked;
  cowyswietlac[10]:=form2.checkbox17.checked;
  cowyswietlac[11]:=form2.checkbox14.checked;
  cowyswietlac[12]:=form2.checkbox16.checked;
  cowyswietlac[13]:=form2.checkbox15.checked;
  cowyswietlac[14]:=form2.checkbox20.checked;
  cowyswietlac[15]:=form2.checkbox21.checked;
  cowyswietlac[16]:=form2.checkbox22.checked;
  cowyswietlac[17]:=form2.checkbox23.checked;
  cowyswietlac[18]:=form2.checkbox24.checked;
  cowyswietlac[19]:=form2.checkbox25.checked;
  cowyswietlac[20]:=form2.checkbox26.checked;
  {impermeant anions}
  bialko:=form2.CheckBox2.checked;                 {czy bialka uwzgledniamy}
  bialkoi:=strtofloat(form2.Edit28.Text);
  bialkoo:=strtofloat(form2.edit36.text);
  ladunekbialka:=strtofloat(form2.Edit30.text); {mEq/mol bialek}
  ladunekbialka2:=strtofloat(form2.Edit38.text);
  {dla równania G-H-K}
  PCl:=strtofloat(form2.Edit27.Text)*1e-2;
  PNa:=strtofloat(form2.Edit6.Text)*1e-2;  {m/s}
  PK:=strtofloat(form2.Edit7.Text)*1e-2;
  {parametry pompy}
  zatrz:=Form2.CheckBox1.Checked;         {true/false}
  ileK:=strtoint(Form2.Edit1.Text);          {liczba}
  ileNa:=strtoint(Form2.Edit2.Text);         {liczba}
  k1:=strtofloat(Form2.Edit3.Text);           {pA/pF}
  wNa:=strtofloat(Form2.Edit14.Text);            {liczba}
  wK:=strtofloat(Form2.Edit15.Text);
  {jony-parametry}
  qCl:=strtofloat(Form2.Edit8.Text);
  qNa:=strtofloat(Form2.Edit4.Text);            {mSi/uF}
  qK:=strtofloat(Form2.Edit5.Text);
  cCli:=strtofloat(Form2.Edit24.Text);
  cClo:=strtofloat(Form2.Edit25.Text);
  cNao:=strtofloat(Form2.Edit12.Text);           {mmol/l}     {BARDZO WAZNE}
  cKi:=strtofloat(Form2.Edit18.Text);
  cNai:=strtofloat(Form2.Edit19.Text);
  cKo:=strtofloat(Form2.Edit20.Text);
  {pozostale parametry}
  T1:=strtofloat(Form2.Edit9.Text);               {K}
  dt:=strtofloat(Form2.Edit10.Text)*1e-3;           {s}
  V:=strtofloat(Form2.Edit11.Text)*1e-6;           {l}
  tmax := strtofloat(Form2.Edit13.Text)*1e-3;       {s}
  Vecm:=strtofloat(Form2.Edit16.Text)*1e-6;     {l}
  tzat:=strtofloat(Form2.Edit17.Text)*1e-3;     {s}
  {kondensator}
  eps:=strtofloat(Form2.Edit21.text);         {F/m}
  d:=strtofloat(Form2.edit22.text);           {nm}
  S:=strtofloat(Form2.edit23.text);         {mm^2}
  {wywalanie wynikow}
  ktory:=strtoint(form2.Edit26.Text);
  koncowy:=form2.checkbox3.checked;
  {osmolarnosci}
  qH2O:=strtofloat(form2.Edit29.Text);      {l/(N*s)}             {z artykulu !}
  ocNa:=strtofloat(form2.Edit31.Text);   {osmotic coefficients,liczby}
  ocK:=strtofloat(form2.Edit32.Text);
  ocCl:=strtofloat(form2.Edit33.Text);
  ocB:=strtofloat(form2.Edit35.Text);
  osm:=not form2.checkbox18.checked;
  if osm = false then cowyswietlac[16]:=false;
  cowyswietlac[19]:=false;
  {warunek kończący}
  wkonc:=form2.checkbox19.checked;
  wkoncI:=strtofloat(form2.edit37.text);

  obrot:=0;
  {koniec pobierania danych}

  (*PODSTAWOWE PARAMETRY*)
  E:=0.0;
  iK:=0;iPompa:=0;iNa:=0;iCl:=0;fH2O:=0;
  t:=0;
  C:=((eps*EPS0*S)/d)*(1e9);       {(F/m)*(mm2)/(nm)=(F/1e3mm)*(mm2)/(1e-6mm)=F*1e3 - więc mnożę przez 1e9 i mam mikrofarady}

  form3.edit13.text:=floattostr(C);    {pojemnosc na ekran wyrzucamy !}
  przysp:=C*dt/F;                     {przyspieszacz programu}

  (*ZACZYNAMY DZIALANIE*)
  if Nastepny = false then    {w momencie, gdy startujemy od SAMEGO POCZATKU}
   begin

   Form3.Edit15.Text:=Form2.Edit11.Text;       {wyswietlanie POCZATKOWEJ objetosci komorki - ZAWSZE na START-aby mozna bylo procent policzyc}

   if bialko=false then                            {jak nie uwzględniamy bialek to zerujemy ich ilosc}
   begin
   bialkoi:=0.0;
   bialkoo:=0.0;
   ladunekbialka:=0.0;
   ladunekbialka2:=0.0;
   end;

   //równowagi ladunku po obu stronach - warto sprawdzić na samym poczatku
   if bialko=true then                                  {gdy mamy bialka}
    begin

    if ((ladunekbialka+cCli)<>(cNai+cKi)) or ((cNao+cKo)<>(cClo+ladunekbialka2)) then      {Sprawdzamy równowagę jonów}
     begin
     ShowMessage('There must not be unbalanced charge on either side of the membrane !');
     exit;
     end

    end

   else                                   {gdy nie ma bialek}
    begin

    if ((cCli<>cKi+cNai)or(cClo<>cKo+cNao)) then      {Sprawdzamy równowagę jonów}
      begin
      ShowMessage('There must not be unbalanced charge on either side of the membrane !');
      exit;
      end
    //równowagi sprawdzone - można zaczynać !

    end;

   {ZERUJEMY PLIKI Z DANYMI OSTATNIEGO DOSWIADCZENIA}
   for i:=1 to 20 do
    if cowyswietlac[i] = true then
    begin
     AssignFile(plik,listaplikow[i]);
     rewrite(plik);
     CloseFile(plik);
    end;

   {CZYSZCZENIE PÓL}
   Form3.Memo12.Lines.Clear;
   Form3.Memo13.Lines.Clear;
   Form3.Memo14.Lines.Clear;
   Form3.Memo11.Lines.Clear;
   Form3.Memo1.Lines.Clear;
   Form3.Memo2.Lines.Clear;
   Form3.Memo3.Lines.Clear;
   Form3.Memo4.Lines.Clear;
   Form3.Memo5.Lines.Clear;
   Form3.Memo6.Lines.Clear;
   Form3.Memo7.Lines.Clear;
   Form3.Memo8.Lines.Clear;
   Form3.Memo9.Lines.Clear;
   Form3.Memo10.Lines.Clear;
   Form3.Memo15.Lines.Clear;
   Form3.Memo16.Lines.Clear;
   Form3.Memo17.Lines.Clear;
   Form3.Memo18.Lines.Clear;
   Form3.Memo19.Lines.Clear;
   Form3.Memo20.Lines.Clear;
   Form3.Memo21.Lines.Clear;
   Form3.Edit2.Text:='0';
   Form3.Edit3.Text:='';
   Form3.Edit4.Text:='';
   Form3.Edit5.Text:='';
   Form3.Edit6.Text:='';
   Form3.Edit7.Text:='';
   Form3.Edit8.Text:='';
   Form3.Edit9.Text:='';
   Form3.Edit10.Text:='';
   Form3.Edit11.Text:='';
   Form3.Edit12.Text:='';
   form3.Edit16.text:='';
   form3.Edit17.text:='';
   form3.edit13.text:='0';

   {JAK BIALKA SA-START}
   if bialko=true then     {Jesli ktos chce uwzgledniac bialka}
    begin
    BialkoLicz(T1,V,Vecm,ladunekbialka,cCli,cClo,cNai,cNao,cKi,cKo,E);
    ECl:=(R*T1/F)*ln(cCli/cClo); {V}
    ENa:=(R*T1/F)*ln(cNao/cNai);  {V}
    EK:=(R*T1/F)*ln(cKo/cKi);    {V}
    Eghk:=(R*T1/F)*ln(((PNa*cNao)+(PK*cKo)+(PCl*cCli))/((PNa*cNai)+(PK*cKi)+(PCl*cClo)));
    Eghk2:=((qK*EK)+(qNa*ENa)+(qCl*ECl))/(qK+qCl+qNa);
    E_III:=((qK*EK)+((2/3)*qNa*ENa))/(qK+((2/3)*qNa));
    E_V:=(R*T1/F)*ln((((2/3)*PNa*cNao)+(PK*cKo))/(((2/3)*PNa*cNai)+(PK*cKi)));
    Form3.Edit2.Text:=floattostrf(E,ffGeneral,7,7);  {wyrzucamy potencjal G-D}
    form3.edit3.text:=floattostr(cNai);               {wyswietlamy stezenia - rzeczywiste poczatkowe w chwili '0'}
    form3.Edit4.text:=floattostr(cKi);
    form3.edit5.text:=floattostr(cCli);
    form3.edit6.text:=floattostr(cNao);
    form3.edit7.text:=floattostr(cKo);
    form3.edit8.text:=floattostr(cClo);
    form3.edit9.text:=floattostrf(cNai+cKi+cCli+bialkoi,ffGeneral,4,4);     {tu wyswietlamy te pola w zbiorze wynikow zatytulowanych}
    form3.edit10.text:=floattostrf(cNao+cKo+cClo,ffGeneral,4,4);           {rownowaga Gibbsa-Donnana}
    form3.edit11.text:=floattostrf(cNai+cKi-cCli-bialkoi,ffGeneral,4,4);       {typu suma stezen wszystkiech IN i OUT i inne}
    form3.edit12.text:=floattostrf(cNao+cKo-cClo,ffGeneral,4,4);
    if abs(strtofloat(form3.edit12.text)) < 1e-12 then            {bo program jest niemadry i wyrzuca absurdalny wynik...}
     form3.edit12.text:='0';                                        {...rzedu 1e-15, ktory jest zwyklym bledem}
    if abs(strtofloat(form3.edit11.text)) < 1e-12 then                  {dlatego równamy do zera wszystko co jest mniejsze od 1e-12}
     form3.edit11.text:='0';
    OsmIN:=(ocNa*cNai)+(ocK*cKi)+(ocCl*cCli)+(ocB*bialkoi);
    OsmOUT:=(ocNa*cNao)+(ocK*cKo)+(ocCl*cClo)+(ocB*bialkoo);
    end
   {JAK BIALKA SA-KONIEC}

   (*JAK NIE MA BIALEK-START*)
   else                    {Jesli ktos nie chce bialek uwzgledniac...}
     begin
     E:=0;                  {...to zaczynamy od zerowego potencjalu}
     OsmIN:=(ocNa*cNai)+(ocK*cKi)+(ocCl*cCli);
     OsmOUT:=(ocNa*cNao)+(ocK*cKo)+(ocCl*cClo);
     ECl:=(R*T1/F)*ln(cCli/cClo); {V}
     ENa:=(R*T1/F)*ln(cNao/cNai);  {V}
     EK:=(R*T1/F)*ln(cKo/cKi);    {V}
     Eghk:=(R*T1/F)*ln(((PNa*cNao)+(PK*cKo)+(PCl*cCli))/((PNa*cNai)+(PK*cKi)+(PCl*cClo)));
     Eghk2:=((qK*EK)+(qNa*ENa)+(qCl*ECl))/(qK+qCl+qNa);
     E_III:=((qK*EK)+((2/3)*qNa*ENa))/(qK+((2/3)*qNa));
     E_V:=(R*T1/F)*ln((((2/3)*PNa*cNao)+(PK*cKo))/(((2/3)*PNa*cNai)+(PK*cKi)));
     end;
   (*JAK NIE MA BIALEK-KONIEC*)

   iK:=0;iPompa:=0;iNa:=0;iCl:=0;fH2O:=0;   {ciąg dalszy - Nastepny=false, a zatem ZACZYNAMY OD POCZATKU, OD ZERA}

   end

  {ODTWARZAMY PARAMETRY OSTATNIEGO UKLADU - JUZ NIE ZACZYNAMY OD ZERA}
  else
   begin                    {Nalezy odtworzyc parametry ostatniego ukladu}
   E:=strtofloat(form2.Edit34.text);
   ECl:=(R*T1/F)*ln(cCli/cClo); {V}
   ENa:=(R*T1/F)*ln(cNao/cNai);  {V}
   EK:=(R*T1/F)*ln(cKo/cKi);    {V}
   Eghk:=(R*T1/F)*ln(((PNa*cNao)+(PK*cKo)+(PCl*cCli))/((PNa*cNai)+(PK*cKi)+(PCl*cClo)));
   Eghk2:=((qK*EK)+(qNa*ENa)+(qCl*ECl))/(qK+qCl+qNa);
   E_III:=((qK*EK)+((2/3)*qNa*ENa))/(qK+((2/3)*qNa));
   E_V:=(R*T1/F)*ln((((2/3)*PNa*cNao)+(PK*cKo))/(((2/3)*PNa*cNai)+(PK*cKi)));
   iNa:=qNa*(E-ENa);      {(mSi/uF)*V=mA/uF}
   iK:=qK*(E-EK);
   iCl:=qCl*(E-ECl);
   iPompa0:=k1*cKo*(cNai/((cKo + (1/wK))*(cNai + (1/wNa))))*(1e-3);  {pompa jalowa}
   iPompa:=(-1)*(-ileNa+ileK)*iPompa0;   {pA/pF*1e-3 = nA/pF = mA/uF}
   OsmIN:=(ocNa*cNai)+(ocK*cKi)+(ocCl*cCli)+(ocB*bialkoi);
   OsmOUT:=(ocNa*cNao)+(ocK*cKo)+(ocCl*cClo)+(ocB*bialkoo);
   if osm=true then
    begin
    cisnosm:=R*T1*((ocNa*(cNai-cNao))+(ocK*(cKi-cKo))+(ocCl*(cCli-cClo))+(ocB*(bialkoi-bialkoo))); {równanie van't Hoffa, Pa, usprawnione o osmotic coefficient}
    {1000 dodany wyżej, gdyż równ. vant Hoffa daje kPa w wyniku}
    fH2O:=qH2O*cisnosm*(S);    {1e6 dodane bo qH20 ma l w jednostce, 1e-6 dodane bo S ma byc w m2, więc redukuje się samo}              {ul/s}
    end
   end;


  (*START PETLI*)

  warunek:=true;
  while warunek=true do
   begin
   if ((zatrz=true)and(t>=tzat)) then  {jak chcemy zatrzymac pompe, a czas przekracza czas zatrzymania}
    begin

    if ((koncowy=false) and (obrot mod ktory=0)) then {wywalamy wyniki}
    begin
     for i:=1 to 20 do
      if cowyswietlac[i]=true then
      case i of
      9:Form3.Memo1.Lines.Add(floattostr(E));
      1:Form3.Memo2.Lines.Add(floattostr(cNao));
      2:Form3.Memo3.Lines.Add(floattostr(cNai));
      3:Form3.Memo4.Lines.Add(floattostr(cKo));
      4:Form3.Memo5.Lines.Add(floattostr(cKi));
      11:Form3.Memo6.Lines.Add(floattostr(iNa*C));
      12:Form3.Memo7.Lines.Add(floattostr(iK*C));
      10:Form3.Memo8.Lines.Add(floattostr(iPompa*C));
      7:Form3.Memo10.Lines.Add(floattostr(Eghk));
      8:Form3.Memo11.Lines.Add(floattostr(Eghk2));
      5:Form3.Memo12.Lines.Add(floattostr(cClo));
      6:Form3.Memo13.Lines.Add(floattostr(cCli));
      13:Form3.Memo14.Lines.Add(floattostr(iCl*C));
      14:Form3.Memo14.Lines.Add(floattostr(OsmIN));
      15:Form3.Memo14.Lines.Add(floattostr(OsmOUT));
      16:Form3.Memo14.Lines.Add(floattostr(fH2O));
      17:Form3.Memo14.Lines.Add(floattostr(V));
      18:Form3.Memo19.Lines.Add(floattostr(E_III));
      19:Form3.Memo20.Lines.Add(floattostr(E_IV));
      20:Form3.Memo21.Lines.Add(floattostr(E_V));
      end;
     Form3.Edit1.Text:=floattostr(V*1e6);
     Form3.Edit14.Text:=floattostr(Vecm*1e6);
     Form3.Label41.Caption:=floattostrf(((V*1e6)/strtofloat(form3.edit15.text))*100,ffGeneral,4,4)+' % początkowej objętosci';
     Form3.edit18.text:=floattostr(bialkoi);
    end;

    Inc(obrot);
    Label1.caption:=inttostr(obrot);
    Form1.Refresh;

    if osm=true then
    begin
    cisnosm:=R*T1*((ocNa*(cNai-cNao))+(ocK*(cKi-cKo))+(ocCl*(cCli-cClo))+(ocB*(bialkoi-bialkoo))); {równanie van't Hoffa, Pa, usprawnione o osmotic coefficient}
    {1000 dodany wyżej, gdyż równ. vant Hoffa daje kPa w wyniku}
    fH2O:=qH2O*cisnosm*(S);    {1e6 dodane bo qH20 ma l w jednostce, 1e-6 dodane bo S ma byc w m2, więc redukuje się samo}              {ul/s}
    dV:=fH2O*dt*1e-6;      {l}
    end
    else
    dV:=0.0;

    ENa:=(R*T1/F)*ln(cNao/cNai);           {Nernst}
    EK:=(R*T1/F)*ln(cKo/cKi);              {V}
    ECl:=(R*T1/F)*ln(cCli/cClo);
    Eghk:=(R*T1/F)*ln(((PNa*cNao)+(PK*cKo)+(PCl*cCli))/((PNa*cNai)+(PK*cKi)+(PCl*cClo)));    {GHK}
    Eghk2:=((qK*EK)+(qNa*ENa)+(qCl*ECl))/(qK+qCl+qNa);
    E_III:=((qK*EK)+((2/3)*qNa*ENa))/(qK+((2/3)*qNa));
    E_V:=(R*T1/F)*ln((((2/3)*PNa*cNao)+(PK*cKo))/(((2/3)*PNa*cNai)+(PK*cKi)));

    iNa:=qNa*(E-ENa);                       {prady z kanalow Na i K}
    iK:=qK*(E-EK);
    iCl:=qCl*(E-ECl);
    iPompa0:=0;                                {nie ma pompy !!!}
    iPompa:=0;               {nieistotna linijka}

    E:=E+(-1)*((iNa+iK+iPompa+iCl)*dt)*(1e3);            {liczymy potencjal}
     {(mA/uF)*s = mAs/uF = mC/uF. Mnożę przez 1e3 czyli mam uC/uF=C/F= V}
    cNai:=((cNai*V)+(przysp*((-ileNa*iPompa0)-iNa)))/(V+dV);
    cNao:=((cNao*Vecm)-(przysp*((-ileNa*iPompa0)-iNa)))/(Vecm-dV);
    cKi:=((cKi*V)+(przysp*((iPompa0*ileK)-iK)))/(V+dV);
    cKo:=((cKo*Vecm)-(przysp*((iPompa0*ileK)-iK)))/(Vecm-dV);
    cCli:=((cCli*V)+(iCl*przysp))/(V+dV);
    cClo:=((cClo*Vecm)-(iCl*przysp))/(Vecm-dV);
    bialkoi:=(bialkoi*V)/(V+dV);
    bialkoo:=(bialkoo*Vecm)/(Vecm-dV);
    ladunekbialka:=(ladunekbialka*V)/(V+dV);
    ladunekbialka2:=(ladunekbialka2*Vecm)/(Vecm-dV);
    OsmIN:=(ocNa*cNai)+(ocK*cKi)+(ocCl*cCli)+(ocB*bialkoi);
    OsmOUT:=(ocNa*cNao)+(ocK*cKo)+(ocCl*cClo)+(ocB*bialkoo);

    end

   else                                         {jesli nie chcemy zatrzymywac pompy}
   (*A TERAZ GDY NIE ZATRZYMUJEMY POMPY ALBO JESTESMY PRZED JEJ ZATRZYMANIEM*)
    begin
    if ((koncowy=false) and (obrot mod ktory=0)) then {wywalamy wyniki}
    begin
     for i:=1 to 20 do
      if cowyswietlac[i]=true then
      case i of
      9:Form3.Memo1.Lines.Add(floattostr(E));
      1:Form3.Memo2.Lines.Add(floattostr(cNao));
      2:Form3.Memo3.Lines.Add(floattostr(cNai));
      3:Form3.Memo4.Lines.Add(floattostr(cKo));
      4:Form3.Memo5.Lines.Add(floattostr(cKi));
      11:Form3.Memo6.Lines.Add(floattostr(iNa*C));
      12:Form3.Memo7.Lines.Add(floattostr(iK*C));
      10:Form3.Memo8.Lines.Add(floattostr(iPompa*C));
      7:Form3.Memo10.Lines.Add(floattostr(Eghk));
      8:Form3.Memo11.Lines.Add(floattostr(Eghk2));
      5:Form3.Memo12.Lines.Add(floattostr(cClo));
      6:Form3.Memo13.Lines.Add(floattostr(cCli));
      13:Form3.Memo14.Lines.Add(floattostr(iCl*C));
      14:Form3.Memo15.Lines.Add(floattostr(OsmIN));
      15:Form3.Memo16.Lines.Add(floattostr(OsmOUT));
      16:Form3.Memo17.Lines.Add(floattostr(fH2O));
      17:Form3.Memo18.Lines.Add(floattostr(V));
      18:Form3.Memo19.Lines.Add(floattostr(E_III));
      19:Form3.Memo20.Lines.Add(floattostr(E_IV));
      20:Form3.Memo21.Lines.Add(floattostr(E_V));
      end;
     Form3.Edit1.Text:=floattostr(V*1e6);
     Form3.Edit14.Text:=floattostr(Vecm*1e6);
     Form3.Label41.Caption:=floattostrf(((V*1e6)/strtofloat(form3.edit15.text))*100,ffGeneral,4,4)+' % początkowej objętosci';
     Form3.edit18.text:=floattostr(bialkoi);
    end;

    Inc(obrot);
    Label1.Caption := inttostr(obrot);
    Form1.Refresh;

    if osm=true then
    begin
    cisnosm:=R*T1*((ocNa*(cNai-cNao))+(ocK*(cKi-cKo))+(ocCl*(cCli-cClo))+(ocB*(bialkoi-bialkoo))); {równanie van't Hoffa, Pa}
    fH2O:=qH2O*cisnosm*S;                  {ul/s}
    dV:=fH2O*dt*1e-6;                    {l}
    end
    else
    dV:=0.0;

    ENa:=(R*T1/F)*ln(cNao/cNai);
    EK:=(R*T1/F)*ln(cKo/cKi);
    ECl:=(R*T1/F)*ln(cCli/cClo);
    Eghk:=(R*T1/F)*ln(((PNa*cNao)+(PK*cKo)+(PCl*cCli))/((PNa*cNai)+(PK*cKi)+(PCl*cClo)));
    Eghk2:=((qK*EK)+(qNa*ENa)+(qCl*ECl))/(qK+qCl+qNa);
    E_III:=((qK*EK)+((2/3)*qNa*ENa))/(qK+((2/3)*qNa));
    E_V:=(R*T1/F)*ln((((2/3)*PNa*cNao)+(PK*cKo))/(((2/3)*PNa*cNai)+(PK*cKi)));

    iNa:=qNa*(E-ENa);
    iK:=qK*(E-EK);
    iCl:=qCl*(E-ECl);
    iPompa0:=k1*cKo*cNai/((cKo + (1/wK))*(cNai + (1/wNa)))*(1e-3);      {pompa jalowa}
    iPompa:=(-1)*(-ileNa+ileK)*iPompa0;

    E:=E+((-1)*((iNa+iK+iCl+iPompa)*dt)*(1e3));

    cNai:=((cNai*V)+(przysp*((-ileNa*iPompa0)-iNa)))/(V+dV);
    cNao:=((cNao*Vecm)-(przysp*((-ileNa*iPompa0)-iNa)))/(Vecm-dV);
    cKi:=((cKi*V)+(przysp*((iPompa0*ileK)-iK)))/(V+dV);
    cKo:=((cKo*Vecm)-(przysp*((iPompa0*ileK)-iK)))/(Vecm-dV);
    cCli:=((cCli*V)+(iCl*przysp))/(V+dV);
    cClo:=((cClo*Vecm)-(iCl*przysp))/(Vecm-dV);
    bialkoi:=(bialkoi*V)/(V+dV);
    bialkoo:=(bialkoo*Vecm)/(Vecm-dV);
    ladunekbialka:=(ladunekbialka*V)/(V+dV);
    ladunekbialka2:=(ladunekbialka2*Vecm)/(Vecm-dV);
    OsmIN:=(ocNa*cNai)+(ocK*cKi)+(ocCl*cCli)+(ocB*bialkoi);
    OsmOUT:=(ocNa*cNao)+(ocK*cKo)+(ocCl*cClo)+(ocB*bialkoo);

    end;

   t:=t+dt;      {aktualizacja czasu}
   V:=V+dV;         {aktualizacja objetosci}
   Vecm:=Vecm-dV;

   if wkonc=true then                     {opcja uczciwego zakończenia doswiadczenia}
    begin
    if (abs((iCl+iNa+iK+iPompa)*C) > wkoncI) then warunek:=true else warunek:=false
    end
   else
    if t<tmax then warunek:=true else warunek:=false;

   end;
  (*KONIEC PETLI*)

  (*WYSWIETLANIE ROWNANIA IV*)
  if ((form2.checkbox25.checked=true) and (osm=true)) then
  begin
  E_IV:=(R*T1/F)*ln(1+((bialkoo-bialkoi+ladunekbialka2-ladunekbialka)/(2*cClo)));
  Form3.Memo20.Lines.Add(floattostr(E_IV));
  cowyswietlac[19]:=true;
  end;

  (*WYSWIETLANIE KOŃCOWYCH WYNIKOW*)
  if koncowy=true then {wywalamy wyniki - tylko przy opcji koncowych wynikow}
    begin
     for i:=1 to 20 do
      if cowyswietlac[i]=true then
      case i of
      9:Form3.Memo1.Lines.Add(floattostr(E));
      1:Form3.Memo2.Lines.Add(floattostr(cNao));
      2:Form3.Memo3.Lines.Add(floattostr(cNai));
      3:Form3.Memo4.Lines.Add(floattostr(cKo));
      4:Form3.Memo5.Lines.Add(floattostr(cKi));
      11:Form3.Memo6.Lines.Add(floattostr(iNa*C));
      12:Form3.Memo7.Lines.Add(floattostr(iK*C));
      10:Form3.Memo8.Lines.Add(floattostr(iPompa*C));
      7:Form3.Memo10.Lines.Add(floattostr(Eghk));
      8:Form3.Memo11.Lines.Add(floattostr(Eghk2));
      5:Form3.Memo12.Lines.Add(floattostr(cClo));
      6:Form3.Memo13.Lines.Add(floattostr(cCli));
      13:Form3.Memo14.Lines.Add(floattostr(iCl*C));
      14:Form3.Memo15.Lines.Add(floattostr(OsmIN));
      15:Form3.Memo16.Lines.Add(floattostr(OsmOUT));
      16:Form3.Memo17.Lines.Add(floattostr(fH2O));
      17:Form3.Memo18.Lines.Add(floattostr(V));
      18:Form3.Memo19.Lines.Add(floattostr(E_III));
      19:Form3.Memo20.Lines.Add(floattostr(E_IV));
      20:Form3.Memo21.Lines.Add(floattostr(E_V));
      end;
     Form3.Edit1.Text:=floattostr(V*1e6);
     Form3.Edit14.Text:=floattostr(Vecm*1e6);
     Form3.Label41.Caption:=floattostrf(((V*1e6)/strtofloat(form3.edit15.text))*100,ffGeneral,4,4)+' % początkowej objętosci';
     Form3.edit18.text:=floattostr(bialkoi);
    end;

  (*KONCOWE USTALENIA*)

  //spisujemy zmienne do kontynuacji
  form2.Edit12.text:=floattostr(cNao);
  form2.Edit19.text:=floattostr(cNai);
  form2.edit20.text:=floattostr(cKo);
  form2.Edit18.text:=floattostr(cKi);
  form2.edit25.text:=floattostr(cClo);
  form2.edit24.text:=floattostr(cCli);
  form2.edit28.text:=floattostr(bialkoi);
  form2.edit36.text:=floattostr(bialkoo);
  form2.edit11.text:=floattostr(V*1e6);
  form2.edit16.text:=floattostr(Vecm*1e6);
  form2.edit34.text:=floattostr(E);
  form2.edit30.text:=floattostr(ladunekbialka);
  form2.edit38.text:=floattostr(ladunekbialka2);
  //koniec spisywania

  //przeliczamy i wyrzucamy osmolarnosci
  form3.edit17.text:=floattostr(cNai+cKi+cCli+bialkoi);
  form3.edit16.text:=floattostr(cNao+cKo+cClo+bialkoo);
  //koniec przeliczania osmolarnosci

  //zapisujemy dane do plików tekstowych
  if nieczysc=false then
   for i:=1 to 20 do
    if cowyswietlac[i] = true then
    begin
     AssignFile(plik,listaplikow[i]);
     Append(plik);
     case i of
     1:for j:=0 to form3.Memo2.lines.count-1 do writeln(plik,form3.Memo2.Lines[j]);
     2:for j:=0 to form3.Memo3.lines.count-1 do writeln(plik,form3.Memo3.Lines[j]);
     3:for j:=0 to form3.Memo4.lines.count-1 do writeln(plik,form3.Memo4.Lines[j]);
     4:for j:=0 to form3.Memo5.lines.count-1 do writeln(plik,form3.Memo5.Lines[j]);
     5:for j:=0 to form3.Memo12.lines.count-1 do writeln(plik,form3.Memo12.Lines[j]);
     6:for j:=0 to form3.Memo13.lines.count-1 do writeln(plik,form3.Memo13.Lines[j]);
     7:for j:=0 to form3.Memo10.lines.count-1 do writeln(plik,form3.Memo10.Lines[j]);
     8:for j:=0 to form3.Memo11.lines.count-1 do writeln(plik,form3.Memo11.Lines[j]);
     9:for j:=0 to form3.Memo1.lines.count-1 do writeln(plik,form3.Memo1.Lines[j]);
     10:for j:=0 to form3.Memo8.lines.count-1 do writeln(plik,form3.Memo8.Lines[j]);
     11:for j:=0 to form3.Memo6.lines.count-1 do writeln(plik,form3.Memo6.Lines[j]);
     12:for j:=0 to form3.Memo7.lines.count-1 do writeln(plik,form3.Memo7.Lines[j]);
     13:for j:=0 to form3.Memo14.lines.count-1 do writeln(plik,form3.Memo14.Lines[j]);
     14:for j:=0 to form3.Memo15.lines.count-1 do writeln(plik,form3.Memo15.Lines[j]);
     15:for j:=0 to form3.Memo16.lines.count-1 do writeln(plik,form3.Memo16.Lines[j]);
     16:for j:=0 to form3.Memo17.lines.count-1 do writeln(plik,form3.Memo17.Lines[j]);
     17:for j:=0 to form3.Memo18.lines.count-1 do writeln(plik,form3.Memo18.Lines[j]);
     18:for j:=0 to form3.Memo19.lines.count-1 do writeln(plik,form3.Memo19.Lines[j]);
     19:for j:=0 to form3.Memo20.lines.count-1 do writeln(plik,form3.Memo20.Lines[j]);
     20:for j:=0 to form3.Memo21.lines.count-1 do writeln(plik,form3.Memo21.Lines[j]);
     end;
     CloseFile(plik);
    end;
  //koniec zapisywania

  Button3.Enabled := true; {umożliwiamy start programu z wczesniejszymi parametrami}
  Nastepny:=false;           {a nuz procedura szla przez kontynuacje i jest true - a ktos konczy doswiadczenie i rozpoczyna kolejne}
  Form3.Show;                {pokazujemy ekran z wynikami}
  end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Nastepny := true;
  Form2.ShowModal;
  Button2Click(sender);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Form3.Show;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Nastepny:=false;
end;

end.

