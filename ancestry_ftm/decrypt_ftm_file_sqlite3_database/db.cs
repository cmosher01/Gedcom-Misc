using System;
using System.Data.SQLite;

/*
From Family Tree Maker 2019 directory, copy
    System.Data.SQLite.dll
    x86\SQLite.Interop.dll
into build directory, along with this source code file (db.cs)

Edit source code, "connstring" variable with name of FTM (unzipped) file.
and approprieate password depending on FTM version (for FTM 2019, use #7)

1 NGDuck
2 AC0MNGDuck$
3 aes128:Nerv0u$GreenDuck
4 aes128:qVrttqreE0clGNuyUsZU0nCl9+VxyOuL
5 aes128:DScnaANSEN6uvDLr3HNN+0VfrPK6YODJ
6 aes256:Ud1lo0OtDABLU63tRhUlLuzAJA8hNZAE
7 aes256:ViDfwQnOAX8IGG5T5xs3yyBOryIqfPu6

Make sure .NET 4.0 SDK is in Path: C:\Windows\Microsoft.NET\Framework\v4.0.30319

csc /t:exe /out:db.exe /r:"System.Data.SQLite.dll" /linkres:"SQLite.Interop.dll" /platform:x86 db.cs

db.exe

Then hexedit file, byte at offset 21 decimal (= 15 hex), change byte from hex 20 to hex 40.
*/ 

public class SQLitePasswd {
    public static void Main() {
        string connstring = "data source=TREE.ftm;password=aes256:ViDfwQnOAX8IGG5T5xs3yyBOryIqfPu6";
        SQLiteConnection cnn = null;
        try {
            cnn = new SQLiteConnection(connstring);
            cnn.Open();
            cnn.ChangePassword((String)null);
        } finally {
            if (cnn != null && cnn.State != System.Data.ConnectionState.Closed) {
                cnn.Close();
            }
        }
    }
}
