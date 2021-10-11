unit Main;

interface

uses
  Windows, SysUtils, Controls, Forms, Dialogs, StdCtrls, Add2FileUtils, Classes, ExtCtrls;

type
  TLargeString = array [0..65535] of Char; { Pour la d�mo, on se limite � 65536 caract�res ... }
  { Comme les buffers sont non-typ�s, vous pouvez �crire ce que vous voulez ! }

  TMainForm = class(TForm)
    BrowseBtn: TButton;
    FileLbl: TLabel;
    OpenDlg: TOpenDialog;
    SepBevel: TBevel;
    DataMemo: TMemo;
    WriteBtn: TButton;
    DeleteBtn: TButton;
    QuitBtn: TButton;
    ToReadBtn: TButton;
    procedure BrowseBtnClick(Sender: TObject);
    procedure WriteBtnClick(Sender: TObject);
    procedure QuitBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DeleteBtnClick(Sender: TObject);
    procedure ToReadBtnClick(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  MainForm: TMainForm;
  F: HFILE=0; { Contient le descripteur du fichier en cours de modification (par d�faut 0) }

implementation

{$R *.dfm}

procedure TMainForm.BrowseBtnClick(Sender: TObject);
Var
 Tmp: OFSTRUCT;
 Tmp2: Longword;
 S: TLargeString;
begin
 if OpenDlg.Execute then
  begin
   WriteBtn.Enabled := False;
   DeleteBtn.Enabled := False; { On d�sactive tous les boutons pour l'instant }
   DataMemo.Text := '';
   DataMemo.Enabled := False;
   FileLbl.Caption := '[Aucun fichier s�lectionn�]';
   if F <> 0 then CloseHandle(F); { On ferme le fichier pr�c�dent }
   F := OpenFile(PChar(OpenDlg.FileName), Tmp, OF_READWRITE); { On ouvre le nouveau fichier }
   { Si erreur d'ouverture du nouveau fichier, message + sortie de proc�dure }
   if F = HFILE_ERROR then raise Exception.Create('Impossible d''ouvrir le fichier !');
   { Si tout s'est bien pass�, on remplit le m�mo des donn�es ajout�es et on active tout }
   FileLbl.Caption := ExtractFileName(OpenDlg.FileName);
   ReadFileAdd(F, S, Tmp2);
   DataMemo.Text := S;
   WriteBtn.Enabled := True;
   DeleteBtn.Enabled := True;
   DataMemo.Enabled := True; { Si pas de donn�es ajout�es, on affiche un petit message. }
   if DataMemo.Text = '' then MessageDlg('Ce fichier ne comporte aucune donn�e ajout�e.' + chr(13) + 'Vous pouvez en ajouter en tapant la donn�e dans la zone de saisie, et en cliquant sur "Ajouter ces donn�es".' + chr(13) + 'Pour supprimer toutes les donn�es ajout�es du fichier, cliquez sur "Supprimer toutes les donn�es".', mtInformation, [mbOK], 0);
  end;
end;

procedure TMainForm.WriteBtnClick(Sender: TObject);
Var
 S: TLargeString;
 I: Integer;
 Size: Integer;
begin
 { On interdit l'�criture d'un texte vide (car sinon, WriteFileAdd renvoie False, puis message plus m�chant apr�s). }
 if DataMemo.Text = '' then raise Exception.Create('Vous ne pouvez pas ajouter une donn�e nulle.');
 { On limite la taille du texte }
 if Length(DataMemo.Text) > SizeOf(TLargeString) then DataMemo.Text := Copy(DataMemo.Text, 0, SizeOf(TLargeString));
 { On enl�ve les derni�res donn�es ajout�es ... }
 ClearFileAdd(F);
 { On convertit le texte du m�mo en TLargeString }
 Size := 0;
 for I := 1 to SizeOf(S) do
  begin
   if I <= Length(DataMemo.Text) then S[I - 1] := DataMemo.Text[I] else S[I - 1] := #0;
   Inc(Size); { On augmente la taille en octets de 1 }
  end;
 { On tente d'�crire (message si erreur) }
 if not WriteFileAdd(F, S, Size) then raise Exception.Create('Erreur lors de l''�criture des donn�es ajout�es !');
end;

procedure TMainForm.QuitBtnClick(Sender: TObject);
begin
 Close; { On ferme l'application }
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if F <> 0 then CloseHandle(F); { Si on a ouvert un fichier, on le ferme avant de quitter }
end;

procedure TMainForm.DeleteBtnClick(Sender: TObject);
Var
 S: TLargeString;
 Tmp: Longword;
begin
 ClearFileAdd(F); { On vide toutes les donn�es ajout�es }
 ReadFileAdd(F, S, Tmp); { On affiche les donn�es ajout�es dans le m�mo (normalement, vide) }
 DataMemo.Text := S;
end;

procedure TMainForm.ToReadBtnClick(Sender: TObject);
resourcestring { Petit texte mis en m�moire (pour �viter de mettre tout �a dans MessageDlg) }
 ToReadStr = 'Notez que le programme v�rifie si des donn�es ajout�es' +
             ' sont pr�sentes gr�ce � une signature (ici "ADDA"). Si cette' +
             ' signature n''est pas pr�sente, le programme consid�rera qu''il' +
             ' n''y a pas de donn�es ajout�es, et �crira donc ces derni�res � la suite.' +
             chr(13) +
             'Lorsque vous compressez votre fichier, il est probable que la signature' +
             'soit alt�r�e. Dans ce cas-l�, ne r��crivez pas de donn�es sur le fichier compress�, ' +
             'mais lisez plut�t les donn�es une fois le fichier d�compress� pour �viter que les' +
             ' donn�es du ' + 'fichier compress� chevauchent les donn�es de ce m�me' +
             ' fichier lorsqu''il n''�tait pas compress�. Ceci ne s''applique pas aux fichiers' +
             ' zipp�s (compress�s et r�unis en un seul fichier).' +
             chr(13) +
             'Notez que certains types de fichiers peuvent �tre endommag�s par l''�criture des donn�es ' +
             'ajout�es. Ceci pour la raison que certains fichiers n''enregistrent pas la taille de leurs ' +
             'donn�es mais lisent plut�t les donn�es jusqu''� la fin du fichier (l� o� se trouvent les ' +
             'donn�es ajout�es). Cependant, ces types de fichiers sont bien rares !';
begin
 MessageDlg(ToReadStr, mtInformation, [mbOK], 0); { On affiche le petit texte }
end;

end.
