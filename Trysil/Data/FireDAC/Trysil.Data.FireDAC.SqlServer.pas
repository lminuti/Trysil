﻿(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.SqlServer;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Phys.MSSQL,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,

  Trysil.Types,
  Trysil.Filter,
  Trysil.Exceptions,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Data,
  Trysil.Data.Parameters,
  Trysil.Events.Abstract,
  Trysil.Data.FireDAC.Connection,
  Trysil.Data.FireDAC.Common,
  Trysil.Data.FireDAC,
  Trysil.Data.SqlSyntax.SqlServer;

type
{ TTDataSqlServerConnection }

  TTDataSqlServerConnection = class(TTDataFireDACConnection)
  strict protected
    function GetDataSetParam(AParam: TFDParam): ITDataSetParam;

    function SelectCount(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Integer; override;
  public
    procedure GetMetadata(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;

    function GetSequenceID(const ASequenceName: String): TTPrimaryKey; override;

    function CreateReader(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTDataReader; override;

    function CreateInsertCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataInsertCommand; override;

    function CreateUpdateCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataUpdateCommand; override;

    function CreateDeleteCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataDeleteCommand; override;
  public
    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;

  end;

{ TTDataSqlServerDataReader }

  TTDataSqlServerDataReader = class(TTDataReader)
  strict private
    FSyntax: TTDataSqlServerSelectSyntax;
  strict protected
    function GetDataset: TDataset; override;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;
  end;

{ TTDataSqlServerDataInsertCommand }

  TTDataSqlServerDataInsertCommand = class(TTDataInsertCommand)
  strict private
    FConnection: TTDataConnection;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataSqlServerDataUpdateCommand }

  TTDataSqlServerDataUpdateCommand = class(TTDataUpdateCommand)
  strict private
    FConnection: TTDataConnection;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataSqlServerDataDeleteCommand }

  TTDataSqlServerDataDeleteCommand = class(TTDataDeleteCommand)
  strict private
    FConnection: TTDataConnection;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

implementation

{ TTDataSqlServerConnection }

class procedure TTDataSqlServerConnection.RegisterConnection(const AName,
  AServer, AUsername, APassword, ADatabaseName: String);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Server=%s', [AServer]));
    LParameters.Add(Format('Database=%s', [ADatabaseName]));
    if AUsername.IsEmpty then
        LParameters.Add('OSAuthent=Yes')
    else
    begin
        LParameters.Add(Format('User_Name=%s', [AUserName]));
        LParameters.Add(Format('Password=%s', [APassword]));
    end;

    TTDataFireDACConnectionPool.Instance.RegisterConnection(
      AName, 'MSSQL', LParameters);
  finally
    LParameters.Free;
  end;
end;

function TTDataSqlServerConnection.SelectCount(
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AEntity: TObject): Integer;
var
  LID: TTPrimaryKey;
  LSyntax: TTDataSqlServerSelectCountSyntax;
begin
  LID := ATableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  LSyntax := TTDataSqlServerSelectCountSyntax.Create(
    Self, ATableMap, ATableName, AColumnName, LID);
  try
    result := LSyntax.Count;
  finally
    LSyntax.Free;
  end;
end;

function TTDataSqlServerConnection.GetDataSetParam(
  AParam: TFDParam): ITDataSetParam;
begin
  Result := TTFDDataSetParam.Create(AParam);
end;

procedure TTDataSqlServerConnection.GetMetadata(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
var
  LSyntax: TTDataSqlServerMetadataSyntax;
  LIndex: Integer;
begin
  LSyntax := TTDataSqlServerMetadataSyntax.Create(
    Self, AMapper, ATableMap, ATableMetadata);
  try
    for LIndex := 0 to LSyntax.Dataset.FieldDefs.Count - 1 do
      ATableMetadata.Columns.Add(
        LSyntax.Dataset.FieldDefs[LIndex].Name,
        LSyntax.Dataset.FieldDefs[LIndex].DataType,
        LSyntax.Dataset.FieldDefs[LIndex].Size);
  finally
    LSyntax.Free;
  end;
end;

function TTDataSqlServerConnection.GetSequenceID(
  const ASequenceName: String): TTPrimaryKey;
var
  LSyntax: TTDataSqlServerSequenceSyntax;
begin
  LSyntax := TTDataSqlServerSequenceSyntax.Create(Self, ASequenceName);
  try
    result := LSyntax.ID;
  finally
    LSyntax.Free;
  end;
end;

function TTDataSqlServerConnection.CreateReader(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTDataReader;
begin
  result := TTDataSqlServerDataReader.Create(
    Self, AMapper, ATableMap, ATableMetadata, AFilter);
end;

function TTDataSqlServerConnection.CreateInsertCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataInsertCommand;
begin
  result := TTDataSqlServerDataInsertCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata);
end;

function TTDataSqlServerConnection.CreateUpdateCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataUpdateCommand;
begin
  result := TTDataSqlServerDataUpdateCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata);
end;

function TTDataSqlServerConnection.CreateDeleteCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataDeleteCommand;
begin
  result := TTDataSqlServerDataDeleteCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata);
end;

class procedure TTDataSqlServerConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

{ TTDataSqlServerDataReader }

constructor TTDataSqlServerDataReader.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FSyntax := TTDataSqlServerSelectSyntax.Create(
    AConnection, AMapper, ATableMap, ATableMetadata, AFilter);
end;

destructor TTDataSqlServerDataReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTDataSqlServerDataReader.GetDataset: TDataset;
begin
  result := FSyntax.Dataset;
end;

{ TTDataSqlServerDataInsertCommand }

constructor TTDataSqlServerDataInsertCommand.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataSqlServerDataInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataSqlServerInsertSyntax;
begin
  LSyntax := TTDataSqlServerInsertSyntax.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataSqlServerDataUpdateCommand }

constructor TTDataSqlServerDataUpdateCommand.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataSqlServerDataUpdateCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataSqlServerUpdateSyntax;
begin
  LSyntax := TTDataSqlServerUpdateSyntax.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataSqlServerDataDeleteCommand }

constructor TTDataSqlServerDataDeleteCommand.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataSqlServerDataDeleteCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataSqlServerDeleteSyntax;
begin
  LSyntax := TTDataSqlServerDeleteSyntax.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

end.
