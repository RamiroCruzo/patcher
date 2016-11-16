program Project2;

{$APPTYPE CONSOLE}
{$R *.res}
{$optimization on}

uses
  WinAPI.Windows,
  System.SysUtils,
  System.Classes, 
  System.hash;

function GetSHA1(Data: TBytes): string;
var
  Enc: TEncoding;
begin
  Enc := TEncoding.Default;
  Result := THashSHA1.GetHashString(Enc.GetString(Data));
end;

var
  raw, Buffer: array of Byte;
  null: array [0 .. 0] of Byte = (
    $00
  );
  pos: TStringList;
  I, j, k, l: Int64;
  start, stop, elapsed: cardinal;
  infile, scanfile: TBufferedFileStream;
  ScanStopped: boolean;

begin
  SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);
  start := GetTickCount;
  pos := TStringList.Create;
  j := 0;
  try
    scanfile := TBufferedFileStream.Create(paramstr(2), fmOpenRead);
    SetLength(raw, scanfile.Size);
    scanfile.Read(raw[0], scanfile.Size);
    writeln('Loaded file to scan');
    infile := TBufferedFileStream.Create(paramstr(1), fmOpenReadWrite or
      fmShareDenyNone);
    SetLength(Buffer, infile.Size);
    infile.Read(Buffer[0], infile.Size);
    try
      for l := 0 to infile.Size - 1 do
      begin
        if Buffer[l] = raw[0] then
        begin
          if scanfile.Size = 1 then
            pos.Add(IntToStr(l))
          else
          begin
            k := 1;
            ScanStopped := false;
            while k < scanfile.Size do
            begin
              if Buffer[l + k] = raw[k] then
              begin
                Inc(k);
              end
              else
              begin
                ScanStopped := true;
                Break;
              end;
            end;
            if not ScanStopped then
              pos.Add(IntToStr(l));
          end;
        end;
      end;
    finally
      Finalize(Buffer);
      writeln('Scan Complete');
    end;
    writeln('Matches found: ' + IntToStr(pos.Count));
    for j := 0 to pos.Count - 1 do
    begin
      infile.Seek(strtoint(pos[j]), soFromBeginning);
      for I := 0 to scanfile.Size - 1 do
      begin
        infile.Write(null, 1);
      end;
    end;
  finally
    pos.Free;
    scanfile.Free;
    infile.Free;
  end;
  stop := GetTickCount;
  elapsed := stop - start;
  writeln('Time Taken: ' + IntToStr(elapsed) + ' ms');

end.
