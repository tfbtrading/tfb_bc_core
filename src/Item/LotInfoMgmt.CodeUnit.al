codeunit 50100 "TFB Lot Info Mgmt"
{
    trigger OnRun()
    begin

    end;

    procedure AttachFile(IDT: enum "TFB Item Doc Type"; var LotInfo: Record "Lot No. Information"): BigInteger

    var
        TempBlob: CodeUnit "Temp Blob";
        FileManagement: Codeunit "File Management";
        PersBlobCU: Codeunit "Persistent Blob";
        FileFilterTxt: Label 'All files (*.pdf)|*.pdf';
        ExtFilterTxt: Label 'pdf';
        FileDialogTxt: Label 'Select file', comment = '%1=Type of File';
        InStream: InStream;
        BlobKey: BigInteger;



    begin


        TempBlob.CreateInStream(InStream);

        FileManagement.BLOBImportWithFilter(TempBlob, FileDialogTxt, '', FileFilterTxt, ExtFilterTxt);

        If TempBlob.HasValue() then begin
            TempBlob.CreateInStream(InStream);
            BlobKey := PersBlobCU.Create();
            If PersBlobCU.CopyFromInStream(BlobKey, InStream) then begin

                case IDT of
                    IDT::COA:
                        LotInfo."TFB CoA Attach." := BlobKey;
                    IDT::OPC:
                        LotInfo."TFB OPC Attach." := BlobKey;
                end;

                LotInfo.Modify();
                Exit(BlobKey);
            end;
        end;
    end;


    procedure DownloadFile(IDT: Enum "TFB Item Doc Type"; LotInfo: Record "Lot No. Information")

    var
        TempBlobCU: Codeunit "Temp Blob";
        PersBlobCU: CodeUnit "Persistent Blob";
        InStream: InStream;
        OutStream: Outstream;
        Ref: BigInteger;
        FileName: Text;

    begin




        case IDT of
            IDT::COA:
                begin
                    FileName := GetCoAFileName(LotInfo);
                    Ref := LotInfo."TFB CoA Attach.";
                end;
            IDT::OPC:
                begin
                    FileName := GetOPCFileName(LotInfo);
                    Ref := LotInfo."TFB OPC Attach.";
                end;

        end;

        If (Ref > 0) and (PersBlobCU.Exists(Ref)) then begin

            TempBlobCU.CreateOutStream(OutStream);
            TempBlobCU.CreateInStream(InStream);
            PersBlobCU.CopyToOutStream(Ref, OutStream);
            CopyStream(OutStream, InStream);
            If Not DownloadFromStream(InStream, 'Title', 'ToFolder', 'Filter', FileName) then
                Error('File Not Downloaded');
        end;
    end;

    procedure GetCoAFileName(Rec: Record "Lot No. Information"): Text

    var
        FileNameBuilder: TextBuilder;
    begin
        FileNameBuilder.Append('COA_');
        FileNameBuilder.Append(rec."Item No.");
        FileNameBuilder.Append('_');
        FileNameBuilder.Append(rec."Lot No.");
        FileNameBuilder.Append('.pdf');
        Exit(FileNameBuilder.ToText());
    end;

    procedure GetOPCFileName(Rec: Record "Lot No. Information"): Text

    var
        FileNameBuilder: TextBuilder;
    begin
        FileNameBuilder.Append('OPC_');
        FileNameBuilder.Append(rec."Item No.");
        FileNameBuilder.Append('_');
        FileNameBuilder.Append(rec."Lot No.");
        FileNameBuilder.Append('.pdf');
        Exit(FileNameBuilder.ToText());
    end;


    procedure RemoveFile(IDT: Enum "TFB Item Doc Type"; var LotInfo: Record "Lot No. Information"): Boolean

    var
        PersBlobCU: CodeUnit "Persistent Blob";
        Ref: BigInteger;


    begin

        case IDT of
            IDT::COA:
                Ref := LotInfo."TFB CoA Attach.";

            IDT::OPC:
                Ref := LotInfo."TFB OPC Attach.";


        end;

        If PersBlobCU.Delete(Ref) then begin
            case IDT of
                IDT::COA:
                    LotInfo."TFB CoA Attach." := 0;

                IDT::OPC:
                    LotInfo."TFB CoA Attach." := 0;

            end;
            LotInfo.Modify(false);
            Exit(true);
        end;
    end;


}