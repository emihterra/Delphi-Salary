unit DMSQLite;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.FMXUI.Wait,
  FireDAC.Comp.UI, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet,
  System.SyncObjs, System.Variants, FMX.Dialogs;

const
  CtDBName = 'terra.db';
  CtSQLiteDll = 'sqlite3.dll';

type
  TParamsProc = reference to procedure(AADQuery: TFDQuery);
  TGetQueryValueProc = reference to procedure(AADQuery: TDataSet);
  TShowErrorProc = reference to procedure(AMessage: String);

type
  TSalaryFieldData = record
    Name: String;
    Value: String;
  end;
  TSalaryFieldsArray = array of TSalaryFieldData;

type
  TDM = class(TDataModule)
    SQLConnection: TFDConnection;
    FDQuery1: TFDQuery;
    FDTransaction1: TFDTransaction;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FDBUpdateCriticalSection: TCriticalSection;
    procedure PrepareDB;
    procedure ExecSQL(
      ASQL: String; AParamsProc: TParamsProc = nil;
      AShowErrorProc: TShowErrorProc = nil);
    function OpenSQL(
      ASQL: String;
      AParamsProc: TParamsProc = nil;
      AGetQueryValueProc: TGetQueryValueProc = nil;
      AShowErrorProc: TShowErrorProc = nil;
      ARecsSkip: Integer = -1;
      ARecsMax: Integer = -1): Boolean;
    function GetNewQueryInstance: TFDQuery;
    function SaveToFileFromBlob(ASQL, AFileSpec: String; AShowErrorProc: TShowErrorProc = nil): Boolean;
  public
    { Public declarations }
    function DBConnect(AShowErrorProc: TShowErrorProc = nil): Boolean;
    procedure DBDisconnect;
    procedure SaveEmployee(
      AMonth: String;
      AYear: String;
      AIDUser: String;
      AName: String;
      ADepartment: String;
      AUnknownType: TSalaryFieldsArray;
      AIncomeFields: TSalaryFieldsArray;
      AWithheldFields: TSalaryFieldsArray;
      APaymentsFields: TSalaryFieldsArray;
      AIncomeSum: TSalaryFieldData;
      AWithheldSum: TSalaryFieldData;
      AMonthBegin: TSalaryFieldData;
      APayAll: TSalaryFieldData;
      APaymentsSum: TSalaryFieldData;
      ASalaryHand: TSalaryFieldData);

    function GetOrAddDepartment(ADepartmentName: String): Integer;
    procedure GetDepartments(SL: TStrings);
    procedure GetPeriods(SL: TStrings);
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure SaveToBlobFromStream(Stream: TStream; Dataset: TDataset; const FieldName: String); overload;
var
  BS: TStream;
begin
  BS := Dataset.CreateBlobStream(Dataset.FieldByName(FieldName), bmWrite);
  try
    BS.Seek(0, soFromBeginning);
    Stream.Position := 0;
    BS.CopyFrom(Stream, Stream.Size);
  finally
    FreeAndNil(BS);
  end;
end;

procedure SaveToBlobFromFile(const FileSpec: String; Dataset: TDataset; const FieldName: String);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileSpec, fmOpenRead or fmShareDenyNone);
  try
    SaveToBlobFromStream(FS, Dataset, FieldName);
  finally
    FreeAndNil(FS);
  end;
end;

procedure SaveToBlobFromStr(const Str: String; Dataset: TDataset; const FieldName: String);
var
  SS: TStringStream;
begin
  SS := TStringStream.Create(Str);
  try
    SaveToBlobFromStream(SS, Dataset, FieldName);
  finally
    FreeAndNil(SS);
  end;
end;

procedure LoadFromBlobToStream(Stream: TStream; Dataset: TDataset; const FieldName: String);
var
  BS: TStream;
begin
  BS := Dataset.CreateBlobStream(Dataset.FieldByName(FieldName), bmRead);
  try
    BS.Seek(0, soFromBeginning);
    Stream.CopyFrom(BS, BS.Size);
  finally
    FreeAndNil(BS);
  end;
end;

procedure LoadFromBlobToStr(var Str: String; Dataset: TDataset; const FieldName: String); overload;
var
  SS: TStringStream;
begin
  SS := TStringStream.Create('');
  try
    LoadFromBlobToStream(SS, Dataset, FieldName);
    Str := SS.DataString;
  finally
    FreeAndNil(SS);
  end;
end;

