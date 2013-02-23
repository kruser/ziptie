; ZipTie Server NSIS install script
; Original Brett Wooldridge

;--------------------------------
;Include Modern UI
  !include Sections.nsh
  !include "MUI.nsh"
  !include "StrFunc.nsh"
  ${StrRep}
  
# Defines
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION 2008.10.0.1
!define COMPANY ZipTie
!define URL http://www.ziptie.org

!define PRESERVE_DATA_DIALOG_TEXT "Would you like to preserve the data retrieved and stored by the ZipTie Server?$\n$\nIf so, the data will remain untouched in the current installation of the ZipTie Server.  Otherwise, the data will be erased."

# MUI defines
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

;--------------------------------
;General
    #Specify the default install location
    InstallDir "$PROGRAMFILES\ZipTie Server"

    ;Name and file
    Name "ZipTie Server"
    OutFile "..\..\..\dist\artifacts\ZipTieServerSetup.exe"
  
    CRCCheck on
    XPStyle on
    ShowInstDetails show
    VIProductVersion 2008.10.0.1
    VIAddVersionKey ProductName "ZipTie Server"
    VIAddVersionKey ProductVersion "${VERSION}"
    VIAddVersionKey CompanyName "${COMPANY}"
    VIAddVersionKey CompanyWebsite "${URL}"
    VIAddVersionKey FileVersion "${VERSION}"
    VIAddVersionKey FileDescription ""
    VIAddVersionKey LegalCopyright ""

  ;Default installation folder set in .onInit

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\ZipTie Server" ""

  ; Required for Vista
  RequestExecutionLevel admin

  var /GLOBAL jdkdir
  var /GLOBAL installsvc
  var /GLOBAL startsvc
  var /GLOBAL preserveData
  var /GLOBAL performUpdate

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  
;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "MPL-1_1.txt"
;  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  Page custom ServicesDialog
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Dummy Section" SecDummy

    # Stop the ZipTie Server if it already exists.  This will need to be done if someone is trying to upgrade
    IfFileExists "$INSTDIR\ztwrapper\windows\ztwrapper.exe" 0 +4
    IfFileExists "$INSTDIR\ztwrapper\windows\ztwrapper.conf" 0 +3
    StrCpy $performUpdate "yes"
    ExecWait '"$INSTDIR\ztwrapper\windows\ztwrapper.exe" --stop "$INSTDIR\ztwrapper\windows\ztwrapper.conf"'

  SetOutPath "$INSTDIR"

  ;These are the files to install
  ;
  ReserveFile "options.ini"
  ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"
  
    # When upgrading, backup all the important files some place safe so they don't get nuked.
    # This includes the following directories:
    #
    # "derby" - The Derby database
    # "repository" - The SVN repositories used for storing device config information
    # "lucene" - The Lucene search index
    # "osgi-conifg" - All of the configuration preferences for the ZipTie server
  StrCmp $performUpdate "yes" 0 +10
    CreateDirectory $INSTDIR\ziptieServerBackup
    CreateDirectory $INSTDIR\ziptieServerBackup\derby
    CreateDirectory $INSTDIR\ziptieServerBackup\repository
    CreateDirectory $INSTDIR\ziptieServerBackup\lucene
    CreateDirectory $INSTDIR\ziptieServerBackup\osgi-config
    CopyFiles /silent $INSTDIR\derby\* $INSTDIR\ziptieServerBackup\derby
    CopyFiles /silent $INSTDIR\repository\* $INSTDIR\ziptieServerBackup\repository
    CopyFiles /silent $INSTDIR\lucene\* $INSTDIR\ziptieServerBackup\lucene
    CopyFiles /silent $INSTDIR\osgi-config\* $INSTDIR\ziptieServerBackup\osgi-config
    
  # Delete the "core", and "crates" directories when upgrading
  StrCmp $performUpdate "yes" 0 +3
      RMDir /r "$INSTDIR\core"
      RMDir /r "$INSTDIR\crates"
  
  # Copy over everything but the ztwrapper.conf file, this is because the ztwrapper.conf must be modified
  # to properly contain the correct path to the Java installation on the machine
  SetOverwrite on
  File /r /x ztwrapper.conf ..\..\..\dist\server\*.*
  
  # Restore the "osgi-config\security\passwd" file that contains all the user/password info
  StrCmp $performUpdate "yes" 0 +3
      Delete "$INSTDIR\osgi-config\security\passwd"
      CopyFiles "$INSTDIR\ziptieServerBackup\osgi-config\security\passwd" "$INSTDIR\osgi-config\security\passwd"

  # When perfomring an upgrade, try migrating the database to the current version
  StrCmp $performUpdate "yes" 0 +5
    RMDir /r "$INSTDIR\derby"
    CreateDirectory $INSTDIR\derby
    CopyFiles /silent $INSTDIR\ziptieServerBackup\derby\* $INSTDIR\derby
    ExecWait 'perl "$INSTDIR\dbutil.pl" migrate'
  
  # Do some stuff to modify the ztwrapper.conf file.
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File "/oname=$TEMP\ztwrappertmp.conf" ..\..\..\dist\server\ztwrapper\windows\ztwrapper.conf
  
  ClearErrors
  FileOpen $0 "$TEMP\ztwrappertmp.conf" r
  FileOpen $1 "$INSTDIR\ztwrapper\windows\ztwrapper.conf" w
  loop:
    IfErrors done
    FileRead $0 $2
    ${StrRep} $2 $2 "%JAVA_HOME%" $jdkdir
    FileWrite $1 $2
    Goto loop
  done:
  ClearErrors
  FileClose $0
  FileClose $1
  Delete "$TEMP\ztwrappertmp.conf"

  # Create expiration file.  Is only used if other properties are set.
  FileOpen $0 "$INSTDIR\osgi-config\zef.dat" w
  FileWrite $0 "expiry"
  FileClose $0

  ;Store installation folder
  WriteRegStr HKCU "Software\ZipTie Server" "" $INSTDIR
  
    # Install required Perl modules before starting the server
    ExecWait 'perl "$INSTDIR\perlcheck.pl"'

  IntCmpU $installsvc 0 +2
    ExecWait '"$INSTDIR\ztwrapper\windows\ztwrapper.exe" --install "$INSTDIR\ztwrapper\windows\ztwrapper.conf"'

  IntCmpU $startsvc 0 +2
    ExecWait '"$INSTDIR\ztwrapper\windows\ztwrapper.exe" --start "$INSTDIR\ztwrapper\windows\ztwrapper.conf"'
    
    # Create the actual uninstaller
    WriteUninstaller "$INSTDIR\ZipTieServerUninstall.exe"
    
    # Specify information about ZipTie Server to show up in the Add/Remove Programs dialog in the Control Panel
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    
    # Specify the icon to use for the ZipTie Server uninstaller in Add/Remove Programs
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\ZipTieServerUninstall.exe
    
    # Specify the location of the uninstaller
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\ZipTieServerUninstall.exe
    
    # Specify that we do not want any modify or repair options to be allowed in the uninstaller
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1

