unit uCadCategorias;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.DBCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  cCadCategorias, uDTMConexao, uEnum;

type
  TfrmCadCategorias = class(TfrmTelaHeranca)
    qryListagemcategoriaId: TIntegerField;
    qryListagemdescricao: TWideStringField;
    edtCategoriaId: TLabeledEdit;
    edtDescricao: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
  private
    { Private declarations }
    oCategoria:Tcategoria;
    function Apagar:boolean; override;
    function Gravar(EstadoDoCadastro:TEstadoDoCadastro):boolean; override;
  public
    { Public declarations }

  end;

var
  frmCadCategorias: TfrmCadCategorias;

implementation

{$R *.dfm}


//procedure TfrmCadCategorias.btnGravarClick(Sender: TObject);
//begin
//  if (edtDescricao.Text = EmptyStr) then
//  begin
//    ShowMessage('Campo obrigatório.');
//    edtDescricao.SetFocus;
//    Abort;
//  end;
//  inherited;
//end;

{$region 'Override'}
function TfrmCadCategorias.Apagar: boolean;
begin
  if oCategoria.Selecionar(qryListagem.FieldByName('categoriaId').AsInteger) then
  begin
    Result := oCategoria.Apagar;
  end;
end;

function TfrmCadCategorias.Gravar(EstadoDoCadastro: TEstadoDoCadastro): boolean;
begin
  if edtCategoriaId.Text <> EmptyStr then
    oCategoria.codigo := StrToInt(edtCategoriaId.Text)
  else
    oCategoria.codigo := 0;

  oCategoria.descricao := edtDescricao.Text;

  if (EstadoDoCadastro=ecInserir) then
    Result := oCategoria.Inserir
  else if (EstadoDoCadastro=ecAlterar) then
    Result := oCategoria.Atualizar;
end;
{$endregion}

procedure TfrmCadCategorias.btnAlterarClick(Sender: TObject);
begin
  if oCategoria.Selecionar(qryListagem.FieldByName('categoriaId').AsInteger) then
  begin
    edtCategoriaId.Text := IntToStr(oCategoria.codigo);
    edtDescricao.Text   := oCategoria.descricao;
  end
  else
  begin
    btnCancelar.Click;
    Abort;
  end;

  inherited;
  edtDescricao.SetFocus;

end;

procedure TfrmCadCategorias.btnNovoClick(Sender: TObject);
begin
  inherited;
  edtDescricao.SetFocus;
end;

procedure TfrmCadCategorias.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(oCategoria) then
    FreeAndNil(oCategoria);
end;

procedure TfrmCadCategorias.FormCreate(Sender: TObject);
begin
  inherited;
  oCategoria := Tcategoria.Create(dtmPrincipal.ConexaoDB);
  IndiceAtual := 'descricao';
end;

end.
