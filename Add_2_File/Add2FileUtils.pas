unit Add2FileUtils;

interface

uses Windows; { Eh oui on a juste besoin de Windows - en dehors des unit�s System et compagnie ... }

type
  TQuadCharArray = array [0..3] of Char; { Taille : 4 octets, �quivalent d'un double mot }

  TFileAddHeader = record { Le header des donn�es ajout�es }
   Signature: TQuadCharArray; { La signature des donn�es - si elle ne correspond pas � AddSignature, on peut s'arr�ter }
   AddLength: Longword; { La taille des donn�es (la longueur de la cha�ne) }
  end;

const { La signature des donn�es ajout�es : doit figurer dans le header des donn�es ajout�es de ... }
  AddSignature: TQuadCharArray = ('A', 'D', 'D', 'A'); { ... chaque fichier qui en comporte.        }

{ ReadFileAdd lit les donn�es ajout�es d'un fichier - si elle renvoie Size 0, pas de donn�es }
function ReadFileAdd(F: HFILE; var Buffer; var Size: Longword): Boolean;
{ WriteFileAdd �crit les donn�es Buffer de taille Size dans un fichier F, et renvoie True si succ�s }
function WriteFileAdd(F: HFILE; const Buffer; Size: Longword): Boolean;
{ ClearFileAdd supprime toutes les donn�es ajout�es dans un fichier F, et renvoie True si succ�s }
{ Notez que un retour False ne signifie pas toujours une erreur (pas de donn�es ajout�es ...)    }
function ClearFileAdd(F: HFILE): Boolean;

implementation

function ReadFileAdd(F: HFILE; var Buffer; var Size: Longword): Boolean; { Lecture des donn�es ajout�es }
Var
 Header: TFileAddHeader;
 Tmp: Longword;
begin
 Result := False;
 { On se place � la fin du fichier pour �tre plus rapides }
 SetFilePointer(F, -SizeOf(TFileAddHeader), nil, FILE_END);
 { On lit le header des donn�es ajout�es }
 ReadFile(F, Header, SizeOf(Header), Tmp, nil);
 { On va maintenant lire les donn�es ajout�es }
 if Header.Signature <> AddSignature then Exit;
 { On lit la taille des donn�es }
 Size := Header.AddLength;
 { On se place au d�but des donn�es ajout�es }
 SetFilePointer(F, -SizeOf(TFileAddHeader) - Header.AddLength, nil, FILE_END);
 { On lit ! }
 ReadFile(F, Buffer, Size, Tmp, nil);
 Result := True;
end;

function WriteFileAdd(F: HFILE; const Buffer; Size: Longword): Boolean; { Ecriture des donn�es ajout�es }
Var
 Header: TFileAddHeader;
 Tmp: Longword;
begin
 Result := False;
 { Ne pas oublier de supprimer au pr�alable les anciennes donn�es : si elles sont plus volumineuses
   que les nouvelles, des art�facts seraient conserv�s ! }
 ClearFileAdd(F);
 { Si pas de buffer � �crire, on part tout de suite ! }
 if Size = 0 then Exit;
 { On va maintenant �crire les donn�es ajout�es }
 { On se place � la fin du fichier }
 SetFilePointer(F, 0, nil, FILE_END);
 { On �crit le buffer ... }
 WriteFile(F, Buffer, Size, Tmp, nil);
 { On remplit le header des donn�es ajout�es }
 Header.Signature := AddSignature;
 Header.AddLength := Size;
 { On se place � la fin du fichier pour �tre plus rapides }
 SetFilePointer(F, 0, nil, FILE_END);
 { On �crit le header des donn�es ajout�es }
 WriteFile(F, Header, SizeOf(Header), Tmp, nil);
 Result := True;
end;

function ClearFileAdd(F: HFILE): Boolean;       { Suppression des donn�es ajout�es }
Var
 Header: TFileAddHeader;
 Tmp: Longword;
begin
 Result := False;
 { On se place � la fin du fichier, et on lit le header }
 SetFilePointer(F, -SizeOf(TFileAddHeader), nil, FILE_END);
 { On lit le header des donn�es ajout�es }
 ReadFile(F, Header, SizeOf(Header), Tmp, nil);
 { On v�rifie qu'il y ait bien des donn�es ajout�es }
 if Header.Signature <> AddSignature then Exit;
 { On va maintenant tronquer le fichier, on se place au d�but des donn�es ajout�es ... }
 SetFilePointer(F, -SizeOf(TFileAddHeader) - Header.AddLength, nil, FILE_END);
 { On tronque � la position du pointeur de fichier actuelle ! }
 SetEndOfFile(F);
 { Et voil� ! }
 Result := True;
end;

end.
