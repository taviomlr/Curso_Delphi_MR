unit MoveFilesList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils;

type
  TFormMain = class(TForm)
    ButtonMove: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonMoveClick(Sender: TObject);
  private
    { Private declarations }
    procedure MoveFiles(const SourceFolder, DestinationFolder: string);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

//procedure TFormMain.MoveFiles(const SourceFolder, DestinationFolder: string);
procedure TFormMain.MoveFiles(const CaminhoOrigem, NomeArquivo: string);
var
  FileList: TStringList;
  I: Integer;
//  SourcePath, DestinationPath, FileName: string;
  CaminhoDestino: string;
  DiretorioAtual: string;

begin
  DiretorioAtual := GetCurrentDir;
  FileList := TStringList.Create;
  CaminhoOrigem := DiretorioAtual + '\' + CaminhoOrigem;
  try
//    FileList.LoadFromFile('C:\pasta\subpasta1\arquivo.txt');
//    SourcePath := IncludeTrailingPathDelimiter(SourceFolder);
//    DestinationPath := IncludeTrailingPathDelimiter(DestinationFolder);

    FileList.LoadFromFile(SourceFolder + 'arquivo.txt');
//    SourcePath := IncludeTrailingPathDelimiter(SourceFolder);
//    DestinationPath := IncludeTrailingPathDelimiter(DestinationFolder);

    for I := 0 to FileList.Count - 1 do
    begin
      FileName := FileList[I];
      if TFile.Exists(CaminhoOrigem + FileName) then
        TFile.Move(SourcePath + FileName, DestinationPath + FileName);
    end;
  finally
    FileList.Free;
  end;
end;

procedure TFormMain.ButtonMoveClick(Sender: TObject);
var
  ExecutablePath: string;
begin
  ExecutablePath := ExtractFilePath(ParamStr(0));
  MoveFiles(ExecutablePath + '..\subpasta1\', ExecutablePath + 'subpasta2\');
  ShowMessage('Arquivos movidos com sucesso!');
//  MoveFiles('C:\pasta\subpasta1', 'C:\pasta\subpasta2');
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  ButtonMoveClick(nil);
end;

end.

