@echo off
:: https://www.python.org/downloads/metadata/sigstore/
setlocal
set sigstoreName=%1
set distrName=%sigstoreName:.sigstore=%
if -%1- == -%distrName%- exit /b
call :test "[^0-9]3\.14[^0-9]"      "hugo@python.org"       "https://github.com/login/oauth"
call :test "[^0-9]3\.1[23][^0-9]"   "thomas@python.org"     "https://accounts.google.com"
call :test "[^0-9]3\.1[01][^0-9]"   "pablogsal@python.org"  "https://accounts.google.com"
call :test "[^0-9]3\.[89][^0-9]"    "lukasz@langa.pl"       "https://github.com/login/oauth"
call :test "[^0-9]3\.7[^0-9]"       "nad@python.org"        "https://github.com/login/oauth"
exit /b
:test
echo %distrName% | findstr /r %1 >nul && call :verify %2 %3
exit /b
:verify
sigstore.exe verify identity --bundle %sigstoreName% --cert-identity %1 --cert-oidc-issuer %2 %distrName%
exit