unit cCadClientes;

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
  Tcliente = class
  private
    ConexaoDB: TZConnection;
    F_clienteId:integer;
    F_nome:string;
    F_endereco:string;
    F_cidade:string;
    F_bairro:string;
    F_estado:string;
    F_cep:string;
    F_telefone:string;
    F_email:string;
    F_dataNascimento:TDateTime;
  public
    constructor Create(aConexao:TZConnection);
    destructor Destroy; override;
    function Inserir:boolean;
    function Atualizar:boolean;
    function Apagar:boolean;
    function Selecionar(id:integer):boolean;

  published
    property codigo:integer           read F_clienteId         write F_clienteId;
    property nome:string              read F_nome              write F_nome;
    property endereco:string          read F_endereco          write F_endereco;
    property cidade:string            read F_cidade            write F_cidade;
    property bairro:string            read F_bairro            write F_bairro;
    property estado:string            read F_estado            write F_estado;
    property cep:string               read F_cep               write F_cep;
    property telefone:string          read F_telefone          write F_telefone;
    property email:string             read F_email             write F_email;
    property dataNascimento:TDateTime read F_dataNascimento    write F_dataNascimento;
  end;


implementation


{$region 'Constructor e Destructor'}
constructor Tcliente.Create(aConexao:TZConnection);
begin
  ConexaoDB :=  aConexao;
end;

destructor Tcliente.Destroy;
begin

  inherited;
end;
{$endregion}


{$region 'CRUD'}
function Tcliente.Apagar: boolean;
var
  Qry:TZQuery;
begin
  if MessageDlg('Deseja apagar o registro: '+#13+#13+
                'C�digo: '+IntToStr(F_clienteId)+#13+
                'Descri��o: '+F_nome,TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],0)=mrNo then
  begin
    Result := false;
    Abort;
  end;

  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM clientes '+
                ' WHERE clienteId = :clienteId ');
    Qry.ParamByName('clienteId').AsInteger := F_clienteId;
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

function Tcliente.Atualizar: boolean;
var
  Qry:TZQuery;
begin
  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('UPDATE  clientes '+
                '   SET  nome           = :nome '+
                '       ,endereco       = :endereco '+
                '       ,cidade         = :cidade '+
                '       ,bairro         = :bairro '+
                '       ,estado         = :estado '+
                '       ,cep            = :cep '+
                '       ,telefone       = :telefone '+
                '       ,email          = :email '+
                '       ,dataNascimento = :dataNascimento '+
                ' WHERE clienteId = :clienteId ');
    Qry.ParamByName('clienteId').AsInteger := self.F_clienteId;
    Qry.ParamByName('nome').AsString := self.F_nome;
    Qry.ParamByName('endereco').AsString := self.F_endereco;
    Qry.ParamByName('cidade').AsString := self.F_cidade;
    Qry.ParamByName('bairro').AsString := self.F_bairro;
    Qry.ParamByName('estado').AsString := self.F_estado;
    Qry.ParamByName('cep').AsString := self.F_cep;
    Qry.ParamByName('telefone').AsString := self.F_telefone;
    Qry.ParamByName('email').AsString := self.F_email;
    Qry.ParamByName('dataNascimento').AsDateTime := self.F_dataNascimento;
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

function Tcliente.Inserir: boolean;
var
  Qry:TZQuery;
begin
  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('INSERT INTO clientes (nome '+
                '                     ,endereco '+
                '                     ,cidade '+
                '                     ,bairro '+
                '                     ,estado '+
                '                     ,cep '+
                '                     ,telefone '+
                '                     ,email '+
                '                     ,dataNascimento) '+
                '     VALUES          (:nome '+
          '                           ,:endereco '+
          '                           ,:cidade '+
          '                           ,:bairro '+
          '                           ,:estado '+
          '                           ,:cep '+
          '                           ,:telefone '+
          '                           ,:email '+
          '                          ,:dataNascimento)');

    Qry.ParamByName('nome').AsString             := self.F_nome;
    Qry.ParamByName('endereco').AsString         := self.F_endereco;
    Qry.ParamByName('cidade').AsString           := self.F_cidade;
    Qry.ParamByName('bairro').AsString           := self.F_bairro;
    Qry.ParamByName('estado').AsString           := self.F_estado;
    Qry.ParamByName('cep').AsString              := self.F_cep;
    Qry.ParamByName('telefone').AsString         := self.F_telefone;
    Qry.ParamByName('email').AsString            := self.F_email;
    Qry.ParamByName('dataNascimento').AsDateTime := self.F_dataNascimento;
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

function Tcliente.Selecionar(id: integer): boolean;
var
  Qry:TZQuery;
begin
  try
    Result := true;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT clienteId '+
'                       ,nome '+
'                       ,endereco '+
'                       ,cidade '+
'                       ,bairro '+
'                       ,estado '+
'                       ,cep '+
'                       ,telefone '+
'                       ,email '+
'                       ,dataNascimento '+
'                  FROM clientes '+
'                 WHERE clienteId = :clienteId ');

    Qry.ParamByName('clienteId').AsInteger := id;
    try
      Qry.Open;
      Self.F_clienteId := Qry.FieldByName('clienteId').AsInteger;
      Self.F_nome := Qry.FieldByName('nome').AsString;
      Self.F_endereco:= Qry.FieldByName('endereco').AsString;
      Self.F_cidade := Qry.FieldByName('cidade').AsString;
      Self.F_bairro := Qry.FieldByName('bairro').AsString;
      Self.F_estado := Qry.FieldByName('estado').AsString;
      Self.F_cep := Qry.FieldByName('cep').AsString;
      Self.F_telefone := Qry.FieldByName('telefone').AsString;
      Self.F_email := Qry.FieldByName('email').AsString;
      Self.F_dataNascimento := Qry.FieldByName('dataNascimento').AsDateTime;
    except
      Result := false;
    end;
  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);
  end;

end;
{$endregion}

end.
