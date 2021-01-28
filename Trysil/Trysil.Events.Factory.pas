(*

  Trysil
  Copyright � David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Events.Factory;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,

  Trysil.Exceptions,
  Trysil.Events.Abstract;

type

{ TTEventFactory }

  TTEventFactory = class
  strict private
    class var FInstance: TTEventFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FContext: TRttiContext;

    function SearchMethod(
      const ARttiType: TRttiType;
      const AContext: TObject;
      const AEntity: TObject): TRttiMethod;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateEvent<T: class>(
      const ATypeInfo: PTypeInfo;
      const AContext: TObject;
      const AEntity: T): TTEvent;

    class property Instance: TTEventFactory read FInstance;
  end;

resourcestring
  SNotValidEventClass = 'Not valid constructor in TTEvent class: %s.';
  SNotEventType = 'Not valid TTEvent type: %s.';

implementation

{ TTEventFactory }

class constructor TTEventFactory.ClassCreate;
begin
  FInstance := TTEventFactory.Create;
end;

class destructor TTEventFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTEventFactory.Create;
begin
  inherited Create;
  FContext := TRttiContext.Create;
end;

destructor TTEventFactory.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

function TTEventFactory.SearchMethod(
  const ARttiType: TRttiType;
  const AContext: TObject;
  const AEntity: TObject): TRttiMethod;
var
  LRttiMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
  LIsValid: Boolean;
begin
  result := nil;
  for LRttiMethod in ARttiType.GetMethods do
    if LRttiMethod.IsConstructor then
    begin
      LParameters := LRttiMethod.GetParameters;
      LIsValid := Length(LParameters) = 2;
      if LIsValid then
        LIsValid :=
          (LParameters[0].ParamType.Handle = AContext.ClassInfo) and
          (LParameters[1].ParamType.Handle = AEntity.ClassInfo);

      if LIsValid then
      begin
        result := LRttiMethod;
        Break;
      end;
    end;
end;

function TTEventFactory.CreateEvent<T>(
  const ATypeInfo: PTypeInfo;
  const AContext: TObject;
  const AEntity: T): TTEvent;
var
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
  LParams: TArray<TValue>;
  LResult: TValue;
begin
  result := nil;
  if Assigned(ATypeInfo) then
  begin
    LRttiType := FContext.GetType(ATypeInfo);
    LRttiMethod := SearchMethod(LRttiType, AContext, AEntity);
    if not Assigned(LRttiMethod) then
      raise ETException.CreateFmt(SNotValidEventClass, [ATypeInfo.Name]);

    SetLength(LParams, 2);
    LParams[0] := TValue.From<TObject>(AContext);
    LParams[1] := TValue.From<TObject>(AEntity);

    LResult := LRttiMethod.Invoke(LRttiType.AsInstance.MetaclassType, LParams);
    try
      if not LResult.IsType<TTEvent>(False) then
        raise ETException.CreateFmt(SNotEventType, [ATypeInfo.Name]);
      result := LResult.AsType<TTEvent>(False);
    except
      LResult.AsObject.Free;
      raise;
    end;
  end;
end;

end.