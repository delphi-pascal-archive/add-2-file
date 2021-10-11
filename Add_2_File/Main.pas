unit Main;

interface

uses
  Windows, SysUtils, Controls, Forms, Dialogs, StdCtrls, Add2FileUtils, Classes, ExtCtrls;

type
  TLargeString = array [0..65535] of Char; { Pour la démo, on se limite à 65536 caractères ... }
  { Comme les buffers sont non-typés, vous pouvez écrire ce que vous voulez ! }

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
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;
  F: HFILE=0; { Contient le descripteur du fichier en cours de modification (par défaut 0) }

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
   DeleteBtn.Enabled := False; { On désactive tous les boutons pour l'instant }
   DataMemo.Text := '';
   DataMemo.Enabled := False;
   FileLbl.Caption := '[Aucun fichier sélectionné]';
   if F <> 0 then CloseHandle(F); { On ferme le fichier précédent }
   F := OpenFile(PChar(OpenDlg.FileName), Tmp, OF_READWRITE); { On ouvre le nouveau fichier }
   { Si erreur d'ouverture du nouveau fichier, message + sortie de procédure }
   if F = HFILE_ERROR then raise Exception.Create('Impossible d''ouvrir le fichier !');
   { Si tout s'est bien passé, on remplit le mémo des données ajoutées et on active tout }
   FileLbl.Caption := ExtractFileName(OpenDlg.FileName);
   ReadFileAdd(F, S, Tmp2);
   DataMemo.Text := S;
   WriteBtn.Enabled := True;
   DeleteBtn.Enabled := True;
   DataMemo.Enabled := True; { Si pas de données ajoutées, on affiche un petit message. }
   if DataMemo.Text = '' then MessageDlg('Ce fichier ne comporte aucune donnée ajoutée.' + chr(13) + 'Vous pouvez en ajouter en tapant la donnée dans la zone de saisie, et en cliquant sur "Ajouter ces données".' + chr(13) + 'Pour supprimer toutes les données ajoutées du fichier, cliquez sur "Supprimer toutes les données".', mtInformation, [mbOK], 0);
  end;
end;

procedure TMainForm.WriteBtnClick(Sender: TObject);
Var
 S: TLargeString;
 I: Integer;
 Size: Integer;
begin
 { On interdit l'écriture d'un texte vide (car sinon, WriteFileAdd renvoie False, puis message plus méchant après). }
 if DataMemo.Text = '' then raise Exception.Create('Vous ne pouvez pas ajouter une donnée nulle.');
 { On limite la taille du texte }
 if Length(DataMemo.Text) > SizeOf(TLargeString) then DataMemo.Text := Copy(DataMemo.Text, 0, SizeOf(TLargeString));
 { On enlève les dernières données ajoutées ... }
 ClearFileAdd(F);
 { On convertit le texte du mémo en TLargeString }
 Size := 0;
 for I := 1 to SizeOf(S) do
  begin
   if I <= Length(DataMemo.Text) then S[I - 1] := DataMemo.Text[I] else S[I - 1] := #0;
   Inc(Size); { On augmente la taille en octets de 1 }
  end;
 { On tente d'écrire (message si erreur) }
 if not WriteFileAdd(F, S, Size) then raise Exception.Create('Erreur lors de l''écriture des données ajoutées !');
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
 ClearFileAdd(F); { On vide toutes les données ajoutées }
 ReadFileAdd(F, S, Tmp); { On affiche les données ajoutées dans le mémo (normalement, vide) }
 DataMemo.Text := S;
end;

procedure TMainForm.ToReadBtnClick(Sender: TObject);
resourcestring { Petit texte mis en mémoire (pour éviter de mettre tout ça dans MessageDlg) }
 ToReadStr = 'Notez que le programme vérifie si des données ajoutées' +
             ' sont présentes grâce à une signature (ici "ADDA"). Si cette' +
             ' signature n''est pas présente, le programme considérera qu''il' +
             ' n''y a pas de données ajoutées, et écrira donc ces dernières à la suite.' +
             chr(13) +
             'Lorsque vous compressez votre fichier, il est probable que la signature' +
             'soit altérée. Dans ce cas-là, ne réécrivez pas de données sur le fichier compressé, ' +
             'mais lisez plutôt les données une fois le fichier décompressé pour éviter que les' +
             ' données du ' + 'fichier compressé chevauchent les données de ce même' +
             ' fichier lorsqu''il n''était pas compressé. Ceci ne s''applique pas aux fichiers' +
             ' zippés (compressés et réunis en un seul fichier).' +
             chr(13) +
             'Notez que certains types de fichiers peuvent être endommagés par l''écriture des données ' +
             'ajoutées. Ceci pour la raison que certains fichiers n''enregistrent pas la taille de leurs ' +
             'données mais lisent plutôt les données jusqu''à la fin du fichier (là où se trouvent les ' +
             'données ajoutées). Cependant, ces types de fichiers sont bien rares !';
begin
 MessageDlg(ToReadStr, mtInformation, [mbOK], 0); { On affiche le petit texte }
end;

end.
