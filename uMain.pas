unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.DateUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext,
  Vcl.ComCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    HTTPServer: TIdHTTPServer;
    TextFile: TMemo;
    OpenDialog1: TOpenDialog;
    Time: TCheckBox;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HTTPServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

const
  ch = #13+#10;

type
  TMyRecord = record
    idTask: string;  // номер задачи
    uuid:string;       // GUDI подсборки
    task_id: Integer;  // Этап подсборки
    From:   string;  // откуда везти
    to_:    string;  // куда везти
    work_place:string; // G3D G2T G6T для кого задача
    isFromWMS:boolean;
    status: Integer; // статус задачи
    Time:integer;
  end;

var
//  TextFile: TStringList;
  MyRecordArray: array of TMyRecord;
  i: Integer;
  LineValues: TStringList;

Function StrToDateTimeZone(DateTimeStr: string): TDateTime;
var
  Year, Month, Day, Hour, Minute, Second, Millisecond, TimeZone: Word;
begin
  DateTimeStr:=trim(DateTimeStr);
  Year := StrToInt(Copy(DateTimeStr, 1, 4));
  Month := StrToInt(Copy(DateTimeStr, 6, 2));
  Day := StrToInt(Copy(DateTimeStr, 9, 2));
  Hour := StrToInt(Copy(DateTimeStr, 12, 2));
  Minute := StrToInt(Copy(DateTimeStr, 15, 2));
  Second := StrToInt(Copy(DateTimeStr, 18, 2));
  Millisecond := StrToInt(Copy(DateTimeStr, 21, 3));
  TimeZone := StrToInt(Copy(DateTimeStr, 25, 3));

  Result:=EncodeDateTime(Year,Month,Day,Hour,Minute,Second,Millisecond);

end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then exit;

  // Создаем объект для чтения текстового файла
 // TextFile := TStringList.Create;
  LineValues := TStringList.Create;
  try
    // Загружаем содержимое файла в объект
    TextFile.Lines.LoadFromFile(OpenDialog1.FileName);

    // Устанавливаем размер массива равным количеству строк в файле
    SetLength(MyRecordArray, TextFile.Lines.Count - 1); // -1 для исключения строки заголовков

    // Проходим по каждой строке, начиная со второй (индекс 1), так как первая строка - заголовки
    for i := 1 to TextFile.Lines.Count - 1 do
    begin
      // Разбиваем строку на значения с использованием разделителя ';'
      LineValues.Delimiter := ';';
      LineValues.StrictDelimiter := True;
      LineValues.DelimitedText := TextFile.Lines[i];

      // Заполняем поля записи соответствующими значениями из строки
      MyRecordArray[i - 1].idTask     := LineValues[0];
      MyRecordArray[i - 1].uuid       := LineValues[1];
      MyRecordArray[i - 1].task_id    := strtointdef(LineValues[2],0);;
      MyRecordArray[i - 1].From       := LineValues[3];
      MyRecordArray[i - 1].to_        := LineValues[4];
      MyRecordArray[i - 1].work_place := LineValues[5];
      MyRecordArray[i - 1].isFromWMS  := LowerCase(LineValues[6])='true';
      MyRecordArray[i - 1].status     := strtointdef(LineValues[7],0);
      MyRecordArray[i - 1].Time       := strtointdef(LineValues[8],0);
    end;

    // Теперь у вас есть массив MyRecordArray, содержащий записи типа TMyRecord
    // Вы можете использовать его в вашей программе по своему усмотрению
  finally
    // Освобождаем ресурсы
  //  TextFile.Free;
    LineValues.Free;
  end;
end;



procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  HTTPServer.Active := False;
  CanClose:=True;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  // Запускаем сервер
  HTTPServer.Active := True;
 // HTTPServer.Active := False;
  TextFile.Clear;
  with HTTPServer.Bindings.Items[0] do
    Caption:=Caption+' '+IP+':'+IntToStr(Port);
end;

Function Iifbo(bo:boolean):string;
begin
  if bo then
    result:='true'
  else
    Result:='false';

end;

function TaskToJSON(n:integer):AnsiString;
begin
  result:='';
  if n<Low(MyRecordArray) then exit;
  if n>High(MyRecordArray) then exit;

    // '{"idTask": "8b3e8ed9-2606-4476-b19010",
    //   "from": "S1D5C16SL",
    //   "to": "S8D2C10SR",
    //   "status": 1},'+

  result:='  {'+ch;
  result:=result+'    "idTask": "'+   MyRecordArray[n].idTask+'",'+ch;
  result:=result+'    "uuid": "'+    MyRecordArray[n].uuid+'",'+ch;
  result:=result+'    "task_id": "'+ inttostr(MyRecordArray[n].task_id)+'",'+ch;
  result:=result+'    "from": "'+  MyRecordArray[n].From+'",'+ch;
  result:=result+'    "to": "'+   MyRecordArray[n].to_+'",'+ch;
  result:=result+'    "work_place": "'+MyRecordArray[n].work_place+'",'+ch;
  result:=result+'    "isFromWMS": '+Iifbo(MyRecordArray[n].isFromWMS)+','+ch;
  result:=result+'    "status": "'+inttostr(MyRecordArray[n].status)+'"'+ch;
  result:=result+'  }';

end;


Function IIF(bo:boolean;st1,st2:string):string;
begin
  if bo then
    result:=st1
  else
    result:=st2;
end;

procedure TForm2.HTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  i:integer;
begin
  // Устанавливаем заголовки ответа
  AResponseInfo.ContentType := 'application/json';
  AResponseInfo.CharSet := 'utf-8';

  // Отправляем строку с данными
  with AResponseInfo do ContentText := '[';

  for i := Low(MyRecordArray) to High(MyRecordArray) do begin
    with AResponseInfo do
     ContentText := ContentText + iif(i=0,'',',')+#$0D+#$0A+
       TaskToJSON(i);
  end;

  with AResponseInfo do
    ContentText := ContentText+#$0D+#$0A+']';

end;

end.

