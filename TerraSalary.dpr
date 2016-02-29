program TerraSalary;

uses
  System.StartUpCopy,
  FMX.Forms,
  MasterDetail in 'MasterDetail.pas' {MasterDetailForm},
  DMSQLite in 'DMSQLite.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TMasterDetailForm, MasterDetailForm);
  Application.Run;
end.
