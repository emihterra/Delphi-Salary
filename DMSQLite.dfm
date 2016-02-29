object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 321
  Width = 222
  object SQLConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=C:\MyProjects\Delphi\TerraSalary\Win32\Debug\terra.db')
    Transaction = FDTransaction1
    UpdateTransaction = FDTransaction1
    Left = 40
    Top = 32
  end
  object QueryEmployees: TFDQuery
    Connection = SQLConnection
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckDynamic
    SQL.Strings = (
      'select * from employee')
    Left = 136
    Top = 32
    object QueryEmployeesid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object QueryEmployeesid_department: TIntegerField
      FieldName = 'id_department'
      Origin = 'id_department'
    end
    object QueryEmployeesname: TWideMemoField
      FieldName = 'name'
      Origin = 'name'
      BlobType = ftWideMemo
    end
    object QueryEmployeesid_user: TWideMemoField
      FieldName = 'id_user'
      Origin = 'id_user'
      BlobType = ftWideMemo
    end
    object QueryEmployeesmonth: TWideMemoField
      FieldName = 'month'
      Origin = 'month'
      BlobType = ftWideMemo
    end
    object QueryEmployeesyear: TWideMemoField
      FieldName = 'year'
      Origin = 'year'
      BlobType = ftWideMemo
    end
    object QueryEmployeesincome_fields: TWideMemoField
      FieldName = 'income_fields'
      Origin = 'income_fields'
      BlobType = ftWideMemo
    end
    object QueryEmployeesincome_values: TWideMemoField
      FieldName = 'income_values'
      Origin = 'income_values'
      BlobType = ftWideMemo
    end
    object QueryEmployeesincome_sum: TWideMemoField
      FieldName = 'income_sum'
      Origin = 'income_sum'
      BlobType = ftWideMemo
    end
    object QueryEmployeeswithheld_fields: TWideMemoField
      FieldName = 'withheld_fields'
      Origin = 'withheld_fields'
      BlobType = ftWideMemo
    end
    object QueryEmployeeswithheld_values: TWideMemoField
      FieldName = 'withheld_values'
      Origin = 'withheld_values'
      BlobType = ftWideMemo
    end
    object QueryEmployeeswithheld_sum: TWideMemoField
      FieldName = 'withheld_sum'
      Origin = 'withheld_sum'
      BlobType = ftWideMemo
    end
    object QueryEmployeesmonth_begin: TWideMemoField
      FieldName = 'month_begin'
      Origin = 'month_begin'
      BlobType = ftWideMemo
    end
    object QueryEmployeespay_all: TWideMemoField
      FieldName = 'pay_all'
      Origin = 'pay_all'
      BlobType = ftWideMemo
    end
    object QueryEmployeespayments_fields: TWideMemoField
      FieldName = 'payments_fields'
      Origin = 'payments_fields'
      BlobType = ftWideMemo
    end
    object QueryEmployeespayments_values: TWideMemoField
      FieldName = 'payments_values'
      Origin = 'payments_values'
      BlobType = ftWideMemo
    end
    object QueryEmployeespayments_sum: TWideMemoField
      FieldName = 'payments_sum'
      Origin = 'payments_sum'
      BlobType = ftWideMemo
    end
    object QueryEmployeessalary_hand: TWideMemoField
      FieldName = 'salary_hand'
      Origin = 'salary_hand'
      BlobType = ftWideMemo
    end
    object QueryEmployeessigned: TBooleanField
      FieldName = 'signed'
      Origin = 'signed'
    end
    object QueryEmployeessign_time: TSQLTimeStampField
      FieldName = 'sign_time'
      Origin = 'sign_time'
    end
    object QueryEmployeessign_pic: TBlobField
      FieldName = 'sign_pic'
      Origin = 'sign_pic'
    end
  end
  object FDTransaction1: TFDTransaction
    Connection = SQLConnection
    Left = 40
    Top = 96
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 40
    Top = 168
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 136
    Top = 96
  end
end
