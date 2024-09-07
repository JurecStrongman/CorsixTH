; Copyright (c) 2015 Edvin "Lego3" Linge

; Permission is hereby granted, free of charge, to any person obtaining a copy of
; this software and associated documentation files (the "Software"), to deal in
; the Software without restriction, including without limitation the rights to
; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
; of the Software, and to permit persons to whom the Software is furnished to do
; so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; Base Script generated by the HM NIS Edit Script Wizard.
; Last compiled on MakeNSIS v3.0b1.

;---------------------------------- Definitions for the game -----------------------------------

!define PRODUCT_NAME "CorsixTH"
!define PRODUCT_VERSION "0.68.0-rc1"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"
Unicode True

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "CorsixTHInstaller.exe"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; Compatible with x64 systems
!include "x64.nsh"

; Include FileFunc to allow GetParent support
!include "FileFunc.nsh"
!insertmacro GetParent

; Include Word Functions for VersionCompare
!include "WordFunc.nsh"

!include "nsDialogs.nsh"
!include "LogicLib.nsh"

; This is needed to be able to install into the program files directory
RequestExecutionLevel admin

; -------------------- Definitions and macros that create the graphical interface -----------------

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_CUSTOMFUNCTION_UNGUIINIT un.onGUIInit2

!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "welcome.bmp"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME

; License page
!insertmacro MUI_PAGE_LICENSE "..\LICENSE.txt"

; Directory page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ValidateDirectory
!insertmacro MUI_PAGE_DIRECTORY

; Another directory page to choose where the original game is
Var OriginalPath
Var CONFIGAPPDATA
Var Dialog
Var AppDataSaveCheckBox

Page custom OptionsPage OptionsPageLeave

; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\CorsixTH.exe"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Icons used by the installer and uninstaller
UninstallIcon "..\CorsixTH\CorsixTH.ico"
Icon "..\CorsixTH\CorsixTH.ico"


; ------------------------------- Languages supported by the installer ---------------------------


; Language files
!insertmacro MUI_LANGUAGE "Czech"
!insertmacro MUI_LANGUAGE "Danish"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Finnish"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Hungarian"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "Norwegian"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Portuguese"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "TradChinese"

; MUI end ------

;Used to replace strings in the config.txt file
!include StrRep.nsh
!include ReplaceInFile.nsh

Function .onInit
  ; Set default Theme Hospital vanilla install directory.
  StrCpy $OriginalPath "$PROGRAMFILES\Bullfrog\Hospital\"

  ; Read Uninstall data from CorsixTH section of the registry.
  ReadRegStr $R0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString"

  ; Check to see if game is already installed.
  ; Temporary $R0 NSIS register is used for storage while we pull the registry data, if CorsixTH data exists we parse the path and set it as the installer location, if not the installer defaults to stock location.
  ${If} $R0 != ''
   ${GetParent} $R0, $R0
   StrCpy $INSTDIR $R0
  ${Else}
   ${If} ${RunningX64}
    StrCpy $INSTDIR $PROGRAMFILES64\${PRODUCT_NAME}
   ${EndIf}
  ${EndIf}
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

!include LanguageStrings.nsh

; A function called when the user wants to move on past the choose installation directory dialog.
Function ValidateDirectory
  ; Check if we're trying to install over an existing installation
  ${If} ${FileExists} "$INSTDIR\Lua"
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(overwrite_install)" IDYES overwriting
    Abort
  ${EndIf}
  overwriting:
FunctionEnd

; ----------------------------- Functions for the custom options page ----------------------------

Function OptionsPage
  ${If} ${FileExists} "$APPDATA\CorsixTH\config.txt"
    StrCpy $CONFIGAPPDATA ${BST_CHECKED}
    Abort
  ${ElseIf} ${FileExists} "$INSTDIR\config.txt"
    StrCpy $CONFIGAPPDATA ${BST_UNCHECKED}
    Abort
  ${EndIf}

  nsDialogs::Create 1018
  Pop $Dialog

  !insertmacro MUI_HEADER_TEXT $(options_title) $(options_subtitle)

  ${NSD_CreateCheckBox} 12u 12u 300u 10u $(save_in_appdata)
  Pop $AppDataSaveCheckBox
  ${NSD_Check} $AppDataSaveCheckBox

  nsDialogs::Show
FunctionEnd

Function OptionsPageLeave
  ${NSD_GetState} $AppDataSaveCheckBox $CONFIGAPPDATA
FunctionEnd


