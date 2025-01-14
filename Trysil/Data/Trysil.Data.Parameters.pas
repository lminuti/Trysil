(*

  Trysil
  Copyright � David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.Parameters;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.TypInfo,
  Data.DB,

  Trysil.Data,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Mapping,
  Trysil.Rtti;

type

{ TTDataParameter }

  TTDataParameter = class abstract
  strict protected
    FParam: ITDataSetParam;
    FMapper: TTMapper;
    FColumnMap: TTColumnMap;
  public
    constructor Create(
      const AParam: ITDataSetParam;
      const AMapper: TTMapper;
      const AColumnMap: TTColumnMap);

    procedure SetValue(const AEntity: TObject); virtual; abstract;
  end;

  TTDataParameterClass = class of TTDataParameter;

{ TTDataStringParameter }

  TTDataStringParameter = class(TTDataParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataIntegerParameter }

  TTDataIntegerParameter = class(TTDataParameter)
  strict private
    procedure SetValueFromObject(const AObject: TObject);
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataLargeIntegerParameter }

  TTDataLargeIntegerParameter = class(TTDataParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataDoubleParameter }

  TTDataDoubleParameter = class(TTDataParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataBooleanParameter }

  TTDataBooleanParameter = class(TTDataParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataDateTimeParameter }

  TTDataDateTimeParameter = class(TTDataParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataGuidParameter }

  TTDataGuidParameter = class(TTDataParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataBlobParameter }

  TTDataBlobParameter = class(TTDataParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDataParameterFactory }

  TTDataParameterFactory = class
  strict private
    class var FInstance: TTDataParameterFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FDataParameterTypes: TDictionary<TFieldType, TClass>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterParameterClass<C: TTDataParameter>(
      const AFieldType: TFieldType);

    function CreateParameter(
      const AFieldType: TFieldType;
      const AParam: ITDataSetParam;
      const AMapper: TTMapper;
      const AColumnMap: TTColumnMap): TTDataParameter;

    class property Instance: TTDataParameterFactory read FInstance;
  end;

{ TTDataParameterRegister }

  TTDataParameterRegister = class
  public
    class procedure RegisterParameterClasses;
  end;

{ resourcestring }

resourcestring
  SBlobDataParameterValue = 'Value for blob Parameter is not accessible.';
  SParameterTypeError = 'Parameter non registered for type %s.';
  STableMapNotFound = 'TableMap for class %s not found';
  SPrimaryKeyNotDefined = 'Primary key not defined for class %s';

implementation

{ TTDataParameter }

constructor TTDataParameter.Create(
  const AParam: ITDataSetParam;
  const AMapper: TTMapper;
  const AColumnMap: TTColumnMap);
begin
  inherited Create;
  FParam := AParam;
  FMapper := AMapper;
  FColumnMap := AColumnMap;
end;

{ TTDataStringParameter }

procedure TTDataStringParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<String>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<String>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsString := LNullable;
  end
  else
    FParam.AsString := LValue.AsType<String>();
end;

{ TTDataIntegerParameter }

procedure TTDataIntegerParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Integer>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Integer>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsInteger := LNullable;
  end
  else if FColumnMap.Member.IsClass then
    SetValueFromObject(LValue.AsObject)
  else
    FParam.AsInteger := LValue.AsType<Integer>();
end;

procedure TTDataIntegerParameter.SetValueFromObject(const AObject: TObject);
var
  LTableMap: TTTableMap;
  LValue: TTValue;
begin
  if TRttiLazy.IsLazy(AObject) then
    LValue := FColumnMap.Member.GetValueFromObject(AObject)
  else
  begin
    LTableMap := FMapper.Load(AObject.ClassInfo);
    if not Assigned(LTableMap) then
      raise ETException.Create(STableMapNotFound);
    if not Assigned(LTableMap.PrimaryKey) then
      raise ETException.Create(SPrimaryKeyNotDefined);
    LValue := LTableMap.PrimaryKey.Member.GetValue(AObject);
  end;
  FParam.AsInteger := LValue.AsType<Integer>();
end;

{ TTDataLargeIntegerParameter }

procedure TTDataLargeIntegerParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Int64>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Int64>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsLargeInt := LNullable;
  end
  else
    FParam.AsLargeInt := LValue.AsType<Int64>();
end;

{ TTDataDoubleParameter }

procedure TTDataDoubleParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Double>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Double>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsFloat := LNullable;
  end
  else
    FParam.AsFloat := LValue.AsType<Double>();
