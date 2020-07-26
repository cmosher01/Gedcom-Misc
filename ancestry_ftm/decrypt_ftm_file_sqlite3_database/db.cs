using System;
using System.IO;
using System.Data.SQLite;
using System.Security.Cryptography;

/*
From Family Tree Maker 2019 directory, copy
    System.Data.SQLite.dll
    x86\SQLite.Interop.dll
into build directory, along with this source code file (db.cs)

Edit db.cs to use approprieate password depending on FTM version (for FTM 2019, use #7):
1 NGDuck
2 AC0MNGDuck$
3 aes128:Nerv0u$GreenDuck
4 aes128:qVrttqreE0clGNuyUsZU0nCl9+VxyOuL
5 aes128:DScnaANSEN6uvDLr3HNN+0VfrPK6YODJ
6 aes256:Ud1lo0OtDABLU63tRhUlLuzAJA8hNZAE
7 aes256:ViDfwQnOAX8IGG5T5xs3yyBOryIqfPu6

Make sure .NET 4.0 SDK is in Path: C:\Windows\Microsoft.NET\Framework\v4.0.30319
set Path=C:\Windows\Microsoft.NET\Framework\v4.0.30319;%Path%

csc /t:exe /out:db.exe /r:"System.Data.SQLite.dll" /platform:x86 db.cs

db.exe *.ftm

This program never modifies or deletes any existing files.
It creates a copy of the original FTM (database) file in a temporary directory.
It then creates a decrypted copy in the same directory.

Then hexedit file, byte at offset 21 decimal (= 15 hex), change byte from hex 20 to hex 40.


*/ 

public class SQLitePasswd {
    const string password = "aes256:ViDfwQnOAX8IGG5T5xs3yyBOryIqfPu6";
    const string sql3magic = "SQLite format 3\0";

    public static void Main(string[] args) {
        // TODO: check for existence of System.Data.SQLite.dll and SQLite.Interop.dll to prevent crash

        if (args.Length <= 0) {
            Console.WriteLine("No FTM files specified; nothing to do");
            return;
        }

        var tdir = CreateUniqueTempDirectory();
        Console.WriteLine("Creating new output directory: {0}", tdir);

        foreach (var a in args) {
            Console.WriteLine("------------------------------------------");
            var f = Path.GetFullPath(a);
            if (File.Exists(f)) {
                copyAndDecrypt(f, tdir);
            } else {
                var fc = Console.ForegroundColor;
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("WARNING: input file not found; skipping: {0}", f);
                Console.ForegroundColor = fc;
            }
        }
        Console.WriteLine("------------------------------------------");
    }

    static void copyAndDecrypt(string f, string tdir) {
        Console.WriteLine("Processing input file: {0}", f);

        var fdir = Path.GetDirectoryName(f);
        var ffil = Path.GetFileNameWithoutExtension(f);
        var ftyp = Path.GetExtension(f);

        Console.WriteLine("dir={0} ; file={1} ; type={2}", fdir, ffil, ftyp);

        var md5 = CalcHashOfFile(f);
        Console.WriteLine("md5={0}", md5);

        var orig = Path.GetFullPath(tdir+@"\"+ffil+".md5."+md5+".original.ftm");
        Console.WriteLine("Copying: {0}  ----to---->  {1}", f, orig);
        File.Copy(f, orig);

        var decr = Path.GetFullPath(tdir+@"\"+ffil+".md5."+md5+".decrypted.db");
        Console.Write("Preparing new SQLite database file for decryption: ");
        {
            var fc = Console.ForegroundColor;
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("{0}", decr);
            Console.ForegroundColor = fc;
        }
        File.Copy(orig, decr);



        // TODO: cycle through all known passwords till we find one that works
        var connstring =
            "data source="+decr+";"+
            "password="+password;
        Console.WriteLine("Connection string: {0}", connstring);

        SQLiteConnection cnn = null;
        try {
            cnn = new SQLiteConnection(connstring);
            Console.WriteLine("Opening database...");
            cnn.Open();
            Console.WriteLine("Decrypting database...");
            cnn.ChangePassword((String)null);
            Console.WriteLine("Decryption completed.");
        } finally {
            if (cnn != null && cnn.State != System.Data.ConnectionState.Closed) {
                cnn.Close();
            }
        }

        Console.WriteLine("Patching value of maximum embedded payload fractions, in header...");
        using (BinaryWriter bw = new BinaryWriter(File.Open(decr, FileMode.Open, FileAccess.ReadWrite))) {
            bw.BaseStream.Seek(21, SeekOrigin.Begin);
            const Byte patch = 0x40;
            bw.Write(patch);
        }
        Console.WriteLine("Patch complete.");

        using (BinaryReader br = new BinaryReader(File.Open(decr, FileMode.Open, FileAccess.Read))) {
            byte[] magic = br.ReadBytes(0x10);
            var smag = String.Concat(Array.ConvertAll(magic, x => (char)x));
            Console.WriteLine("Magic bytes of decrypted file: {0} == {1}",
                String.Concat(Array.ConvertAll(magic, x => x.ToString("X2"))),
                smag);

            var fc = Console.ForegroundColor;
            if (smag.Equals(sql3magic)) {
                Console.Write("Magic bytes are as expected: ");
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("{0}", smag.Replace("\0", String.Empty));
            } else {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("WARNING: Magic bytes are not as expected. Most likely, the decryption failed.");
            }
            Console.ForegroundColor = fc;
        }
    }

    static string CreateUniqueTempDirectory()
    {
        var uniqueTempDir = Path.GetFullPath(Path.Combine(Path.GetTempPath(), Path.GetRandomFileName()));
        Directory.CreateDirectory(uniqueTempDir);
        return uniqueTempDir;
    }

    static string CalcHashOfFile(string f) {
        using (var md5 = MD5.Create())
        {
            using (var stream = File.OpenRead(f))
            {
                var hash = md5.ComputeHash(stream);
                return BitConverter.ToString(hash).Replace("-", String.Empty).ToLowerInvariant();
            }
        }
    }
}












/*
Data info
---------
Date format is related to Julian Day times 512


LinkTableID refers to tables (defined in FTM.Data.DB.dll: FTM.Data.DB/TableID enum):
  0 Assertion,
  1 ChildRelationship,
  2 Fact,
  3 FactType,
  4 Note,
  5 Person,
  6 Place,
  7 Relationship,
  8 Setting,
  9 Task,
 10 MasterSource,
 11 Category,
 12 Repository,
 13 MediaFile,
 14 MediaLink,
 15 FileCategoryRel,
 16 Source,
 17 SourceLink,
 18 TaskCategory,
 19 TaskCategoryRel,
 20 History,
 21 Publication,
 22 HistoryList,
 23 Deleted,
 24 Cache,
 25 WebLink,
 26 Tag,
 27 TagLink,
 28 MediaFileBookmark,
 29 SettingURLBookmark,
 30 PersonExternal,
 31 ChangeMacroCommand,
 32 ChangeCommand,
 33 DynamicFilter,
 34 DynamicFilterItem,
 35 Watermark,
 36 DnaMatch,
 37 CompactChangesForUndo,
 38 MediaFileOriginal,


Tables with LinkTableID column:
Fact
MediaLink
Note
SourceLink
TagLink
Task
WebLink

common tables linked to:
 2 Fact
 5 Person
 7 Relationship
13 MediaFile
16 Source

*/
