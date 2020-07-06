REM === Program Data ====================================
REM === Title:----------Raport file update with FTP =====
REM === ----------------server ==========================
REM === Author:---------Jakub Tomaszewski ===============
REM === Company:--------ExampleCompany ==================
REM === Date:-----------27-11-2014 ======================
REM =====================================================

REM === Important Notice!!! =============================
REM === Raport file names in local directory and in =====
REM === remote directory must be the same!!! ============
REM =====================================================

REM === Commentary ======================================
REM =====================================================
REM === Possible changes --- Apply only in Network 1 ====
REM =====================================================
REM === Variables to change when moving script to =======
REM === another machine =================================
REM === --- loc1 ----------- Directory of raport file ===
REM =====================================================
REM === Variables to change when using another FTP ======
REM === server or location ==============================
REM === --- ftpuser -------- Username for FTP ===========
REM === --- password ------- User Password for FTP ======
REM === --- remotefolder --- FTP directory for file =====
REM === --- servername ----- Server to connect to =======
REM =====================================================
REM === Variables to change when updating other file ====
REM === --- remotefile ----- Name of updated file =======
REM =====================================================

REM === Start script ====================================
REM =====================================================

REM === Network 1 =======================================
REM === Set localization variables and turn display off =
REM =====================================================

REM === @echo off

set "loc1=%Userprofile%\Desktop\example\ftp"
set "ftploc=tempftpfile"
set "loc2=%loc1%\%ftploc%"
set "filename=exampleFile.xlsm"
set "password=Pa55w0rd123123"
set "ftpuser=example@user.com"
set "servername=example.com"
set "remotefolder=raport"

REM === Network 2 =======================================
REM === Create text file with download operation ========
REM === File transferred to temprorary location  ========
REM === Create temprorary location for FTPcontrol files =
REM =====================================================

cd %loc1%
mkdir %ftploc%

echo user %ftpuser%>%loc1%\%ftploc%\ftprec.txt
echo %password%>>%loc1%\%ftploc%\ftprec.txt
echo lcd %loc2%>>%loc1%\%ftploc%\ftprec.txt
echo cd %remotefolder%>>%loc1%\%ftploc%\ftprec.txt
echo bin>>%loc1%\%ftploc%\ftprec.txt
echo get %filename%>>%loc1%\%ftploc%\ftprec.txt
echo quit>>%loc1%\%ftploc%\ftprec.txt

REM === Network 3 =======================================
REM === Create text file with upload operation ==========
REM === Only for updating if FTP file was old  ==========
REM === Deletes old file from FTP server ================
REM =====================================================

echo user %ftpuser%>%loc1%\%ftploc%\ftpdel.txt
echo %password%>>%loc1%\%ftploc%\ftpdel.txt
echo lcd %loc1%>>%loc1%\%ftploc%\ftpdel.txt
echo cd %remotefolder%>>%loc1%\%ftploc%\ftpdel.txt
echo bin>>%loc1%\%ftploc%\ftpdel.txt
echo delete %filename%>>%loc1%\%ftploc%\ftpdel.txt
echo put %filename%>>%loc1%\%ftploc%\ftpdel.txt
echo quit>>%loc1%\%ftploc%\ftpdel.txt

REM === Network 4 =======================================
REM === Download file to compare using temprorary =======
REM === location to store file from FTP =================
REM =====================================================

cd %loc1%
if not exist %ftploc% mkdir %ftploc%
ftp -n -s:%loc1%\%ftploc%\ftprec.txt %servername%
REM === Network 5 =======================================
REM === Compare file content and choose whether to ======
REM === replace files or end script =====================
REM =====================================================

fc %loc1%\%filename% %loc2%\%filename% | find "FC: no diff" > nul
if ERRORLEVEL 1 goto comp_sizes

goto cleanup

REM === Network 6 =======================================
REM === Compare size of files and choose whether to =====
REM === replace file on server or local file ============
REM =====================================================

:comp_sizes

call :datasize %loc1%\%filename% %loc2%\%filename%
if %f1size% GTR %f2size% goto sendfile
if %f1size% LSS %f2size% goto takefile

echo Pliki roznia sie miedzy soba, ale maja ten sam rozmiar. Wybierz:
echo [1] by wyslac plik z dysku na serwer,
echo [2] by pobrac plik z serwera na dysk,
echo [3] by zakonczyc bez zamiany plikow.

CHOICE /C 123 /t 30 /d 3
if ERRORLEVEL 3 goto cleanup
if ERRORLEVEL 2 goto takefile
if ERRORLEVEL 1 goto sendfile

goto cleanup

REM === Network 7 =======================================
REM === Replace old file from FTP with new from local ===
REM =====================================================

:sendfile

ftp -n -s:%loc1%\%ftploc%\ftpdel.txt %servername%

goto cleanup

REM === Network 8 =======================================
REM === Replace old file from local with new from FTP ===
REM =====================================================

:takefile

del %loc1%\%filename%
copy %loc2%\%filename% %loc1%\%filename%

goto cleanup

REM === Network 9 =======================================
REM === Clean temprorary files and go to end of file ====
REM =====================================================

:cleanup

del ftpdel.dat
del ftprec.dat
rmdir /s /q %loc2%
goto EOF

REM === Network 10 ======================================
REM === Assign values of file size to variables =========
REM =====================================================

:datasize

set f1size=%~z1
set f2size=%~z2
exit /b 0

REM === End of script ===================================
REM =====================================================