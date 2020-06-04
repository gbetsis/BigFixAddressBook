unit untMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, untAddWorkstation, untAddDepartment,
  Vcl.Menus, Data.DbxSqlite, Data.FMTBcd, Data.DB, Data.SqlExpr,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Generics.Collections,
  System.Actions, Vcl.ActnList, ShellApi, ShlObj, System.ImageList, Vcl.ImgList, untPing, ActiveX;

type
  TfrmMain = class(TForm)
    treMain: TTreeView;
    mnuMain: TMainMenu;
    mnuFile: TMenuItem;
    mnuHelp: TMenuItem;
    mnuEdit: TMenuItem;
    mnuExit: TMenuItem;
    mnuAddDepartment: TMenuItem;
    mnuAddWorkStation: TMenuItem;
    mnuAbout: TMenuItem;
    N1: TMenuItem;
    FDConnection: TFDConnection;
    FDQuery: TFDQuery;
    btnConnect: TButton;
    mnuTreeView: TPopupMenu;
    mnuPopupConnect: TMenuItem;
    N2: TMenuItem;
    mnuPopupEdit: TMenuItem;
    mnuPopupDelete: TMenuItem;
    actlstMain: TActionList;
    actConnect: TAction;
    imgTree: TImageList;
    lblPCSN: TLabel;
    edtPCSN: TEdit;
    lblMonitorSN: TLabel;
    edtMonitorSN: TEdit;
    lblKeyboardSN: TLabel;
    edtKeyboardSN: TEdit;
    lblMouseSN: TLabel;
    edtMouseSN: TEdit;
    lblDetails: TLabel;
    edtDetails: TEdit;
    edtIPAddress: TEdit;
    lblIPAddress: TLabel;
    grpWorkstation: TGroupBox;
    btnSave: TButton;
    btnCancel: TButton;
    procedure mnuAddDepartmentClick(Sender: TObject);
    procedure mnuAddWorkStationClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PopulateTreeView(Sender: TObject);
    procedure treMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actConnectExecute(Sender: TObject);
    procedure mnuPopupEditClick(Sender: TObject);
    procedure mnuPopupDeleteClick(Sender: TObject);
    procedure treMainChange(Sender: TObject; Node: TTreeNode);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure treMainDblClick(Sender: TObject);
    procedure edtIPAddressChange(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edtDetailsChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtPCSNChange(Sender: TObject);
    procedure edtMonitorSNChange(Sender: TObject);
    procedure edtKeyboardSNChange(Sender: TObject);
    procedure edtMouseSNChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TMyWorkerThread = class(TThread)
    ipaddress: String;
    intNodeIndex: Integer;
  public
    procedure Execute; override;
    constructor Create; overload;
    constructor Create(ipaddress: String; intNodeIndex: Integer); overload;
  end;

  TworkStation = class(TObject)
    id: Integer;
    ipaddress: String;
    detail: String;
    department_id: Integer;
    sn_pc: String;
    sn_monitor: String;
    sn_keyboard: String;
    sn_mouse: String;
  end;

  Tdepartment = class(TObject)
    id: Integer;
    name: String;
    parent_id: Integer;
  end;
var
  frmMain: TfrmMain;
  strProgramFiles : String;
  booChangingWorkstaionFields: Boolean;

implementation

{$R *.dfm}

constructor TMyWorkerThread.Create;
begin
  inherited;
//  Self.ipaddress := ipaddress;
end;

constructor TMyWorkerThread.Create(ipaddress: String; intNodeIndex: Integer);
begin
  inherited Create;
  Self.ipaddress := ipaddress;
  Self.intNodeIndex := intNodeIndex;
end;

//Usage: TMyWorkerThread.Create(false);
procedure TMyWorkerThread.Execute;
var
  PacketsReceived, Minimum, Maximum, Average: Integer;
begin
  //Here we do work
 CoInitialize(nil);
 try
       if Ping(Self.ipaddress, 3, 25, 500, PacketsReceived, Minimum, Maximum, Average) then
       begin
          frmMain.treMain.Items[Self.intNodeIndex].ImageIndex := 3;
          frmMain.treMain.Items[Self.intNodeIndex].SelectedIndex := 3;
       end
       else
       begin
          frmMain.treMain.Items[Self.intNodeIndex].ImageIndex := 4;
          frmMain.treMain.Items[Self.intNodeIndex].SelectedIndex := 4;
       end;

  //When we exit the procedure, the thread ends.
  //So we don't exit until we're done.
 finally
    CoUninitialize;
 end;
end;

procedure TfrmMain.PopulateTreeView(Sender: TObject);
var
  RootNode, WSNode, tmpNode, DeptNode: TTreeNode;
  workStation: TworkStation;
  department: Tdepartment;
  intNodeIndex : Integer;
begin
  //Save the currently selected node index, so we can focus to it, after the refresh.
  if treMain.Items.Count > 0 then
  begin
    if treMain.Selected.AbsoluteIndex = treMain.Items.Count - 1 then
      intNodeIndex := -1
    else
      intNodeIndex := treMain.Selected.AbsoluteIndex;
  end
  else
    intNodeIndex := -1;

  treMain.Items.Clear;
  // SELECT ipaddress, detail, department, departments.id AS department_id, departments.name AS department_name FROM workstations JOIN departments ON department = departments.id;
  RootNode := treMain.Items.Add(nil, 'BigFixAddressBook');
  RootNode.ImageIndex := 0;
  RootNode.SelectedIndex := 0;

  FDQuery.SQL.Text := 'SELECT id, name, parent_id FROM departments ORDER BY parent_id, id;';
  FDQuery.Open;

  while not FDQuery.Eof do
  begin
    //cmbDepartment.Items.Add(frmMain.FDQuery.Fields.Fields[0].AsString);
    //cmbDepartment.AddItem(FDQuery.Fields.Fields[1].AsString, TObject(FDQuery.Fields.Fields[0].AsInteger));
    department := Tdepartment.Create;
    department.id := FDQuery.Fields.FieldByName('id').AsInteger;
    department.name := FDQuery.Fields.FieldByName('name').AsString;
    department.parent_id := FDQuery.Fields.FieldByName('parent_id').AsInteger;
    if department.parent_id <> 0 then
    begin
      for tmpNode in treMain.Items do
      begin
        if TObject(tmpNode.Data) Is Tdepartment then
        begin
            if department.parent_id = Tdepartment(tmpNode.Data).id then
            begin
              DeptNode := treMain.Items.AddChildObject(tmpNode, department.name, department);
              DeptNode.ImageIndex := 1;
              DeptNode.SelectedIndex := 1;
              Break;
            end;
        end;
      end;
    end
    else
    begin
      DeptNode := treMain.Items.AddChildObject(RootNode, department.name, department);
      DeptNode.ImageIndex := 1;
      DeptNode.SelectedIndex := 1;
    end;
    //CurrentDepartment := department.id;
    FDQuery.Next;
  end;

  FDQuery.Close;

  FDQuery.SQL.Text := 'SELECT id, ipaddress, detail, department, sn_pc, sn_monitor, sn_keyboard, sn_mouse FROM workstations ORDER BY ipaddress;';
  FDQuery.Open;

  while not FDQuery.Eof do
  begin
    //cmbDepartment.Items.Add(frmMain.FDQuery.Fields.Fields[0].AsString);
    //cmbDepartment.AddItem(FDQuery.Fields.Fields[1].AsString, TObject(FDQuery.Fields.Fields[0].AsInteger));
    workStation := TWorkStation.Create;
    workStation.id := FDQuery.Fields.FieldByName('id').AsInteger;
    workStation.ipaddress := FDQuery.Fields.FieldByName('ipaddress').AsString;
    workStation.detail := FDQuery.Fields.FieldByName('detail').AsString;
    workStation.department_id := FDQuery.Fields.FieldByName('department').AsInteger;
    workStation.sn_pc := FDQuery.Fields.FieldByName('sn_pc').AsString;
    workStation.sn_monitor := FDQuery.Fields.FieldByName('sn_monitor').AsString;
    workStation.sn_keyboard := FDQuery.Fields.FieldByName('sn_keyboard').AsString;
    workStation.sn_mouse := FDQuery.Fields.FieldByName('sn_mouse').AsString;

    for tmpNode in treMain.Items do
    begin
      if TObject(tmpNode.Data) Is Tdepartment then
      begin
          if workStation.department_id = Tdepartment(tmpNode.Data).id then
          begin
            WSNode := treMain.Items.AddChildObject(tmpNode, workStation.ipaddress, workStation);
            WSNode.ImageIndex := 2;
            WSNode.SelectedIndex := 2;
            Break;
          end;
      end;
    end;

    FDQuery.Next;
  end;

  FDQuery.Close;

  RootNode.Expand(False);
  //treMain.Select(tmpTreeNode);

  if intNodeIndex >= 0 then
  begin
    treMain.Select(treMain.Items[intNodeIndex]);
  end;

end;

procedure TfrmMain.treMainChange(Sender: TObject; Node: TTreeNode);
var
  workStation: TworkStation;
begin

  if Node.Level = 0 then
  begin
    btnConnect.Enabled := False;
    mnuPopupConnect.Enabled := False;
    mnuPopupEdit.Enabled := False;
    mnuPopupDelete.Enabled := False;

    grpWorkstation.Enabled := False;
    grpWorkstation.Visible := False;
  end
  else if TObject(Node.Data) Is Tdepartment then
  begin
    btnConnect.Enabled := False;
    mnuPopupConnect.Enabled := False;
    mnuPopupEdit.Enabled := True;
    if Node.Count = 0 then
      mnuPopupDelete.Enabled := True
    else
      mnuPopupDelete.Enabled := False;

    grpWorkstation.Enabled := False;
    grpWorkstation.Visible := False;
  end
  else if TObject(Node.Data) Is TWorkStation then
  begin
    btnConnect.Enabled := True;
    mnuPopupConnect.Enabled := True;
    mnuPopupEdit.Enabled := True;
    mnuPopupDelete.Enabled := True;

    workStation := TworkStation(Node.Data);
    booChangingWorkstaionFields := True;
    edtIPAddress.Text := workStation.ipaddress;
    edtDetails.Text := workStation.detail;
    edtPCSN.Text := workStation.sn_pc;
    edtMonitorSN.Text := workStation.sn_monitor;
    edtKeyboardSN.Text := workStation.sn_keyboard;
    edtMouseSN.Text := workStation.sn_mouse;
    booChangingWorkstaionFields := False;
    btnSave.Enabled := False;
    btnCancel.Enabled := False;
    grpWorkstation.Enabled := True;
    grpWorkstation.Visible := True;
    grpWorkstation.Tag := workStation.id;
    TMyWorkerThread.Create(workStation.ipaddress, Node.AbsoluteIndex);

  end;


end;

procedure TfrmMain.treMainDblClick(Sender: TObject);
var
  tmpNode: TTreeNode;
begin
  with treMain.ScreenToClient(Mouse.CursorPos) do
    tmpNode := treMain.GetNodeAt(X, Y);

  if (tmpNode <> nil) and (TObject(tmpNode.Data) Is TWorkStation) then
    //ShowMessage(IntToStr(tmpNode.AbsoluteIndex));
    actConnectExecute(Self);

end;

procedure TfrmMain.treMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Item: TTreeNode;
begin
  Item := treMain.GetNodeAt(X, Y);
  if Assigned(Item) then Item.Selected := True;

end;

procedure TfrmMain.actConnectExecute(Sender: TObject);
var
  workStation: TworkStation;
begin
  workStation := TworkStation(treMain.Selected.Data);
  //ShowMessage(workStation.ipaddress);

  // $PROGRAMFILES\IBM\Tivoli\Remote Control\Controller\jre\bin\javaw.exe
  // "-Djava.security.properties=D:\YDT Builds\RemoteControlBigFix\Remote Control\Controller\override.security"
  // -jar "D:\YDT Builds\RemoteControlBigFix\Remote Control\Controller\TRCConsole.jar" --host 10.176.5.203
  ShellExecute(Handle, 'open', PChar(strProgramFiles + '\IBM\Tivoli\Remote Control\Controller\jre\bin\javaw.exe'), PChar('"-Djava.security.properties=' + strProgramFiles + '\IBM\Tivoli\Remote Control\Controller\override.security" -jar "' + strProgramFiles + '\IBM\Tivoli\Remote Control\Controller\TRCConsole.jar" --host ' + workStation.ipaddress), nil, SW_SHOWNORMAL);
end;

function GetSpecialFolderPath(CSIDLFolder: Integer): string;
var
  FilePath: array [0..MAX_PATH] of char;
begin
  SHGetFolderPath(0, CSIDLFolder, 0, 0, FilePath);
  Result := FilePath;
end;

function FileSize(const aFilename: String): Int64;
var
  info: TWin32FileAttributeData;
begin
  result := -1;

  if NOT GetFileAttributesEx(PWideChar(aFileName), GetFileExInfoStandard, @info) then
    EXIT;

  result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

procedure TfrmMain.btnCancelClick(Sender: TObject);
var
  tmpNodeIndex: Integer;
begin
  tmpNodeIndex := treMain.Selected.AbsoluteIndex;
  treMain.Select(treMain.Items[0]);
  treMain.Select(treMain.Items[tmpNodeIndex]);
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  if (edtIPAddress.Text <> '') then
  begin
    try
      FDQuery.SQL.Text := 'UPDATE workstations SET ipaddress = "' + edtIPAddress.Text + '", detail = "' + edtDetails.Text + '", sn_pc = "' + edtPCSN.Text + '", sn_monitor = "' + edtMonitorSN.Text + '", sn_keyboard = "' + edtKeyboardSN.Text + '", sn_mouse = "' + edtMouseSN.Text + '" WHERE id = ' + IntToStr(grpWorkstation.Tag) + ';';
      FDQuery.ExecSQL;
      btnSave.Enabled := False;
      btnCancel.Enabled := False;
      PopulateTreeView(Self);
    except

    end;
  end;
end;

procedure TfrmMain.edtDetailsChange(Sender: TObject);
begin
  if not booChangingWorkstaionFields then
  begin
    btnSave.Enabled := True;
    btnCancel.Enabled := True;
  end;
end;

procedure TfrmMain.edtIPAddressChange(Sender: TObject);
begin
  if not booChangingWorkstaionFields then
  begin
    btnSave.Enabled := True;
    btnCancel.Enabled := True;
  end;
end;

procedure TfrmMain.edtKeyboardSNChange(Sender: TObject);
begin
  if not booChangingWorkstaionFields then
  begin
    btnSave.Enabled := True;
    btnCancel.Enabled := True;
  end;
end;

procedure TfrmMain.edtMonitorSNChange(Sender: TObject);
begin
  if not booChangingWorkstaionFields then
  begin
    btnSave.Enabled := True;
    btnCancel.Enabled := True;
  end;
end;

procedure TfrmMain.edtMouseSNChange(Sender: TObject);
begin
  if not booChangingWorkstaionFields then
  begin
    btnSave.Enabled := True;
    btnCancel.Enabled := True;
  end;
end;

procedure TfrmMain.edtPCSNChange(Sender: TObject);
begin
  if not booChangingWorkstaionFields then
  begin
    btnSave.Enabled := True;
    btnCancel.Enabled := True;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  strDBFileName : String;
  dbFileSize : LongInt;
  dbFile   : TextFile;
//  strAppDataFolder: String;
begin
  strProgramFiles := GetSpecialFolderPath(CSIDL_PROGRAM_FILES);
  //strAppDataFolder := GetSpecialFolderPath(CSIDL_COMMON_APPDATA);
  if not fileexists(strProgramFiles + '\IBM\Tivoli\Remote Control\Controller\jre\bin\javaw.exe') then
  begin
    ShowMessage('Δεν βρέθηκε εγκατεστημένο το BigFix Remote Control - Controller.');
    Application.Terminate;
  end;

  if fileexists(ExtractFilePath(Application.ExeName) + 'BigFixAddressBook.db') then
    strDBFileName := ExtractFilePath(Application.ExeName) + 'BigFixAddressBook.db'
  else
    strDBFileName := GetSpecialFolderPath(CSIDL_COMMON_APPDATA) + '\BigFixAddressBook\BigFixAddressBook.db';

  if fileexists(strDBFileName) then
  begin
    dbFileSize := FileSize(strDBFileName);
  end
  else
  begin
    dbFileSize := -1;
  end;

  if (not fileexists(strDBFileName)) or (dbFileSize = 0) then
  begin
    CreateDir(GetSpecialFolderPath(CSIDL_COMMON_APPDATA) + '\BigFixAddressBook');
    AssignFile(dbFile, strDBFileName);
    Rewrite(dbFile);
    CloseFile(dbFile);

    FDConnection.Params.Database := strDBFileName;
    FDConnection.Connected := True;
    FDQuery.Close;
    FDQuery.SQL.Clear;

    //Version 0.0.0.2
    //FDQuery.SQL.Add('CREATE TABLE "departments" ("id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, "name"	TEXT NOT NULL UNIQUE);');
    //FDQuery.SQL.Add('CREATE TABLE "workstations" ("id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, "ipaddress"	TEXT NOT NULL UNIQUE, "detail"	TEXT, "department"	INTEGER, FOREIGN KEY("department") REFERENCES "departments"("id"));');


    FDQuery.SQL.Add('CREATE TABLE "departments" ("id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, "name"	TEXT NOT NULL UNIQUE, "parent_id"	INTEGER NOT NULL);');
    FDQuery.SQL.Add('CREATE TABLE "workstations" ("id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, "ipaddress"	TEXT NOT NULL UNIQUE, "detail"	TEXT, "department" INTEGER, ' + '"sn_pc" TEXT, "sn_monitor" TEXT, "sn_keyboard" TEXT, "sn_mouse" TEXT, FOREIGN KEY("department") REFERENCES "departments"("id"));');
    FDQuery.ExecSQL;
  end
  else
  begin //Database exists.

    FDConnection.Params.Database := strDBFileName;
    FDConnection.Connected := True;

    // I will check to see if I need to upgrade departments table
    FDQuery.Close;
    FDQuery.SQL.Text := 'PRAGMA table_info(departments);';
    FDQuery.Open;
    if FDQuery.RecordCount = 2 then
    begin // I have detected old database version. I have to upgrade it.
      FDQuery.Close;
      FDQuery.SQL.Clear;
      FDQuery.SQL.Add('ALTER TABLE departments ADD parent_id INTEGER;');
      FDQuery.ExecSQL;
      FDQuery.Close;
    end;

    // I will check to see if I need to upgrade workstations table
    FDQuery.Close;
    FDQuery.SQL.Text := 'PRAGMA table_info(workstations);';
    FDQuery.Open;
    if FDQuery.RecordCount = 4 then
    begin // I have detected old database version. I have to upgrade it.
      FDQuery.Close;
      FDQuery.SQL.Clear;
      FDQuery.SQL.Add('ALTER TABLE workstations ADD "sn_pc" TEXT;');
      FDQuery.SQL.Add('ALTER TABLE workstations ADD "sn_monitor" TEXT;');
      FDQuery.SQL.Add('ALTER TABLE workstations ADD "sn_keyboard" TEXT;');
      FDQuery.SQL.Add('ALTER TABLE workstations ADD "sn_mouse" TEXT;');
      FDQuery.ExecSQL;
      FDQuery.Close;
    end;


  end;

  PopulateTreeView(Self);
  booChangingWorkstaionFields := False;
end;

procedure TfrmMain.mnuAboutClick(Sender: TObject);
begin
  ShowMessage('Version 0.0.0.2 beta');
end;

procedure TfrmMain.mnuAddDepartmentClick(Sender: TObject);
begin
  frmAddDepartment := TfrmAddDepartment.Create(Application);
  if frmAddDepartment.ShowModal = mrOK then
  begin
    //PopulateTreeView(Self);
    frmAddDepartment.Free;
  end
  else
  begin
    frmAddDepartment.Free;
  end;

end;

procedure TfrmMain.mnuAddWorkStationClick(Sender: TObject);
begin
  frmAddWorkstation := TfrmAddWorkstation.Create(Application);
  if frmAddWorkstation.ShowModal = mrOK then
  begin
    PopulateTreeView(Self);
    frmAddWorkstation.Free;
  end
  else
  begin
    frmAddWorkstation.Free;
  end;

end;

procedure TfrmMain.mnuExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.mnuPopupDeleteClick(Sender: TObject);
var
  workStation: TworkStation;
  department: Tdepartment;
begin
  if TObject(treMain.Selected.Data) Is TworkStation then
  begin
    workStation := TworkStation(treMain.Selected.Data);

    FDQuery.SQL.Text := 'DELETE FROM workstations WHERE id = ' + IntToStr(workStation.id) + ';';
    FDQuery.ExecSQL;
  end
  else
  if TObject(treMain.Selected.Data) Is Tdepartment then
  begin
    department := Tdepartment(treMain.Selected.Data);

    FDQuery.SQL.Text := 'DELETE FROM departments WHERE id = ' + IntToStr(department.id) + ';';
    FDQuery.ExecSQL;
  end;

  PopulateTreeView(Self);
end;

procedure TfrmMain.mnuPopupEditClick(Sender: TObject);
var
  workStation: TworkStation;
  department: Tdepartment;
begin
  if treMain.Selected.Level = 1 then
  begin
    department := Tdepartment(treMain.Selected.Data);

    frmAddDepartment := TfrmAddDepartment.Create(Application);
    frmAddDepartment.Tag := department.id;
    frmAddDepartment.edtName.Text := department.name;
    frmAddDepartment.btnAdd.Caption := 'Αποθήκευση';

    if frmAddDepartment.ShowModal = mrOK then
    begin
      PopulateTreeView(Self);
      frmAddDepartment.Free;
    end
    else
    begin
      frmAddDepartment.Free;
    end;
  end
  else if treMain.Selected.Level = 2 then
  begin
    workStation := TworkStation(treMain.Selected.Data);

    frmAddWorkstation := TfrmAddWorkstation.Create(Application);
    frmAddWorkstation.Tag := workStation.id;
    frmAddWorkstation.edtIPAddress.Text := workStation.ipaddress;
    frmAddWorkstation.edtDetails.Text := workStation.detail;
    //frmAddWorkstation.cmbDepartment.ItemIndex := frmAddWorkstation.cmbDepartment.Items.IndexOf(workStation.department_name);
    frmAddWorkstation.btnAdd.Caption := 'Αποθήκευση';

    if frmAddWorkstation.ShowModal = mrOK then
    begin
      PopulateTreeView(Self);
      frmAddWorkstation.Free;
    end
    else
    begin
      frmAddWorkstation.Free;
    end;
  end;



end;

end.
