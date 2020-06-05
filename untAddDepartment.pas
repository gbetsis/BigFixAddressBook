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
    cmbParent: TComboBox;
    lblParent: TLabel;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
var
  intID : Integer;
begin
  if edtName.Text <> '' then
  begin
    if cmbParent.ItemIndex > 0 then
      intID := Tdepartment(cmbParent.Items.Objects[cmbParent.ItemIndex]).id
    else
      intID := 0;

    if btnAdd.Caption = 'Προσθήκη' then
    begin
      try
        frmMain.FDQuery.SQL.Text := 'INSERT INTO departments (name, parent_id) VALUES ("' + edtName.Text + '", ' + IntToStr(intID) + ');';
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
        frmMain.FDQuery.SQL.Text := 'UPDATE departments SET name = "' + edtName.Text + '", parent_id = ' + IntToStr(intID) + ' WHERE id = ' + IntToStr(tag) + ';';
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

procedure TfrmAddDepartment.FormCreate(Sender: TObject);
var
  department: Tdepartment;
begin
  frmMain.FDQuery.SQL.Text := 'SELECT id, name FROM departments ORDER BY name;';
  frmMain.FDQuery.Open;
  while not frmMain.FDQuery.Eof do
  begin
    //cmbDepartment.Items.Add(frmMain.FDQuery.Fields.Fields[0].AsString);
    department := Tdepartment.Create;
    department.id := frmMain.FDQuery.FieldByName('id').AsInteger;
    department.name := frmMain.FDQuery.FieldByName('name').AsString;
    cmbParent.AddItem(department.name, department);
    frmMain.FDQuery.Next;
  end;
  frmMain.FDQuery.Close;

end;

end.
