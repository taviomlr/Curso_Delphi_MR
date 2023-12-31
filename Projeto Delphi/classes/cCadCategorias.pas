unit cCadCategorias;

interface

uses System.Classes,
     Vcl.Controls,
     Vcl.ExtCtrls,
     Vcl.Dialogs,
     ZAbstractConnection,
     ZConnection,
     ZAbstractRODataset,
     ZAbstractDataset,
     ZDataset,
     SysUtils;

type
  Tcategoria = class
  private
    ConexaoDB: TZConnection;
    F_categoriaId:integer;
    F_descricao:string;
    function getCodigo: integer;
    function getDescricao: string;
    procedure setCodigo(const Value: integer);
    procedure setDescricao(const Value: string);
  public
    constructor Create(aConexao:TZConnection);
    destructor Destroy; override;
    function Inserir:boolean;
    function Atualizar:boolean;
    function Apagar:boolean;
    function Selecionar(id:integer):boolean;

  published
    property codigo:integer   read getCodigo    write setCodigo;
    property descricao:string read getDescricao write setDescricao;


  end;

implementation

{ Tcategoria }

{$region 'Constructor e Destructor'}
constructor Tcategoria.Create(aConexao:TZConnection);
begin
  ConexaoDB :=  aConexao;
end;

destructor Tcategoria.Destroy;
begin

  inherited;
end;
{$endregion}

{$region 'CRUD'}
function Tcategoria.Apagar: boolean;
var
  Qry:TZQuery;
begin
  if MessageDlg('Deseja apagar o registro: '+#13+#13+
                'C�digo: '+IntToStr(F_categoriaId)+#13+
                'Descri��o: '+F_descricao,TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],0)=mrNo then
  begin
    Result := false;
    Abort;
  end;

  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM categorias '+
                ' WHERE categoriaId = :categoriaId ');
    Qry.ParamByName('categoriaId').AsInteger := F_categoriaId;
    try
      Qry.ExecSQL;
    except
      Result := false;
    end;

  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;

function Tcategoria.Atualizar: boolean;
var
  Qry:TZQuery;
begin
  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('UPDATE categorias '+
                '   SET descricao = :descricao '+
                ' WHERE categoriaId = :categoriaId ');
    Qry.ParamByName('categoriaId').AsInteger := self.F_categoriaId;
    Qry.ParamByName('descricao').AsString := self.F_descricao;
    try
      Qry.ExecSQL;
    except
      Result := false;
    end;

  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;

function Tcategoria.Inserir: boolean;
var
  Qry:TZQuery;
begin
  //ShowMessage('Gravado');
  //Result := false;
  //ShowMessage(self.F_descricao); FORMA DE TESTAR SE A CLASSE EST� FUNCIONANDO
  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('INSERT INTO categorias (descricao) values (:descricao)');
    //Qry.ParamByName('descricao').Value := self.F_descricao;
    Qry.ParamByName('descricao').AsString := self.F_descricao;
    try
      Qry.ExecSQL;
    except
      Result := false;
    end;

  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);

  end;
end;

function Tcategoria.Selecionar(id: integer): boolean;
var
  Qry:TZQuery;
begin
  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT categoriaId, '+
                '       descricao '+
                '  FROM categorias '+
                ' WHERE categoriaId = :categoriaId');
    //Qry.ParamByName('categoriaId').Value := id;
    Qry.ParamByName('categoriaId').AsInteger := id;
    try
      Qry.Open;
      Self.F_categoriaId := Qry.FieldByName('categoriaId').AsInteger;
      Self.F_descricao   := Qry.FieldByName('descricao').AsString;
    except
      Result := false;
    end;
  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);
  end;

end;
{$endregion}

{$region 'Gets'}
function Tcategoria.getCodigo: integer;
begin
  Result := Self.F_categoriaId;
end;

function Tcategoria.getDescricao: string;
begin
  Result := Self.F_descricao;
end;
{$endregion}

{$region 'Sets'}
procedure Tcategoria.setCodigo(const Value: integer);
begin
  Self.F_categoriaId := Value;
end;

procedure Tcategoria.setDescricao(const Value: string);
begin
  Self.F_descricao := Value;
end;
{$endregion}

end.