; -------------------------- Define which files to include in the package ------------------------


Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer

  ; We no longer have three exes. Make sure to remove them in case this is a
  ; previous CorsixTH installation directory.
  Delete "$INSTDIR\CorsixTH_SDL.exe"
  Delete "$INSTDIR\CorsixTH_DirectX.exe"
  Delete "$INSTDIR\CorsixTH_OpenGL.exe"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}_SDL.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}_OpenGL.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}_DirectX.lnk"

  ${If} ${FileExists} "$INSTDIR\Lua"
    RMDir /r "$INSTDIR\Lua"
    CreateDirectory "$INSTDIR\Lua"
  ${EndIf}

  ${If} ${RunningX64}
    File /r /x .svn x64\*.*
    Goto continued
  ${EndIf}
  File /r /x .svn x86\*.*

  continued:
  ; Time to make the configuration file and Saves folder at the correct location
  ${If} $CONFIGAPPDATA == ${BST_CHECKED}
    SetOutPath "$APPDATA\CorsixTH"
    IfFileExists "$APPDATA\CorsixTH\Saves" saves

    ; Don't overwrite previous installations though!
    CreateDirectory "$APPDATA\CorsixTH\Saves"
  ${Else}
    ; Tell the game that it should read the config file from the install dir
    ; Don't overwrite previous installations here either!
    IfFileExists "$INSTDIR\config.path.txt" saves
    FileOpen $9 config.path.txt w
    FileWrite $9 "$INSTDIR\$\r$\n"
    FileClose $9

    IfFileExists "$INSTDIR\Saves" saves
    CreateDirectory "$INSTDIR\Saves"
  ${EndIf}
  File config_template.txt

  ; Change settings in the config file.
  System::Call 'user32::GetSystemMetrics(i 0) i .r0'
  System::Call 'user32::GetSystemMetrics(i 1) i .r1'
  !insertmacro ReplaceInFile config_template.txt ORIGINAL_HOSPITAL_DIRECTORY $OriginalPath
  !insertmacro ReplaceInFile config_template.txt LANGUAGE_CHOSEN $(install_language)
  !insertmacro ReplaceInFile config_template.txt SCREEN_SIZE_WIDTH "$0"
  !insertmacro ReplaceInFile config_template.txt SCREEN_SIZE_HEIGHT "$1"
  !insertmacro ReplaceInFile config_template.txt SCREEN_FULLSCREEN "false"

  ; TODO: Let the user choose if new music files exist and where they are in that case.
  Rename config_template.txt config.txt
  Delete config_t*

  ; Continue here if the saves folder and config file was already present
  saves:
  ; The three other needed folders
  ; The old Lua folder is deleted first, if any exists, so that the game can start properly.
  SetOutPath "$INSTDIR\Lua"
  File /r /x .svn ..\CorsixTH\Lua\*.*

  SetOutPath "$INSTDIR\Bitmap"
  File /r /x .svn ..\CorsixTH\Bitmap\*.pal
  File /r /x .svn ..\CorsixTH\Bitmap\*.dat
  File /r /x .svn ..\CorsixTH\Bitmap\*.tab

  SetOutPath "$INSTDIR\Levels"
  File /r /x .svn ..\CorsixTH\Levels\*.*

  SetOutPath "$INSTDIR\Campaigns"
  File /r /x .svn ..\CorsixTH\Campaigns\*.*

; Shortcuts and final files
  SetOutPath "$INSTDIR"
  File ..\CorsixTH\*.lua
  File ..\changelog.txt
  File ..\LICENSE.txt
  File ..\README.txt

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd


; ----------------------- Start menu items and finalizing activities -------------------------


Section -AdditionalIcons
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\CorsixTH.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}\CorsixTH AppData Folder.lnk" "$APPDATA\CorsixTH"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\CorsixTH.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "CorsixTH Team"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "https://corsixth.com"

SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(successful_removal)"
FunctionEnd

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

; To be able to show localized strings
Function un.onGUIInit2
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(confirm_removal)" IDYES +2
  Abort
FunctionEnd


; -------------------------- What to remove when uninstalling -------------------------------
Section Uninstall

  RMDir /r "$INSTDIR\Lua"
  RMDir /r "$INSTDIR\Bitmap"
  RMDir /r "$INSTDIR\Levels"
  RMDir /r "$INSTDIR\mime"
  RMDir /r "$INSTDIR\socket"
  RMDir /r "$INSTDIR\Src"

  Delete "$INSTDIR\*.*"

  Delete "$SMPROGRAMS\${PRODUCT_NAME}\*.*"

  RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"

  ; Maybe the user wants to keep saved games?
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(remove_saves)" IDYES afterSaves
  ; Try to remove everything in AppData too. Nothing happens if it doesn't exist.
  RMDir /r "$APPDATA\CorsixTH\Saves"
  RMDir /r "$APPDATA\CorsixTH"
  RMDir /r "$INSTDIR\Saves"

  afterSaves:
  ${Unless} ${FileExists} "$INSTDIR\Saves"
    RMDir "$INSTDIR"
  ${EndUnless}
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"

  IfErrors error noerror
  error:
  MessageBox MB_OK "$(files_left)"
  noerror:
  SetAutoClose true
SectionEnd
