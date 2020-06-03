unit untAddDepartment;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmAddDepartment = class(TForm)
    btnCancel: TButton;
    btnAdd: TButton;
    lblName: TLabel;
    edtName: TEdit;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAddDepartment: TfrmAddDepartment;

implementation

{$R *.dfm}

uses
  untMain;

procedure TfrmAddDepartment.btnAddClick(Sender: TObject);
begin
  if edtName.Text <> '' then
  begin

    if btnAdd.Caption = 'Προσθήκη' then
    begin
      try
        frmMain.FDQuery.SQL.Text := 'INSERT INTO departments (name) VALUES ("' + edtName.Text + '");';
        frmMain.FDQuery.ExecSQL;
        frmAddDepartment.Close;
      except
        ShowMessage('Σφάλμα κατά την προσθήκη της Υπηρεσίας');
      end;
      ModalResult := mrOk;
    end
    else if btnAdd.Caption = 'Αποθήκευση' then
    begin
      try
        frmMain.FDQuery.SQL.Text := 'UPDATE departments SET name = "' + edtName.Text + '" WHERE id = ' + IntToStr(tag) + ';';
        frmMain.FDQuery.ExecSQL;
        frmAddDepartment.Close;
      except
        ShowMessage('Σφάλμα κατά την αποθήκευση της Υπηρεσίας');
      end;
      ModalResult := mrOk;
    end;

  end
  else
  begin
    ShowMessage('Μη έγκυρη καταχώρηση');
  end;
end;

procedure TfrmAddDepartment.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
