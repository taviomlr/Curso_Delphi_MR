unit uCadClientes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.DBCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  RxToolEdit, cCadClientes, uEnum;

type
  TfrmCadClientes = class(TfrmTelaHeranca)
    edtClienteId: TLabeledEdit;
    edtNome: TLabeledEdit;
    Label1: TLabel;
    edtEndereco: TLabeledEdit;
    edtBairro: TLabeledEdit;
    edtCidade: TLabeledEdit;
    Label2: TLabel;
    edtCEP: TMaskEdit;
    edtEmail: TLabeledEdit;
    edtDataNascimento: TDateEdit;
    Label4: TLabel;
    qryListagemclienteId: TIntegerField;
    qryListagemnome: TWideStringField;
    qryListagemendereco: TWideStringField;
    qryListagemcidade: TWideStringField;
    qryListagembairro: TWideStringField;
    qryListagemestado: TWideStringField;
    qryListagemcep: TWideStringField;
    qryListagemtelefone: TWideStringField;
    qryListagememail: TWideStringField;
    qryListagemdataNascimento: TDateTimeField;
    edtTelefone: TMaskEdit;
    Label5: TLabel;
    edtEstado: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
  private
    { Private declarations }
    oCliente:Tcliente;
    function Apagar:boolean; override;
    function Gravar(EstadoDoCadastro:TEstadoDoCadastro):boolean; override;
  public
    { Public declarations }
  end;

var
  frmCadClientes: TfrmCadClientes;

implementation

{$R *.dfm}

uses uDTMConexao;


{ TfrmCadClientes }


{$region 'Override'}
function TfrmCadClientes.Apagar: boolean;
begin
  if oCliente.Selecionar(qryListagem.FieldByName('clienteId').AsInteger) then
    begin
      Result := oCliente.Apagar;
    end;
end;

function TfrmCadClientes.Gravar(EstadoDoCadastro: TEstadoDoCadastro): boolean;
begin
  if edtClienteId.Text <> EmptyStr then
    oCliente.codigo := StrToInt(edtClienteId.Text)
  else
    oCliente.codigo := 0;

  oCliente.nome           := edtNome.Text;
  oCliente.endereco       := edtEndereco.Text;
  oCliente.cidade         := edtCidade.Text;
  oCliente.bairro         := edtBairro.Text;
  oCliente.estado         := edtEstado.Text;
  oCliente.cep            := edtCEP.Text;
  oCliente.telefone       := edtTelefone.Text;
  oCliente.email          := edtEmail.Text;
  oCliente.dataNascimento := edtDataNascimento.Date;

  if (EstadoDoCadastro=ecInserir) then
    Result := oCliente.Inserir
  else if (EstadoDoCadastro=ecAlterar) then
    Result := oCliente.Atualizar;
end;
{$endregion}

procedure TfrmCadClientes.btnAlterarClick(Sender: TObject);
begin
  if oCliente.Selecionar(qryListagem.FieldByName('clienteId').AsInteger) then
  begin
    edtClienteId.Text := IntToStr(oCliente.codigo);
    edtNome.Text   := oCliente.nome;
    edtEndereco.Text   := oCliente.endereco;
    edtCidade.Text   := oCliente.cidade;
    edtBairro.Text   := oCliente.bairro;
    edtEstado.Text   := oCliente.estado;
    edtCEP.Text   := oCliente.cep;
    edtTelefone.Text   := oCliente.telefone;
    edtEmail.Text   := oCliente.email;
    edtdataNascimento.Date   := oCliente.dataNascimento;
  end
  else
  begin
    btnCancelar.Click;
    Abort;
  end;

  inherited;
  edtNome.SetFocus;
end;

procedure TfrmCadClientes.btnNovoClick(Sender: TObject);
begin
  inherited;
  edtNome.SetFocus;
end;

procedure TfrmCadClientes.FormCreate(Sender: TObject);
begin
  inherited;
  oCliente := Tcliente.Create(dtmPrincipal.ConexaoDB);
  IndiceAtual := 'nome';
end;

end.