SectionEnd

;--------------------------------
; On init
Function .onInit

  # Check to see if the Sun JDK is installed
  ClearErrors
  ReadRegStr $0 HKLM "Software\JavaSoft\Java Development Kit" CurrentVersion
  IfErrors 0 +2
    Call NoJdk

  ReadRegStr $jdkdir HKLM "Software\JavaSoft\Java Development Kit\$0" JavaHome
  
  # Check to see if Perl is installed
  ClearErrors
  ExecWait "perl --version"
  IfErrors 0 +2
    Call NoPerl
    
FunctionEnd

;--------------------------------
; Called if no JDK is installed
Function NoJdk
    MessageBox MB_ICONSTOP|MB_OK "The Sun JDK does not appear to be installed.  Please ensure that you have you have Sun JDK version 1.5.0 or higher installed before installing the ZipTie Server."
    Abort
FunctionEnd

#-------------------------------
# Called if Perl is not located within the system path
Function NoPerl
    MessageBox MB_ICONSTOP|MB_OK "A valid install of ActiveState Perl could not be found within the system path.  Please ensure that you have ActiveState Perl version 5.8.8 installed before installing the ZipTie Server."
    Abort
FunctionEnd

Function ServicesDialog

  ;Display the InstallOptions dialog

    !insertmacro MUI_HEADER_TEXT "Select service options." "Select whether you wish to install and start the service."

	InitPluginsDir
	File /oname=$PLUGINSDIR\options.ini "..\..\installers\windows\options.ini"

    !define TEMP1 $R0 ;Temp variable
    Push ${TEMP1}
       InstallOptions::dialog "$PLUGINSDIR\options.ini"
       Pop ${TEMP1}
    Pop ${TEMP1}

    ReadINIStr $installsvc "$PLUGINSDIR\options.ini" "Field 2" "State"
    ReadINIStr $startsvc "$PLUGINSDIR\options.ini" "Field 3" "State"

FunctionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecDummy ${LANG_ENGLISH} "A test section."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

    # Prompt the user if they would like to preserve their data
    MessageBox MB_YESNO|MB_ICONQUESTION "${PRESERVE_DATA_DIALOG_TEXT}" IDYES set_preserve_data_yes IDNO set_preserve_data_no
    set_preserve_data_yes:
      StrCpy $preserveData "yes"
      Goto set_preserve_data_var_done
    set_preserve_data_no:
      StrCpy $preserveData "no"
    set_preserve_data_var_done:
    
    # Stop the ZipTie server
    ExecWait '"$INSTDIR\ztwrapper\windows\ztwrapper.exe" --remove "$INSTDIR\ztwrapper\windows\ztwrapper.conf"'
    
    # Clear out the entry for the ZipTie Server in Add/Remove Programs and clean up any registry values associated with it
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    Delete "$INSTDIR\ZipTieServerUninstall.exe"
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    
    # If the user wants to preserve the data, let's copy it some place safe so it doesn't get nuked.
    # This includes the following directories:
    #
    # "derby" - The Derby database
    # "repository" - The SVN repositories used for storing device config information
    # "lucene" - The Lucene search index
    # "osgi-conifg" - All of the configuration preferences for the ZipTie server
    StrCmp $preserveData "yes" 0 +10
    CreateDirectory $TEMP\ziptieServerBackup
    CreateDirectory $TEMP\ziptieServerBackup\derby
    CreateDirectory $TEMP\ziptieServerBackup\repository
    CreateDirectory $TEMP\ziptieServerBackup\lucene
    CreateDirectory $TEMP\ziptieServerBackup\osgi-config
    CopyFiles /silent $INSTDIR\derby\* $TEMP\ziptieServerBackup\derby
    CopyFiles /silent $INSTDIR\repository\* $TEMP\ziptieServerBackup\repository
    CopyFiles /silent $INSTDIR\lucene\* $TEMP\ziptieServerBackup\lucene
    CopyFiles /silent $INSTDIR\osgi-config\* $TEMP\ziptieServerBackup\osgi-config
    
    # Remove the entire contents of the ZipTie Server install
    RMDir /r /REBOOTOK "$INSTDIR"
    
    # Restore the preserved data back to the install directory
    StrCmp $preserveData "yes" 0 +11
    CreateDirectory $INSTDIR
    CreateDirectory $INSTDIR\derby
    CreateDirectory $INSTDIR\repository
    CreateDirectory $INSTDIR\lucene
    CreateDirectory $INSTDIR\osgi-config
    CopyFiles /silent $TEMP\ziptieServerBackup\derby\* $INSTDIR\derby
    CopyFiles /silent $TEMP\ziptieServerBackup\repository\* $INSTDIR\repository
    CopyFiles /silent $TEMP\ziptieServerBackup\lucene\* $INSTDIR\lucene
    CopyFiles /silent $TEMP\ziptieServerBackup\osgi-config* $INSTDIR\osgi-config
    RMDir /r $TEMP\ziptieServerBackup
    
SectionEnd
