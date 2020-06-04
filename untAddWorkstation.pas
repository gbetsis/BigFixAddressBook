unit untAddWorkstation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmAddWorkstation = class(TForm)
    edtIPAddress: TEdit;
    edtDetails: TEdit;
    lblIPAddress: TLabel;
    lblDetails: TLabel;
    cmbDepartment: TComboBox;
    lblDepartment: TLabel;
    btnAdd: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAddWorkstation: TfrmAddWorkstation;

implementation

{$R *.dfm}

uses
  untMain;

procedure TfrmAddWorkstation.btnAddClick(Sender: TObject);
begin
  if ((cmbDepartment.Text <> '') AND (edtIPAddress.Text <> '')) then
  begin
    if btnAdd.Caption = 'Προσθήκη' then
    begin
      frmMain.FDQuery.Close;
      frmMain.FDQuery.SQL.Text := 'SELECT id FROM workstations WHERE ipaddress = "' + edtIPAddress.Text + '";';
      frmMain.FDQuery.Open;
      if frmMain.FDQuery.RecordCount > 0 then
      begin
        ShowMessage('Υπάρχει ήδη Σταθμός Εργασίας καταχωρημένος, με την ίδια IP διεύθυνση.');
        frmMain.FDQuery.Close;
      end
      else
      begin
        frmMain.FDQuery.Close;
        frmMain.FDQuery.SQL.Text := 'INSERT INTO workstations (ipaddress, detail, department) VALUES ("' + edtIPAddress.Text + '", "' + edtDetails.Text + '", ' + IntToStr(Integer(cmbDepartment.Items.Objects[cmbDepartment.ItemIndex])) + ');';
        frmMain.FDQuery.ExecSQL;
        ModalResult := mrOk;
      end;
    end
    else if btnAdd.Caption = 'Αποθήκευση' then
    begin
      frmMain.FDQuery.SQL.Text := 'UPDATE workstations SET ipaddress = "' + edtIPAddress.Text + '", detail = "' + edtDetails.Text + '", department = ' + IntToStr(Integer(cmbDepartment.Items.Objects[cmbDepartment.ItemIndex])) + ' WHERE id = ' + IntToStr(frmAddWorkstation.Tag) + ';';
      frmMain.FDQuery.ExecSQL;
      ModalResult := mrOk;
    end;

  end
  else
  begin
    ShowMessage('Πρέπει να καταχωρήσετε και Υπηρεσία και IP διεύθυνση');
  end;
end;

procedure TfrmAddWorkstation.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmAddWorkstation.FormCreate(Sender: TObject);
begin
  frmMain.FDQuery.SQL.Text := 'SELECT id, name FROM departments ORDER BY name;';
  frmMain.FDQuery.Open;
  while not frmMain.FDQuery.Eof do
  begin
    //cmbDepartment.Items.Add(frmMain.FDQuery.Fields.Fields[0].AsString);
    cmbDepartment.AddItem(frmMain.FDQuery.Fields.Fields[1].AsString, TObject(frmMain.FDQuery.Fields.Fields[0].AsInteger));
    frmMain.FDQuery.Next;
  end;
  frmMain.FDQuery.Close;

end;

end.
