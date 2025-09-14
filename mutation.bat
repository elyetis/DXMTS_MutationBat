@echo off
setlocal enabledelayedexpansion

REM ===================================================================
REM ==  ETAPE 1: CONFIGURATION DES FICHIERS
REM ===================================================================

echo --- Etape 1: Recherche du fichier de sauvegarde source ---

REM --- Trouver le fichier .sav le plus recent dans le dossier ---
set "SOURCE_SAV_FILE="
FOR /F "delims=" %%i IN ('dir /b /o:-d *.sav') DO (
    set "SOURCE_SAV_FILE=%%i"
    goto :FoundSavFile
)

:FoundSavFile
if not defined SOURCE_SAV_FILE (
    echo ERREUR: Aucun fichier .sav trouve dans ce dossier.
    pause
    exit /b 1
)

echo Fichier de sauvegarde source trouve : %SOURCE_SAV_FILE%

REM --- Definir les noms des fichiers de SORTIE (qui sont fixes) ---
set "FINAL_JSON_FILE=Slot10.json"
set "FINAL_SAV_FILE=Slot10.sav"
set "TEMP_FILE=temp_output.json"

echo.
echo Le processus suivant va etre execute :
echo   1. Convertir "%SOURCE_SAV_FILE%" en "%FINAL_JSON_FILE%"
echo   2. Modifier "%FINAL_JSON_FILE%"
echo   3. Reconvertir le resultat en "%FINAL_SAV_FILE%"
REM echo.
REM pause


REM ===================================================================
REM ==  ETAPE 2: PREREQUIS ET CONVERSION INITIALE
REM ===================================================================

REM --- Verifier que les outils existent ---
where uesave >nul 2>nul
if errorlevel 1 (
  echo ERROR: L'utilitaire 'uesave' est introuvable.
  pause
  exit /b 1
)
where jq >nul 2>nul
if errorlevel 1 (
  echo ERROR: L'utilitaire 'jq' est introuvable.
  pause
  exit /b 1
)

REM --- Executer la conversion .sav -> .json ---
echo.
echo --- Etape 2: Conversion du fichier .sav en .json ---
uesave to-json -i "%SOURCE_SAV_FILE%" -o "%FINAL_JSON_FILE%"

if errorlevel 1 (
  echo ERREUR: La conversion initiale avec 'uesave' a echoue.
  pause
  exit /b 1
)
echo Conversion en JSON reussie.
echo.


REM ===================================================================
REM ==  ETAPE 3: INTERACTION UTILISATEUR
REM ===================================================================
echo --- Etape 3: Configuration des modifications ---

REM ======  GLOWING EYES  ======
echo Quel type voulez-vous definir pour la partie 'Glowing eyes' ?
set /p "NEW_TYPE_RAW=Entrez t (true) ou f (false)"
if /I "%NEW_TYPE_RAW%"=="t"  set "NEW_BOOL_GLOW_EYES=true"
if /I "%NEW_TYPE_RAW%"=="f"  set "NEW_BOOL_GLOW_EYES=false"

