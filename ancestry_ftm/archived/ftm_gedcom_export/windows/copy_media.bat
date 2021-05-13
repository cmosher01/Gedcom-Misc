echo on
rem rsync FTM_DOCUMENTS from local home dir to VBox shared dir

C:\Users\vagrant\rsync\bin\rsync.exe -ltvihPr --super --stats /cygdrive/c/Users/vagrant/FTM_DOCUMENTS/ //VBOXSVR/shared/FTM_DOCUMENTS/

pause