end;

{ TTDataBooleanParameter }

procedure TTDataBooleanParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Boolean>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Boolean>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsBoolean := LNullable;
  end
  else
    FParam.AsBoolean := LValue.AsType<Boolean>();
end;

{ TTDataDateTimeParameter }

procedure TTDataDateTimeParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<TDateTime>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<TDateTime>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsDateTime := LNullable;
  end
  else
    FParam.AsDateTime := LValue.AsType<TDateTime>();
end;

{ TTDataGuidParameter }

procedure TTDataGuidParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<TGuid>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<TGuid>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsGuid := LNullable;
  end
  else
    FParam.AsGuid := LValue.AsType<TGuid>();
end;

{ TTDataBlobParameter }

procedure TTDataBlobParameter.SetValue(const AEntity: TObject);
begin
  raise ETException.Create(SBlobDataParameterValue);
end;

{ TTDataParameterFactory }

class constructor TTDataParameterFactory.ClassCreate;
begin
  FInstance := TTDataParameterFactory.Create;
  TTDataParameterRegister.RegisterParameterClasses;
end;

class destructor TTDataParameterFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTDataParameterFactory.Create;
begin
  inherited Create;
  FDataParameterTypes := TDictionary<TFieldType, TClass>.Create;
end;

destructor TTDataParameterFactory.Destroy;
begin
  FDataParameterTypes.Free;
  inherited Destroy;
end;

procedure TTDataParameterFactory.RegisterParameterClass<C>(
  const AFieldType: TFieldType);
begin
  FDataParameterTypes.Add(AFieldType, C);
end;

function TTDataParameterFactory.CreateParameter(
  const AFieldType: TFieldType;
  const AParam: ITDataSetParam;
  const AMapper: TTMapper;
  const AColumnMap: TTColumnMap): TTDataParameter;
var
  LClass: TClass;
begin
  if not FDataParameterTypes.TryGetValue(AFieldType, LClass) then
    raise ETException.CreateFmt(SParameterTypeError, [
      GetEnumName(TypeInfo(TFieldType), Ord(AFieldType))]);
  result := TTDataParameterClass(LClass).Create(AParam, AMapper, AColumnMap);
end;

{ TTDataParameterRegister }

class procedure TTDataParameterRegister.RegisterParameterClasses;
var
  LInstance: TTDataParameterFactory;
begin
  LInstance := TTDataParameterFactory.Instance;

  // TTDataStringParameter
  LInstance.RegisterParameterClass<TTDataStringParameter>(TFieldType.ftString);
  LInstance.RegisterParameterClass<TTDataStringParameter>(TFieldType.ftWideString);
  LInstance.RegisterParameterClass<TTDataStringParameter>(TFieldType.ftMemo);
  LInstance.RegisterParameterClass<TTDataStringParameter>(TFieldType.ftWideMemo);

  // TTDataIntegerParameter
  LInstance.RegisterParameterClass<TTDataIntegerParameter>(TFieldType.ftSmallint);
  LInstance.RegisterParameterClass<TTDataIntegerParameter>(TFieldType.ftInteger);

  // TTDataLargeIntegerParameter
  LInstance.RegisterParameterClass<TTDataLargeIntegerParameter>(TFieldType.ftLargeint);

  // TTDataDoubleParameter
  LInstance.RegisterParameterClass<TTDataDoubleParameter>(TFieldType.ftBCD);
  LInstance.RegisterParameterClass<TTDataDoubleParameter>(TFieldType.ftFloat);
  LInstance.RegisterParameterClass<TTDataDoubleParameter>(TFieldType.ftSingle);
  LInstance.RegisterParameterClass<TTDataDoubleParameter>(TFieldType.ftCurrency);

  // TTDataBooleanParameter
  LInstance.RegisterParameterClass<TTDataBooleanParameter>(TFieldType.ftBoolean);

  // TTDataDateTimeParameter
  LInstance.RegisterParameterClass<TTDataDateTimeParameter>(TFieldType.ftDate);
  LInstance.RegisterParameterClass<TTDataDateTimeParameter>(TFieldType.ftDateTime);
  LInstance.RegisterParameterClass<TTDataDateTimeParameter>(TFieldType.ftTimeStamp);

  // TTDataGuidParameter
  LInstance.RegisterParameterClass<TTDataGuidParameter>(TFieldType.ftGuid);

  // TTDataBlobParameter
  LInstance.RegisterParameterClass<TTDataBlobParameter>(TFieldType.ftBlob);
end;

end.