if not defined NEW_TYPE_RAW (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM ======  HEAD  ======
echo Quel type voulez-vous definir pour la partie 'Head' ?
set /p "NEW_ID_HEAD=Entrez ID: ( ex ID332 - Femme Heavy Medium, n = None ) "
if /I "%NEW_ID_HEAD%"=="n"  set "NEW_ID_HEAD=None"

if not defined NEW_ID_HEAD (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM ======  FACE  ======
echo Quel type voulez-vous definir pour la partie 'Face' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_FACE="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_FACE=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_FACE=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_FACE=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_FACE=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_FACE=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_FACE=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_FACE=Heavy"

if not defined NEW_TYPE_FACE (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_FACE="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_FACE=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_FACE=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_FACE=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_FACE=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_FACE=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_FACE=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_FACE=ID403"


REM ======  TATTOO  ======
echo Quel type voulez-vous definir pour la partie 'Tattoo' ?
set /p "NEW_TATOO=Entrez : n (none), h (head), b (body), la (left arm), ra (right arm), l (legs)"

:: Initiate all to None
set "NEW_ID_TATTOO_HEAD_MALE=None"
set "NEW_ID_TATTOO_HEAD_FEMALE=None"
set "NEW_ID_TATTOO_BODY_MALE=None"
set "NEW_ID_TATTOO_BODY_FEMALE=None"
set "NEW_ID_TATTOO_LARM_MALE=None"
set "NEW_ID_TATTOO_RARM_MALE=None"
set "NEW_ID_TATTOO_LARM_FEMALE=None"
set "NEW_ID_TATTOO_RARM_FEMALE=None"
set "NEW_ID_TATTOO_LEGS_MALE=None"
set "NEW_ID_TATTOO_LEGS_FEMALE=None"

:: Loop through each word in NEW_TATOO NEW_ID_TATTOO_HEAD_MALE 
for %%W in (%NEW_TATOO%) do (
    if /I "%%W"=="h"  set "NEW_ID_TATTOO_HEAD_MALE=ID301" & set "NEW_ID_TATTOO_HEAD_FEMALE=ID401"
    if /I "%%W"=="b"  set "NEW_ID_TATTOO_BODY_MALE=ID301" & set "NEW_ID_TATTOO_BODY_FEMALE=ID401"
    if /I "%%W"=="la"  set "NEW_ID_TATTOO_LARM_MALE=ID301" & set "NEW_ID_TATTOO_LARM_FEMALE=ID401"
    if /I "%%W"=="ra"  set "NEW_ID_TATTOO_RARM_MALE=ID301" & set "NEW_ID_TATTOO_RARM_FEMALE=ID401"
    if /I "%%W"=="l"  set "NEW_ID_TATTOO_LEGS_MALE=ID301" & set "NEW_ID_TATTOO_LEGS_FEMALE=ID401"
)

REM ======  Left ARM  ======
echo Quel type voulez-vous definir pour la partie 'Left Arm' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_LARM="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_LARM=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_LARM=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_LARM=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_LARM=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_LARM=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_LARM=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_LARM=Heavy"

if not defined NEW_TYPE_LARM (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_LARM="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_LARM=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_LARM=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_LARM=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_LARM=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_LARM=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_LARM=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_LARM=ID403"


REM ======  Right ARM  ======
echo Quel type voulez-vous definir pour la partie 'Right Arm' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_RARM="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_RARM=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_RARM=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_RARM=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_RARM=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_RARM=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_RARM=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_RARM=Heavy"

if not defined NEW_TYPE_RARM (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_RARM="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_RARM=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_RARM=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_RARM=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_RARM=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_RARM=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_RARM=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_RARM=ID403"


REM ======  BODY  ======
echo Quel type voulez-vous definir pour la partie 'Body' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_BODY="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_BODY=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_BODY=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_BODY=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_BODY=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_BODY=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_BODY=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_BODY=Heavy"

if not defined NEW_TYPE_BODY (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_BODY="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_BODY=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_BODY=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_BODY=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_BODY=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_BODY=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_BODY=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_BODY=ID403"



REM ======  BACK  ======
echo Quel type voulez-vous definir pour la partie 'Back' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_BACK="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_BACK=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_BACK=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_BACK=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_BACK=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_BACK=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_BACK=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_BACK=Heavy"

if not defined NEW_TYPE_BACK (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_BACK="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_BACK=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_BACK=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_BACK=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_BACK=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_BACK=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_BACK=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_BACK=ID403"


REM ======  HIP  ======
echo Quel type voulez-vous definir pour la partie 'Hip' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_HIP="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_HIP=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_HIP=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_HIP=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_HIP=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_HIP=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_HIP=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_HIP=Heavy"

if not defined NEW_TYPE_HIP (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_HIP="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_HIP=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_HIP=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_HIP=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_HIP=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_HIP=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_HIP=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_HIP=ID403"


REM ======  SHOULDER  ======
echo Quel type voulez-vous definir pour la partie 'Shoulder' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_SHOULDER="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_SHOULDER=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_SHOULDER=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_SHOULDER=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_SHOULDER=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_SHOULDER=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_SHOULDER=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_SHOULDER=Heavy"

if not defined NEW_TYPE_SHOULDER (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_SHOULDER="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_SHOULDER=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_SHOULDER=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_SHOULDER=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_SHOULDER=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_SHOULDER=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_SHOULDER=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_SHOULDER=ID403"


REM ======  LEGS  ======
echo Quel type voulez-vous definir pour la partie 'Legs' ?
set /p "NEW_TYPE_RAW=Entrez n ( None ), fl-fm-fh    hl-hm-hh, ( fm = Femme Middle )  "

set "NEW_TYPE_LEGS="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_TYPE_LEGS=None"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_TYPE_LEGS=Light"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_TYPE_LEGS=Middle"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_TYPE_LEGS=Heavy"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_TYPE_LEGS=Light"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_TYPE_LEGS=Middle"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_TYPE_LEGS=Heavy"

if not defined NEW_TYPE_LEGS (
  echo Saisie invalide.
  pause
  exit /b 1
)

REM Mapping des IDs
set "NEW_ID_LEGS="
if /I "%NEW_TYPE_RAW%"=="n"  set "NEW_ID_LEGS=None"
if /I "%NEW_TYPE_RAW%"=="hl"  set "NEW_ID_LEGS=ID301"
if /I "%NEW_TYPE_RAW%"=="hm" set "NEW_ID_LEGS=ID302"
if /I "%NEW_TYPE_RAW%"=="hh"  set "NEW_ID_LEGS=ID303"
if /I "%NEW_TYPE_RAW%"=="fl"  set "NEW_ID_LEGS=ID401"
if /I "%NEW_TYPE_RAW%"=="fm" set "NEW_ID_LEGS=ID402"
if /I "%NEW_TYPE_RAW%"=="fh"  set "NEW_ID_LEGS=ID303"


REM ===================================================================
REM ==  ETAPE 4: MODIFICATION DU FICHIER JSON
REM ===================================================================

echo. 
echo --- Etape 4: Modification du fichier JSON en cours... ---

jq --arg NEW_ID_FACE "!NEW_ID_FACE!" ^
  --arg NEW_ID_HEAD "!NEW_ID_HEAD!" ^
  --arg NEW_TYPE_ARMS "!NEW_TYPE_ARMS!" ^
  --arg NEW_ID_LARM "!NEW_ID_LARM!" ^
  --arg NEW_ID_RARM "!NEW_ID_RARM!" ^
  --arg NEW_ID_BODY "!NEW_ID_BODY!" ^
  --arg NEW_ID_BACK "!NEW_ID_BACK!" ^
  --arg NEW_ID_HIP "!NEW_ID_HIP!" ^
  --arg NEW_ID_SHOULDER "!NEW_ID_SHOULDER!" ^
  --arg NEW_ID_LEGS "!NEW_ID_LEGS!" ^
  --arg NEW_ID_TATTOO_HEAD_MALE  "!NEW_ID_TATTOO_HEAD_MALE!" ^
  --arg NEW_ID_TATTOO_HEAD_FEMALE  "!NEW_ID_TATTOO_HEAD_FEMALE!" ^
  --arg NEW_ID_TATTOO_BODY_MALE  "!NEW_ID_TATTOO_BODY_MALE!" ^
  --arg NEW_ID_TATTOO_BODY_FEMALE  "!NEW_ID_TATTOO_BODY_FEMALE!" ^
  --arg NEW_ID_TATTOO_LARM_MALE  "!NEW_ID_TATTOO_LARM_MALE!" ^
  --arg NEW_ID_TATTOO_RARM_MALE  "!NEW_ID_TATTOO_RARM_MALE!" ^
  --arg NEW_ID_TATTOO_LARM_FEMALE  "!NEW_ID_TATTOO_LARM_FEMALE!" ^
  --arg NEW_ID_TATTOO_RARM_FEMALE  "!NEW_ID_TATTOO_RARM_FEMALE!" ^
  --arg NEW_ID_TATTOO_LEGS_MALE  "!NEW_ID_TATTOO_LEGS_MALE!" ^
  --arg NEW_ID_TATTOO_LEGS_FEMALE  "!NEW_ID_TATTOO_LEGS_FEMALE!" ^
  --argjson NEW_BOOL_GLOW_EYES  "!NEW_BOOL_GLOW_EYES!" ^
  "( (.root.properties.OuterCustomSaveList_0.Array.Struct.value[] | select(.Struct.Part_0.Enum == \"ERexFusionMutateDetailedPart::Arms\").Struct.Type_0.Enum) |= \"ERexFusionMutateType::\" + $NEW_TYPE_ARMS) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateLArmModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_LARM) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateRArmModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_RARM) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateLArmModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_LARM) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateRArmModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_RARM) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateBodyModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_BODY) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateBodyModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_BODY) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateApBodyModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_BACK) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateApBodyModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_BACK) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateApLShoulderModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_SHOULDER) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateApRShoulderModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_SHOULDER) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateApLShoulderModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_SHOULDER) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateApRShoulderModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_SHOULDER) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateLegsModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_LEGS) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateLegsModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_LEGS) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateApHipModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_HIP) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateApHipModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_HIP) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateApHeadModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_HEAD) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateApHeadModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_HEAD) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateApEyeModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_FACE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateApEyeModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_FACE) | (.root.properties.SaveGameHash_0.Struct.Struct.Value_0.UInt32 = 0) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateFaceDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_HEAD_MALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateFaceDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_HEAD_FEMALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateBodyDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_BODY_MALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateBodyDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_BODY_FEMALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateLArmDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_LARM_MALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateLArmDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_LARM_FEMALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateRArmDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_RARM_MALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateRArmDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_RARM_FEMALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.MutateLegsDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_LEGS_MALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.MutateLegsDecalModelID_0.Struct.Struct.Key_0.Name = $NEW_ID_TATTOO_LEGS_FEMALE) | (.root.properties.OuterCustomInfo_0.Struct.Struct.FemaleParam_0.Struct.Struct.bIsMutateEyeEmission_0.Bool = $NEW_BOOL_GLOW_EYES) | (.root.properties.OuterCustomInfo_0.Struct.Struct.MaleParam_0.Struct.Struct.bIsMutateEyeEmission_0.Bool = $NEW_BOOL_GLOW_EYES)" ^
   "%FINAL_JSON_FILE%" > "%TEMP_FILE%"

if errorlevel 1 (
  echo ERROR: La modification du fichier JSON a echoue.
  if exist "%TEMP_FILE%" del "%TEMP_FILE%"
  pause
  exit /b 1
)

move /Y "%TEMP_FILE%" "%FINAL_JSON_FILE%" >nul
echo Modification du JSON terminee.


REM ===================================================================
REM ==  ETAPE 5: RECONVERSION FINALE EN .SAV
REM ===================================================================

echo.
echo --- Etape 5: Reconversion du JSON modifie en .sav ---
uesave from-json -i "%FINAL_JSON_FILE%" -o "%FINAL_SAV_FILE%"

if errorlevel 1 (
  echo ERREUR: La reconversion finale en .sav a echoue.
  pause
  exit /b 1
)

echo.
echo Le fichier "%FINAL_SAV_FILE%" a ete cree avec succes !
pause
exit /b 0

endlocal