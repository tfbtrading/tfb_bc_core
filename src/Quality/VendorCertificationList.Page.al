page 50107 "TFB Vendor Certification List"
{
    PageType = List;
    Caption = 'Vendor Certification List';
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Vendor Certification";
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    ModifyAllowed = true;
    PromotedActionCategories = 'New,Certificate';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field(EmoticonStatus; CalculatedEmoticonStatus)
                {
                    Caption = 'Status';
                    ShowCaption = false;
                    Width = 3;
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies status of vendor certification';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies vendor number';

                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies vendors name';
                }
                field(Site; Rec.Site)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies vendors facility that is certified';
                }
                field("Certification Type"; Rec."Certification Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the certification type';
                }
                field("Certification Class"; Rec."Certificate Class")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    lookup = false;
                    tooltip = 'Specifies the class of certification';
                }
                field(Auditor; Rec.Auditor)
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies who audited the site and granted certification';
                }
                field("Last Audit Date"; Rec."Last Audit Date")
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the date on which the last audit was conducted';
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the date on which the certification will expire';

                    trigger OnValidate()

                    begin
                        DaysToExpiry := QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
                        CalculatedStatus := QualityCU.GetCurrentStatus(Rec);
                        IsCertificateAvailable := CheckIfCertificateExists();
                        CalculatedEmoticonStatus := QualityCU.GetStatusEmoticon(CalculatedStatus);
                    end;
                }
                field(CertificateExists; IsCertificateAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'Certificate Exists';
                    ShowCaption = false;
                    Editable = False;
                    tooltip = 'Specifies if certificate is attached';
                }
                field("Days To Expiry"; DaysToExpiry)
                {
                    ApplicationArea = All;
                    Caption = 'Days to Expiry';
                    Tooltip = 'Specifies the number of days until the certification expires';
                }
                field(Status; CalculatedStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Calc. Status';
                    Tooltip = 'Specifies the calculated status of the certification';
                }

            }
        }
        area(Factboxes)
        {

            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }


        }





    }



    actions
    {
        area(Processing)
        {

            action("Attach certificate")
            {

                ApplicationArea = All;
                Visible = True;
                Promoted = True;
                PromotedCategory = Process;
                Image = Import;
                Enabled = true;
                PromotedOnly = true;
                Tooltip = 'Attaches a certificate (in pdf form) to vendor certfication record';

                trigger OnAction()

                begin
                    AttachFile();
                end;

            }
            action("Download certificate")
            {
                ApplicationArea = All;
                Visible = True;
                Promoted = True;
                PromotedCategory = Process;
                Image = SendAsPDF;
                Enabled = IsCertificateAvailable;
                PromotedOnly = true;
                Caption = 'Download certificate(s)';
                tooltip = 'Download a certificate (in pdf form) from certification record';
                trigger OnAction()

                begin
                    DownloadFile();
                end;
            }
            action("Remove CoA")
            {
                ApplicationArea = All;
                Visible = True;
                Promoted = True;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Delete;
                Enabled = IsCertificateAvailable;
                ToolTip = 'Remove current certificate';

                trigger OnAction()

                begin
                    RemoveFile();
                end;

            }


        }
    }


    views
    {
        view("AttentionRequired")
        {
            Caption = 'Attention Required';
            Filters = where("Expiry Date" = filter('<w+1w'));
            SharedLayout = true;
        }


        view("Quality")
        {
            Caption = 'Quality Only';
            Filters = where("Certificate Class" = const(Quality));
            SharedLayout = true;
        }
        view("Religious")
        {
            Caption = 'Religious Only';
            Filters = where("Certificate Class" = const(Religous));
            SharedLayout = true;
        }
    }

    var
        QualityCU: Codeunit "TFB Quality Mgmt";
        DaysToExpiry: Integer;
        CalculatedStatus: Enum "TFB Quality Certificate Status";
        IsCertificateAvailable: Boolean;
        CalculatedEmoticonStatus: Text;


    trigger OnAfterGetRecord()

    begin
        DaysToExpiry := QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
        CalculatedStatus := QualityCU.GetCurrentStatus(Rec);
        IsCertificateAvailable := CheckIfCertificateExists();
        CalculatedEmoticonStatus := QualityCU.GetStatusEmoticon(CalculatedStatus);

    end;

    local Procedure CheckIfCertificateExists(): Boolean

    var
        PersBlobCU: CodeUnit "Persistent Blob";

    begin

        If PersBlobCU.Exists(Rec."Certificate Attach.") then
            Exit(true)
        else
            Exit(false);

    end;



    local procedure AttachFile()

    var

        TempBlobCU: Codeunit "Temp Blob";
        PersBlobCU: CodeUnit "Persistent Blob";
        BlobKey: BigInteger;
        FilterTxt: Label 'All files (*.pdf)|*.pdf';
        FileDialogTxt: Label 'Select Certificate File to Upload';
        FileName: Text;
        InStream: InStream;

    begin


        TempBlobCU.CreateInStream(InStream);
        FileName := QualityCU.GetCertificateFileName(rec);
        if UploadIntoStream(FileDialogTxt, '', FilterTxt, FileName, InStream) then begin
            BlobKey := PersBlobCU.Create();
            If PersBlobCU.CopyFromInStream(BlobKey, InStream) then begin
                Rec."Certificate Attach." := BlobKey;
                rec.Modify();
                IsCertificateAvailable := true;
            end;

        end;
    end;


    local procedure DownloadFile()

    var

        SelRecs: Record "TFB Vendor Certification";
        TempBlobCU: Codeunit "Temp Blob";
        PersBlobCU: CodeUnit "Persistent Blob";
        ZipTempBlob: CodeUnit "Temp Blob";
        DataCompCU: CodeUnit "Data Compression";
        TempBlobList: CodeUnit "Temp Blob List";
        FileNameList: List of [Text];
        InStream: InStream;
        OutStream: Outstream;
        FileName: Text;
        i: integer;

    begin

        CurrPage.SetSelectionFilter(SelRecs);

        if SelRecs.Count() > 1 then begin
            if SelRecs.FindSet(false, false) then begin
                repeat
                    TempBlobCU.CreateOutStream(OutStream);
                    PersBlobCU.CopyToOutStream(SelRecs."Certificate Attach.", OutStream);
                    TempBlobCU.CreateInStream(InStream);
                    TempBlobList.Add(TempBlobCU);
                    FileNameList.Add(QualityCU.GetCertificateFileName(SelRecs));

                until SelRecs.Next() < 1;

                If TempBlobList.Count() >= 1 then begin
                    DataCompCU.CreateZipArchive();

                    for i := 1 to TempBlobList.Count() do begin
                        TempBlobList.Get(i, TempBlobCu);
                        TempBlobCu.CreateInStream(InStream);
                        FileName := FileNameList.Get(i);
                        DataCompCU.AddEntry(InStream, FileName);

                    end;

                    DataCompCU.SaveZipArchive(ZipTempBlob);
                    ZipTempBlob.CreateInStream(InStream);
                    FileName := StrSubstNo('Vendor certificates x %1.zip', TempBlobList.Count());
                    If not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
                        Error('File %1 not downloaded', FileName);
                end;
            end;
        end
        else
            If (Rec."Certificate Attach." > 0) and (PersBlobCU.Exists(Rec."Certificate Attach.")) then begin

                FileName := QualityCU.GetCertificateFileName(Rec);
                TempBlobCU.CreateOutStream(OutStream);
                PersBlobCU.CopyToOutStream(Rec."Certificate Attach.", OutStream);
                TempBlobCU.CreateInStream(InStream);


                If Not DownloadFromStream(InStream, 'Title', 'ToFolder', 'Filter', FileName) then
                    Error('File Not Downloaded');
            end;
    end;

    local procedure RemoveFile()

    var
        PersBlobCU: CodeUnit "Persistent Blob";

    begin

        PersBlobCU.Delete(Rec."Certificate Attach.");
        CheckIfCertificateExists();

    end;


}