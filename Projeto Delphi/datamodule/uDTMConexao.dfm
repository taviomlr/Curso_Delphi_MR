object dtmPrincipal: TdtmPrincipal
  OldCreateOrder = False
  Height = 150
  Width = 215
  object ConexaoDB: TZConnection
    ControlsCodePage = cCP_UTF16
    AutoEncodeStrings = True
    Catalog = ''
    Properties.Strings = (
      'controls_cp=CP_UTF16'
      'AutoEncodeStrings=True')
    Connected = True
    HostName = '.\SERVERCURSO'
    Port = 1433
    Database = 'vendas'
    User = 'sa'
    Password = 'S@geBr.2014'
    Protocol = 'mssql'
    LibraryLocation = 'C:\workspace\Estudos-C-VB6-e-Delphi\Delphi\ntwdblib.dll'
    Left = 120
    Top = 48
  end
end
