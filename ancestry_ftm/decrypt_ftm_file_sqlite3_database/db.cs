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

option, use /D to create file in current directory instead of creating a temporary dir.

It creates a copy of the original FTM (database) file in a temporary directory.
It then creates a decrypted copy in the same directory.
*/

public class SQLitePasswd {
    const string password = "aes256:ViDfwQnOAX8IGG5T5xs3yyBOryIqfPu6";
    const string sql3magic = "SQLite format 3\0";

    public static void Main(string[] args) {
        // TODO: check for existence of System.Data.SQLite.dll and SQLite.Interop.dll to prevent crash

        bool create = true;
        foreach (var a in args) {
            if (a.StartsWith("/")) {
                if (a.ToLower().Equals("/d")) {
                    create = false;
                }
            }
        }

        // always write output directory as the first line of the output file,
        // to allow for easy and consistent parsing by batch scripts
        string tdir;
        if (create) {
            tdir = CreateUniqueTempDirectory();
            Console.WriteLine("{0}", tdir);
            Console.WriteLine("Created new output directory: {0}", tdir);
        } else {
            tdir = ".";
            Console.WriteLine("{0}", tdir);
        }

        bool any = false;
        foreach (var a in args) {
            if (!a.StartsWith("/")) {
                any = true;
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
        }
        Console.WriteLine("------------------------------------------");
        if (!any) {
            Console.WriteLine("No FTM files specified; nothing to do");
        }

        // always write output directory as the last line of the output file,
        // to allow for easy and consistent parsing by batch scripts
        Console.WriteLine("{0}", tdir);
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
            Console.WriteLine("Decryption complete.");
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

        Console.Write("Checking magic bytes of decrypted file...");
        using (BinaryReader br = new BinaryReader(File.Open(decr, FileMode.Open, FileAccess.Read))) {
            byte[] magic = br.ReadBytes(0x10);
            var smag = String.Concat(Array.ConvertAll(magic, x => (char)x));
            Console.WriteLine("Magic bytes: {0} == {1}",
                String.Concat(Array.ConvertAll(magic, x => x.ToString("X2"))),
                smag.Replace("\0", String.Empty));

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
