object frmAddDepartment: TfrmAddDepartment
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #928#961#959#963#952#942#954#951' '#933#960#951#961#949#963#943#945#962
  ClientHeight = 203
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblName: TLabel
    Left = 82
    Top = 59
    Width = 37
    Height = 13
    Caption = #908#957#959#956#945':'
  end
  object lblParent: TLabel
    Left = 8
    Top = 99
    Width = 111
    Height = 13
    Caption = #928#961#959#970#963#964#940#956#949#957#951' '#933#960#951#961#949#963#943#945':'
  end
  object btnCancel: TButton
    Left = 143
    Top = 152
    Width = 96
    Height = 25
    Cancel = True
    Caption = #902#954#965#961#959
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnAdd: TButton
    Left = 32
    Top = 152
    Width = 97
    Height = 25
    Caption = #928#961#959#963#952#942#954#951
    Default = True
    TabOrder = 1
    OnClick = btnAddClick
  end
  object edtName: TEdit
    Left = 125
    Top = 56
    Width = 145
    Height = 21
    TabOrder = 0
  end
  object cmbParent: TComboBox
    Left = 125
    Top = 96
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 3
  end
end
