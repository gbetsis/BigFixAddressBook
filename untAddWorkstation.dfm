object frmAddWorkstation: TfrmAddWorkstation
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #928#961#959#963#952#942#954#951' '#931#964#945#952#956#959#973' '#917#961#947#945#963#943#945#962
  ClientHeight = 203
  ClientWidth = 274
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
  object lblIPAddress: TLabel
    Left = 32
    Top = 75
    Width = 56
    Height = 13
    Caption = 'IP Address:'
  end
  object lblDetails: TLabel
    Left = 32
    Top = 115
    Width = 36
    Height = 13
    Caption = #931#967#972#955#953#945':'
  end
  object lblDepartment: TLabel
    Left = 32
    Top = 35
    Width = 47
    Height = 13
    Caption = #933#960#951#961#949#963#943#945':'
  end
  object edtIPAddress: TEdit
    Left = 94
    Top = 72
    Width = 145
    Height = 21
    TabOrder = 1
  end
  object edtDetails: TEdit
    Left = 94
    Top = 112
    Width = 145
    Height = 21
    TabOrder = 2
  end
  object cmbDepartment: TComboBox
    Left = 94
    Top = 32
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 0
  end
  object btnAdd: TButton
    Left = 32
    Top = 152
    Width = 97
    Height = 25
    Caption = #928#961#959#963#952#942#954#951
    Default = True
    TabOrder = 3
    OnClick = btnAddClick
  end
  object btnCancel: TButton
    Left = 143
    Top = 152
    Width = 96
    Height = 25
    Cancel = True
    Caption = #902#954#965#961#959
    TabOrder = 4
    OnClick = btnCancelClick
  end
end