procedure LoadFromBlobToFile(const FileSpec: String; Dataset: TDataset; const FieldName: String);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileSpec, fmCreate);
  try
    LoadFromBlobToStream(FS, Dataset, FieldName);
  finally
    FreeAndNil(FS);
  end;
end;

function TDM.SaveToFileFromBlob(ASQL, AFileSpec: String; AShowErrorProc: TShowErrorProc = nil): Boolean;
var
  FS: TFileStream;
  SQLQuery: TFDQuery;
begin
  Result := False;
  SQLQuery := GetNewQueryInstance;

  if Assigned(SQLQuery) then
  begin
    try
      if SQLQuery.Active then
      begin
        SQLQuery.Close;
      end;
      SQLQuery.SQL.Text := ASQL;
      SQLQuery.Open;
      if not SQLQuery.Eof and not VarIsNull(SQLQuery.Fields[0].AsVariant) then
      begin
        FS := TFileStream.Create(AFileSpec, fmCreate);
        try
          FS.WriteData(SQLQuery.Fields[0].AsBytes, Length(SQLQuery.Fields[0].AsBytes));
          Result := FileExists(AFileSpec);
        finally
          FS.Free;
        end;
      end;
    except
      on E: Exception do
      begin
        if Assigned(AShowErrorProc) then
        begin
          AShowErrorProc(E.Message);
        end
        else
        begin
          ShowMessage(E.Message);
        end;
      end;
    end;
  end;
end;

function GetExePath(AFileName: String = ''): String;
begin
  Result := ExtractFilePath(ParamStr(0)) + AFileName;
end;

function GetDBPath: String;
begin
  Result := GetExePath + ctDBName;
end;

function TDM.DBConnect(AShowErrorProc: TShowErrorProc = nil): Boolean;
var
  DbPath: String;
begin
  Result := False;
  dbPath := GetDBPath;

  if Assigned(SQLConnection) then
  begin
    try
      if FileExists(GetExePath(ctSQLiteDll)){ and
         FileExists(dbPath)} then
      begin
        if SQLConnection.Connected then
        begin
          SQLConnection.Connected := False;
        end;

        with SQLConnection.Params do
        begin
          Add(Format('Database=%s', [dbPath]));
          Add('LockingMode=Normal');
          Add('JournalMode=WAL');
          Add('Synchronous=Full');
          Add('SQLiteAdvanced=temp_store=MEMORY');
          Add('SQLiteAdvanced=page_size=4096');
          Add('SQLiteAdvanced=auto_vacuum=FULL');
        end;
//  SQLConnection.Params.Add('Password=25112002');
//  ADSQLiteSecurity1.Password := '25112002';
//  ADSQLiteSecurity1.Database := DBName;

        SQLConnection.Connected := True;
        if SQLConnection.Connected then
        begin
          PrepareDB;
          Result := True;
        end;
      end;
    except
      on E: Exception do
      begin
        if Assigned(AShowErrorProc) then
        begin
          AShowErrorProc(E.Message);
        end
        else
        begin
          ShowMessage(E.Message);
        end;
      end;
    end;
  end;
end;

procedure TDM.DBDisconnect;
begin
  if Assigned(SQLConnection) and SQLConnection.Connected then
  begin
    SQLConnection.Connected := False;
  end;
end;

procedure TDM.PrepareDB;
var
  db_version: String;
