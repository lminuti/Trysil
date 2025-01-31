﻿(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.Connection;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
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
  Trysil.Data.FireDAC.Common,
  Trysil.Data.FireDAC;

type

{ TTFDDataSetParam }

  TTFDDataSetParam = class(TInterfacedObject, ITDataSetParam)
  private
    FParam: TFDParam;
  public
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(const Value: Boolean);
    function GetAsDateTime: TDateTime;
    procedure SetAsDateTime(const Value: TDateTime);
    function GetAsGuid: TGUID;
    procedure SetAsGuid(const Value: TGUID);
    function GetAsFloat: Double;
    procedure SetAsFloat(const Value: Double);
    function GetAsLargeInt: Int64;
    procedure SetAsLargeInt(const Value: Int64);
    function GetAsInteger: Integer;
    procedure SetAsInteger(const Value: Integer);
    function GetAsString: string;
    procedure SetAsString(const Value: string);

    procedure Clear;

    constructor Create(AParam: TFDParam);
  end;

{ TTDataFireDACConnection }

  TTDataFireDACConnection = class(TTDataConnection)
  strict private
    FConnectionName: String;

    FWaitCursor: TFDGUIxWaitCursor;
    FConnection: TFDConnection;
  strict protected
    function GetDataSetParam(AParam: TFDParam): ITDataSetParam;

    procedure InitializeParameters(ADataSet: TFDQuery;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject);

    function GetInTransaction: Boolean; override;

  public
    constructor Create(const AConnectionName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;

    function CreateDataSet(const ASQL: string): TDataSet; override;
    function Execute(const ASQL: string;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject): Integer; override;
  end;

{ resourcestring }

resourcestring
  SInTransaction = '%s: Transaction already started.';
  SNotInTransaction = '%s: Transaction not yet started.';

implementation

{ TTFDDataSetParam }

procedure TTFDDataSetParam.Clear;
begin
  FParam.Clear;
end;

constructor TTFDDataSetParam.Create(AParam: TFDParam);
begin
  inherited Create;
  FParam := AParam;
end;

function TTFDDataSetParam.GetAsBoolean: Boolean;
begin
  Result := FParam.AsBoolean;
end;

function TTFDDataSetParam.GetAsDateTime: TDateTime;
begin
  Result := FParam.AsDateTime;
end;

function TTFDDataSetParam.GetAsFloat: Double;
begin
  Result := FParam.AsFloat;
end;

function TTFDDataSetParam.GetAsGuid: TGUID;
begin
  Result := FParam.AsGUID;
end;

function TTFDDataSetParam.GetAsInteger: Integer;
begin
  Result := FParam.AsInteger;
end;

function TTFDDataSetParam.GetAsLargeInt: Int64;
begin
  Result := FParam.AsLargeInt;
end;

function TTFDDataSetParam.GetAsString: string;
begin
  Result := FParam.AsString;
end;

procedure TTFDDataSetParam.SetAsBoolean(const Value: Boolean);
begin
  FParam.AsBoolean := Value;
end;

procedure TTFDDataSetParam.SetAsDateTime(const Value: TDateTime);
begin
  FParam.AsDateTime := Value;
end;

procedure TTFDDataSetParam.SetAsFloat(const Value: Double);
begin
  FParam.AsFloat := Value;
end;

procedure TTFDDataSetParam.SetAsGuid(const Value: TGUID);
begin
  FParam.AsGUID := Value;
end;

procedure TTFDDataSetParam.SetAsInteger(const Value: Integer);
begin
  FParam.AsInteger := Value;
end;

procedure TTFDDataSetParam.SetAsLargeInt(const Value: Int64);
begin
  FParam.AsLargeInt := Value;
end;

procedure TTFDDataSetParam.SetAsString(const Value: string);
begin
  FParam.AsString := Value;
end;

{ TTDataFireDACConnection }

constructor TTDataFireDACConnection.Create(const AConnectionName: String);
begin
    inherited Create;
    FConnectionName := AConnectionName;

    FWaitCursor := TFDGUIxWaitCursor.Create(nil);
    FConnection := TFDConnection.Create(nil);
end;

destructor TTDataFireDACConnection.Destroy;
begin
    FConnection.Free;
    FWaitCursor.Free;
    inherited Destroy;
end;

function TTDataFireDACConnection.Execute(const ASQL: string;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject): Integer;
var
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(FConnection);
  try
    LDataSet.Connection := FConnection;
    LDataSet.SQL.Text := ASQL;

    if Assigned(AEntity) then
      InitializeParameters(LDataSet, AMapper, ATableMap, ATableMetadata, AEntity);

    LDataSet.Execute;
    Result := LDataSet.RowsAffected;
  except
    LDataSet.Free;
    raise;
  end;
end;

procedure TTDataFireDACConnection.AfterConstruction;
begin
    inherited AfterConstruction;
    FWaitCursor.Provider := 'Console';
    FWaitCursor.ScreenCursor := TFDGUIxScreenCursor.gcrNone;

    FConnection.ConnectionDefName := FConnectionName;
    FConnection.Open;
end;

procedure TTDataFireDACConnection.StartTransaction;
begin
  if FConnection.InTransaction then
    raise ETException.CreateFmt(SInTransaction, ['StartTransaction']);
  FConnection.StartTransaction;
end;

procedure TTDataFireDACConnection.CommitTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['CommitTransaction']);
  FConnection.Commit;
end;

procedure TTDataFireDACConnection.RollbackTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['RollbackTransaction']);
  FConnection.Rollback;
end;

function TTDataFireDACConnection.GetDataSetParam(
  AParam: TFDParam): ITDataSetParam;
begin
  Result := TTFDDataSetParam.Create(AParam);
end;

function TTDataFireDACConnection.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

procedure TTDataFireDACConnection.InitializeParameters(ADataSet: TFDQuery;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject);

  function GetColumnMap(
    const AColumnName: String): TTColumnMap;
  var
    LColumn: TTColumnMap;
  begin
    result := nil;
    for LColumn in ATableMap.Columns do
      if LColumn.Name.Equals(AColumnName) then
      begin
        result := LColumn;
        Break;
      end;

    if not Assigned(result) then
      raise ETException.CreateFmt(SColumnNotFound, [AColumnName]);
  end;

var
  LColumn: TTColumnMetadata;
  LParam: TTDataParameter;
  LFireDACParam: TFDParam;
begin
  for LColumn in ATableMetadata.Columns do
  begin
    LFireDACParam := ADataset.Params.FindParam(LColumn.ColumnName);
    if Assigned(LFireDACParam) then
    begin
      LFireDACParam.ParamType := TParamType.ptInput;
      LFireDACParam.DataType := LColumn.DataType;
      LFireDACParam.Size := LColumn.DataSize;

      LParam := TTDataParameterFactory.Instance.CreateParameter(
          LColumn.DataType, GetDataSetParam(LFireDACParam), AMapper, GetColumnMap(LColumn.ColumnName));
      try
        LParam.SetValue(AEntity);
      finally
        LParam.Free;
      end;
    end;
  end;
end;

function TTDataFireDACConnection.CreateDataSet(
  const ASQL: string): TDataSet;
var
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(FConnection);
  try
    LDataSet.Connection := FConnection;
    LDataSet.SQL.Text := ASQL;
  except
    LDataSet.Free;
    raise;
  end;
  Result := LDataSet;
end;

end.
