echo on
rem copy FTM tree files

set gs= ^
root ^
Joseph ^
Colvin ^
Disosway ^
Flandreau ^
Harrison ^
Justice ^
Lopez ^
Lovejoy ^
McLaughlin ^
Mosher ^
Pettit ^
Romero ^
Spohner ^
Taylorson ^
Tutankhamun ^
rapp_kansas ^
Roth ^
Murray_Lougheed_Wilson_Vandever ^
bryan_nc ^
rollo_research ^
Sandys ^





set srcdir=C:\Users\vagrant\FTM_DOCUMENTS
set dstdir=\\VBOXSVR\shared\FTM_DOCUMENTS

pushd "%dstdir%"

(for %%g in (%gs%) do (
    copy /y "%srcdir%\%%g.ftm" .\
))

popd
pause
