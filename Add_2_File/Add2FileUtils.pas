unit Add2FileUtils;

interface

uses Windows; { Eh oui on a juste besoin de Windows - en dehors des unités System et compagnie ... }

type
  TQuadCharArray = array [0..3] of Char; { Taille : 4 octets, équivalent d'un double mot }

  TFileAddHeader = record { Le header des données ajoutées }
   Signature: TQuadCharArray; { La signature des données - si elle ne correspond pas à AddSignature, on peut s'arrêter }
   AddLength: Longword; { La taille des données (la longueur de la chaîne) }
  end;

const { La signature des données ajoutées : doit figurer dans le header des données ajoutées de ... }
  AddSignature: TQuadCharArray = ('A', 'D', 'D', 'A'); { ... chaque fichier qui en comporte.        }

{ ReadFileAdd lit les données ajoutées d'un fichier - si elle renvoie Size 0, pas de données }
function ReadFileAdd(F: HFILE; var Buffer; var Size: Longword): Boolean;
{ WriteFileAdd écrit les données Buffer de taille Size dans un fichier F, et renvoie True si succès }
function WriteFileAdd(F: HFILE; const Buffer; Size: Longword): Boolean;
{ ClearFileAdd supprime toutes les données ajoutées dans un fichier F, et renvoie True si succès }
{ Notez que un retour False ne signifie pas toujours une erreur (pas de données ajoutées ...)    }
function ClearFileAdd(F: HFILE): Boolean;

implementation

function ReadFileAdd(F: HFILE; var Buffer; var Size: Longword): Boolean; { Lecture des données ajoutées }
Var
 Header: TFileAddHeader;
 Tmp: Longword;
begin
 Result := False;
 { On se place à la fin du fichier pour être plus rapides }
 SetFilePointer(F, -SizeOf(TFileAddHeader), nil, FILE_END);
 { On lit le header des données ajoutées }
 ReadFile(F, Header, SizeOf(Header), Tmp, nil);
 { On va maintenant lire les données ajoutées }
 if Header.Signature <> AddSignature then Exit;
 { On lit la taille des données }
 Size := Header.AddLength;
 { On se place au début des données ajoutées }
 SetFilePointer(F, -SizeOf(TFileAddHeader) - Header.AddLength, nil, FILE_END);
 { On lit ! }
 ReadFile(F, Buffer, Size, Tmp, nil);
 Result := True;
end;

function WriteFileAdd(F: HFILE; const Buffer; Size: Longword): Boolean; { Ecriture des données ajoutées }
Var
 Header: TFileAddHeader;
 Tmp: Longword;
begin
 Result := False;
 { Ne pas oublier de supprimer au préalable les anciennes données : si elles sont plus volumineuses
   que les nouvelles, des artéfacts seraient conservés ! }
 ClearFileAdd(F);
 { Si pas de buffer à écrire, on part tout de suite ! }
 if Size = 0 then Exit;
 { On va maintenant écrire les données ajoutées }
 { On se place à la fin du fichier }
 SetFilePointer(F, 0, nil, FILE_END);
 { On écrit le buffer ... }
 WriteFile(F, Buffer, Size, Tmp, nil);
 { On remplit le header des données ajoutées }
 Header.Signature := AddSignature;
 Header.AddLength := Size;
 { On se place à la fin du fichier pour être plus rapides }
 SetFilePointer(F, 0, nil, FILE_END);
 { On écrit le header des données ajoutées }
 WriteFile(F, Header, SizeOf(Header), Tmp, nil);
 Result := True;
end;

function ClearFileAdd(F: HFILE): Boolean;       { Suppression des données ajoutées }
Var
 Header: TFileAddHeader;
 Tmp: Longword;
begin
 Result := False;
 { On se place à la fin du fichier, et on lit le header }
 SetFilePointer(F, -SizeOf(TFileAddHeader), nil, FILE_END);
 { On lit le header des données ajoutées }
 ReadFile(F, Header, SizeOf(Header), Tmp, nil);
 { On vérifie qu'il y ait bien des données ajoutées }
 if Header.Signature <> AddSignature then Exit;
 { On va maintenant tronquer le fichier, on se place au début des données ajoutées ... }
 SetFilePointer(F, -SizeOf(TFileAddHeader) - Header.AddLength, nil, FILE_END);
 { On tronque à la position du pointeur de fichier actuelle ! }
 SetEndOfFile(F);
 { Et voilà ! }
 Result := True;
end;

end.