begin
  ExecSQL('CREATE TABLE IF NOT EXISTS SYSTEM_INFO (''db_version'' TEXT)');

  if not OpenSQL(
          'select db_version from SYSTEM_INFO', nil,
           procedure(AADQuery: TDataSet)
           begin
             db_version := AADQuery.FieldByName('db_version').AsString;
           end) then
  begin
    db_version := '1';
    ExecSQL('insert into SYSTEM_INFO (db_version) values (''1'')');
  end;

  ExecSQL(
    'CREATE TABLE IF NOT EXISTS DEPARTMENT (' +
      '''id'' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,' +
      '''name'' TEXT' +
      ')');

  ExecSQL(
    'CREATE TABLE IF NOT EXISTS EMPLOYEE (' +
      '''id'' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,' +
      '''id_department'' INTEGER DEFAULT 0,' +
      '''name'' TEXT,' +
      '''id_user'' TEXT,' +              // ���������� ����� ����������
      '''month'' TEXT,' +
      '''year'' TEXT,' +
      '''income_fields'' TEXT,' +        // ������������ ����� ���������� ����� ;
      '''income_values'' TEXT,' +        // �������� ����� ���������� ����� ;
      '''income_sum'' TEXT,' +           // ����� ���������
      '''withheld_fields'' TEXT,' +      // ������������ ����� ��������� ����� ;
      '''withheld_values'' TEXT,' +      // �������� ����� ��������� ����� ;
      '''withheld_sum'' TEXT,' +         // ����� ��������
      '''month_begin'' TEXT,' +          // ������ �� ������ ������
      '''pay_all'' TEXT,' +              // ����� � �������
      '''payments_fields'' TEXT,' +      // ������������ ����� ������ ����� ;
      '''payments_values'' TEXT,' +      // �������� ����� ������ ����� ;
      '''payments_sum'' TEXT,' +         // �����
      '''salary_hand'' TEXT,' +          // � ������ �� ����
      '''signed'' BOOLEAN DEFAULT FALSE,' + // ��������
      '''sign_time'' TIMESTAMP,' +          // ����\����� �������
      '''sign_pic'' BLOB' +                 // ����������� � ��������
      ')');

  SQLConnection.ExecSQL
    ('CREATE INDEX IF NOT EXISTS ''department_name'' ON ''DEPARTMENT'' (''name'' ASC)');
  SQLConnection.ExecSQL
    ('CREATE INDEX IF NOT EXISTS ''employee_department'' ON ''EMPLOYEE'' (''id_department'' ASC)');
  SQLConnection.ExecSQL
    ('CREATE INDEX IF NOT EXISTS ''employee_name'' ON ''EMPLOYEE'' (''name'' ASC)');
  SQLConnection.ExecSQL
    ('CREATE INDEX IF NOT EXISTS ''employee_id_user'' ON ''EMPLOYEE'' (''id_user'',''month'',''year'' ASC)');
  SQLConnection.ExecSQL
    ('CREATE INDEX IF NOT EXISTS ''employee_signed'' ON ''EMPLOYEE'' (''signed'' ASC)');
  SQLConnection.ExecSQL
    ('CREATE INDEX IF NOT EXISTS ''employee_month_year'' ON ''EMPLOYEE'' (''month'',''year'' DESC)');

end;

function TDM.OpenSQL(
  ASQL: String;
  AParamsProc: TParamsProc = nil;
  AGetQueryValueProc: TGetQueryValueProc = nil;
  AShowErrorProc: TShowErrorProc = nil;
  ARecsSkip: Integer = -1;
  ARecsMax: Integer = -1): Boolean;
var
  SQLQuery: TFDQuery;
begin
  Result := False;
  SQLQuery := GetNewQueryInstance;

  try
    if Assigned(SQLQuery) then
    begin
      try
        if SQLQuery.Active then
        begin
          SQLQuery.Close;
        end;
        SQLQuery.SQL.Text := ASQL;

        if Assigned(AParamsProc) then
        begin
          AParamsProc(SQLQuery);
        end;

        if (ARecsSkip <> -1) and (ARecsMax <> -1) then
        begin
          SQLQuery.FetchOptions.RecsSkip := ARecsSkip;
          SQLQuery.FetchOptions.RecsMax := ARecsMax;
        end;

        SQLQuery.Open;

        if not SQLQuery.Eof then
        begin
          Result := True;
          if Assigned(AGetQueryValueProc) then
          begin
            AGetQueryValueProc(SQLQuery);
          end;
        end;
      except
        on E: Exception do
        begin
          if Assigned(AShowErrorProc) then
          begin
            AShowErrorProc(E.Message + 'SQL: ' + ASQL);
          end
          else
          begin
            ShowMessage(E.Message);
          end;
        end;
      end;
    end;
  finally
    SQLQuery.Free;
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  FDBUpdateCriticalSection := TCriticalSection.Create;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  FDBUpdateCriticalSection.Create;
end;

procedure TDM.ExecSQL(
  ASQL: String; AParamsProc: TParamsProc = nil;
  AShowErrorProc: TShowErrorProc = nil);
var
  SQLQueryUpd: TFDQuery;
begin
  SQLQueryUpd := GetNewQueryInstance;

  try
    if Assigned(SQLQueryUpd) then
    begin
      try
        if SQLQueryUpd.Active then
        begin
          SQLQueryUpd.Close;
        end;
        SQLQueryUpd.SQL.Text := ASQL;

        if Assigned(AParamsProc) then
        begin
          AParamsProc(SQLQueryUpd);
        end;

        FDBUpdateCriticalSection.Enter;
        try
          SQLQueryUpd.ExecSQL;
        finally
          FDBUpdateCriticalSection.Leave;
        end;
      except
        on E: Exception do
        begin
          if Assigned(E) then
          begin
            if Assigned(AShowErrorProc) then
            begin
              AShowErrorProc(E.Message + 'SQL: ' + ASQL);
            end
            else
            begin
              ShowMessage(E.Message);
            end;
          end;
        end;
      end;
    end;
  finally
    SQLQueryUpd.Free;
  end;
end;

function TDM.GetNewQueryInstance: TFDQuery;
begin
  Result := TFDQuery.Create(Self);
  Result.Connection := SQLConnection;
  Result.Transaction := FDTransaction1;
  Result.UpdateTransaction := FDTransaction1;
end;

function TDM.GetOrAddDepartment(ADepartmentName: String): Integer;
var
  ID: Integer;
begin
  Result := 0;
  ID := 0;

  OpenSQL('select id from DEPARTMENT where name=:name',
   procedure(AADQuery: TFDQuery)
   begin
     AADQuery.ParamByName('name').AsString := ADepartmentName;
   end,
   procedure(AADQuery: TDataSet)
   begin
     ID := AADQuery.FieldByName('id').AsInteger;
   end);

   if ID <> 0 then
   begin
     Result := ID;
     Exit;
   end
   else
   begin
     ExecSQL('insert into DEPARTMENT (name) values (:name)',
       procedure(AADQuery: TFDQuery)
       begin
         AADQuery.ParamByName('name').AsString := ADepartmentName;
       end);

     ID := GetOrAddDepartment(ADepartmentName);
   end;
end;

procedure TDM.GetDepartments(SL: TStrings);
begin
  SL.Clear;
  OpenSQL('select name from DEPARTMENT order by name',
   nil,
   procedure(AADQuery: TDataSet)
   begin
     while not AADQuery.Eof do
     begin
       SL.Add(AADQuery.FieldByName('name').AsString);
       AADQuery.Next;
     end;
   end);
end;

procedure TDM.GetPeriods(SL: TStrings);
var
  MonthToStr: String;
begin
  SL.Clear;
  OpenSQL('select distinct month,year from EMPLOYEE order by year desc, month desc',
   nil,
   procedure(AADQuery: TDataSet)
   begin
     while not AADQuery.Eof do
     begin
       case AADQuery.FieldByName('month').AsInteger of
         1:  MonthToStr := '������';
         2:  MonthToStr := '�������';
         3:  MonthToStr := '����';
         4:  MonthToStr := '������';
         5:  MonthToStr := '���';
         6:  MonthToStr := '����';
         7:  MonthToStr := '����';
         8:  MonthToStr := '������';
         9:  MonthToStr := '��������';
         10: MonthToStr := '�������';
         11: MonthToStr := '������';
         12: MonthToStr := '�������';
       end;
       SL.Add(MonthToStr + ' ' + AADQuery.FieldByName('year').AsString + '�.');
       AADQuery.Next;
     end;
   end);
end;

procedure TDM.SaveEmployee(
  AMonth: String;
  AYear: String;
  AIDUser: String;
  AName: String;
  ADepartment: String;
  AUnknownType: TSalaryFieldsArray;
  AIncomeFields: TSalaryFieldsArray;
  AWithheldFields: TSalaryFieldsArray;
  APaymentsFields: TSalaryFieldsArray;
  AIncomeSum: TSalaryFieldData;
  AWithheldSum: TSalaryFieldData;
  AMonthBegin: TSalaryFieldData;
  APayAll: TSalaryFieldData;
  APaymentsSum: TSalaryFieldData;
  ASalaryHand: TSalaryFieldData);
var
  SQLStr: String;
begin
  if OpenSQL(
       'select id from EMPLOYEE where id_user=:id_user and month=:month and year=:year',
       procedure(AADQuery: TFDQuery)
       begin
         AADQuery.ParamByName('id_user').AsString := AIDUser;
         AADQuery.ParamByName('month').AsString := AMonth;
         AADQuery.ParamByName('year').AsString := AYear;
       end) then
  begin
    SQLStr := 'update EMPLOYEE set ' +

      'id_department=:id_department, name=:name, income_fields=:income_fields,' +
      'income_values=:income_values, income_sum=:income_sum, withheld_fields=:withheld_fields,' +
      'withheld_values=:withheld_values, withheld_sum=:withheld_sum, month_begin=:month_begin,' +
      'pay_all=:pay_all, payments_fields=:payments_fields, payments_values=:payments_values,' +
      'payments_sum=:payments_sum, salary_hand=:salary_hand' +

      ' where id_user=:id_user and month=:month and year=:year';
  end
  else
  begin
    SQLStr := 'insert into EMPLOYEE ' +
      '(id_user, name, id_department, month, year, income_fields, income_values,' +
      'income_sum, withheld_fields, withheld_values, withheld_sum, month_begin,' +
      'pay_all, payments_fields, payments_values, payments_sum, salary_hand)' +
      ' VALUES ' +
      '(:id_user, :name, :id_department, :month, :year, :income_fields, :income_values,' +
      ':income_sum, :withheld_fields, :withheld_values, :withheld_sum, :month_begin,' +
      ':pay_all, :payments_fields, :payments_values, :payments_sum, :salary_hand)';
  end;

  ExecSQL(SQLStr,
    procedure(AADQuery: TFDQuery)

      function GetSalaryFieldsArrayNames(ASalaryFieldsArray: TSalaryFieldsArray): String;
      var
        i: Integer;
      begin
         Result := '';
         if Length(ASalaryFieldsArray) > 0 then
         begin
           for I := Low(ASalaryFieldsArray) to High(ASalaryFieldsArray) do
           begin
             if Result = '' then
             begin
               Result := ASalaryFieldsArray[I].Name;
             end
             else
             begin
               Result := Result + ';' + ASalaryFieldsArray[I].Name;
             end;
           end;
         end;
      end;

      function GetSalaryFieldsArrayValues(ASalaryFieldsArray: TSalaryFieldsArray): String;
      var
        i: Integer;
      begin
         Result := '';
         if Length(ASalaryFieldsArray) > 0 then
         begin
           for I := Low(ASalaryFieldsArray) to High(ASalaryFieldsArray) do
           begin
             if Result = '' then
             begin
               Result := ASalaryFieldsArray[I].Value;
             end
             else
             begin
               Result := Result + ';' + ASalaryFieldsArray[I].Value;
             end;
           end;
         end;
      end;

    begin
     AADQuery.ParamByName('id_user').AsString := AIDUser;
     AADQuery.ParamByName('name').AsString := AName;
     AADQuery.ParamByName('id_department').AsInteger := GetOrAddDepartment(ADepartment);
     AADQuery.ParamByName('month').AsString := AMonth;
     AADQuery.ParamByName('year').AsString := AYear;
     AADQuery.ParamByName('income_sum').AsString := AIncomeSum.Value;
     AADQuery.ParamByName('withheld_sum').AsString := AWithheldSum.Value;
     AADQuery.ParamByName('month_begin').AsString := AMonthBegin.Value;
     AADQuery.ParamByName('pay_all').AsString := APayAll.Value;
     AADQuery.ParamByName('payments_sum').AsString := APaymentsSum.Value;
     AADQuery.ParamByName('salary_hand').AsString := ASalaryHand.Value;

     AADQuery.ParamByName('income_fields').AsString := GetSalaryFieldsArrayNames(AIncomeFields);
     AADQuery.ParamByName('income_values').AsString := GetSalaryFieldsArrayValues(AIncomeFields);

     AADQuery.ParamByName('withheld_fields').AsString := GetSalaryFieldsArrayNames(AWithheldFields);
     AADQuery.ParamByName('withheld_values').AsString := GetSalaryFieldsArrayValues(AWithheldFields);

     AADQuery.ParamByName('payments_fields').AsString := GetSalaryFieldsArrayNames(APaymentsFields);
     AADQuery.ParamByName('payments_values').AsString := GetSalaryFieldsArrayValues(APaymentsFields);
    end);
end;

end.

(*
<?xml version="1.0" encoding="utf-8"?>
<Salary>
	<period>
		<month>�����</month>
		<year>���</year>
	</period>
	<employees>
		<employee name="���" department="�������������">
			<fields>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   .....
			</fields>
		</employee>
		<employee name="���" department="�������������">
			<fields>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   .....
			</fields>
		</employee>
		<employee name="���" department="�������������">
			<fields>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   <field name="������������ ���� �� ������� �����" type="��� ���� (�������� ����)">�������� ����</field>
			   .....
			</fields>
		</employee>
		.......
	</employees>
<Salary>

���� �����:
0 - �� ���������� (����� ���� ����� ����� ������ ����)
1 - ���������� (����� ���� ����� ����� ������ ����)
2 - ����� ���������
3 - ��������� (����� ���� ����� ����� ������ ����)
4 - ����� ��������
5 - ������ �� ������ ������
6 - ����� � �������
7 - ����� ������������� ������� (����� ���� ����� ����� ������ ����)
8 - ����� �� ��������
9 - � ������ �� ����
*)
