program Demo;

uses
  Vcl.Forms,
  Trysil.Cache in '..\..\Trysil\Trysil.Cache.pas',
  Trysil.Classes in '..\..\Trysil\Trysil.Classes.pas',
  Trysil.Context in '..\..\Trysil\Trysil.Context.pas',
  Trysil.Events.Abstract in '..\..\Trysil\Trysil.Events.Abstract.pas',
  Trysil.Events.Attributes in '..\..\Trysil\Trysil.Events.Attributes.pas',
  Trysil.Events.Factory in '..\..\Trysil\Trysil.Events.Factory.pas',
  Trysil.Events in '..\..\Trysil\Trysil.Events.pas',
  Trysil.Exceptions in '..\..\Trysil\Trysil.Exceptions.pas',
  Trysil.Filter in '..\..\Trysil\Trysil.Filter.pas',
  Trysil.Generics.Collections in '..\..\Trysil\Trysil.Generics.Collections.pas',
  Trysil.IdentityMap in '..\..\Trysil\Trysil.IdentityMap.pas',
  Trysil.Lazy in '..\..\Trysil\Trysil.Lazy.pas',
  Trysil.Mapping in '..\..\Trysil\Trysil.Mapping.pas',
  Trysil.Metadata in '..\..\Trysil\Trysil.Metadata.pas',
  Trysil.Provider in '..\..\Trysil\Trysil.Provider.pas',
  Trysil.Resolver in '..\..\Trysil\Trysil.Resolver.pas',
  Trysil.Rtti in '..\..\Trysil\Trysil.Rtti.pas',
  Trysil.Session in '..\..\Trysil\Trysil.Session.pas',
  Trysil.Sync in '..\..\Trysil\Trysil.Sync.pas',
  Trysil.Types in '..\..\Trysil\Trysil.Types.pas',
  Trysil.Data.Columns in '..\..\Trysil\Data\Trysil.Data.Columns.pas',
  Trysil.Data in '..\..\Trysil\Data\Trysil.Data.pas',
  Trysil.Data.FireDAC in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.pas',
  Trysil.Data.FireDAC.SqlServer in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.SqlServer.pas',
  Trysil.Vcl.ListView in '..\..\Trysil.UI\Trysil.Vcl.ListView.pas',
  Demo.Config in 'Demo.Config.pas',
  Demo.Model in 'Demo.Model.pas',
  Demo.MainForm in 'Demo.MainForm.pas' {MainForm},
  Demo.EditDialog in 'Demo.EditDialog.pas' {EditDialog},
  Demo.ListView in 'Demo.ListView.pas',
  Trysil.Data.Parameters in '..\..\Trysil\Data\Trysil.Data.Parameters.pas',
  Trysil.Data.FireDAC.Connection in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.Connection.pas',
  Trysil.Data.FireDAC.Common in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.Common.pas',
  Trysil.Data.SqlSyntax.SqlServer in '..\..\Trysil\Data\Trysil.Data.SqlSyntax.SqlServer.pas',
  Trysil.Attributes in '..\..\Trysil\Trysil.Attributes.pas',
  Trysil.Data.SqlSyntax.FirebirdSQL in '..\..\Trysil\Data\Trysil.Data.SqlSyntax.FirebirdSQL.pas',
  Trysil.Data.FireDAC.FirebirdSQL in '..\..\Trysil\Data\FireDAC\Trysil.Data.FireDAC.FirebirdSQL.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
