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
    DelayedInsert = true;
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
                    Caption = 'Certification';

                    trigger OnValidate()

                    begin
                        Rec.CalcFields("Certificate Class");
                    end;
                }
                field("Certification Class"; Rec."Certificate Class")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    lookup = false;
                    tooltip = 'Specifies the class of certification';
                }
                field(Status; CalculatedStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Editable = false;
                    Tooltip = 'Specifies the calculated status of the certification';
                    Style = Favorable;
                    StyleExpr = CalculatedStatus = CalculatedStatus::Active;
                }
                field(Inherent; Rec.Inherent)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the claimed certification is inherent to the product rather than requiring an external authority. Only available for religious type of certification';
                    Enabled = Rec."Certification Class" = Rec."Certificate Class"::Religous;

                    trigger OnValidate()
                    begin
                        DaysToExpiry := QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
                        CalculatedStatus := QualityCU.GetCurrentStatus(Rec);
                        IsCertificateAvailable := CheckIfCertificateExists();
                        CalculatedEmoticonStatus := QualityCU.GetStatusEmoticon(CalculatedStatus);
                    end;
                }
                field(Auditor; Rec.Auditor)
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies who audited the site and granted certification';
                    Enabled = Rec."Certification Class" <> Rec."Certificate Class"::Religous;
                }
                field("Last Audit Date"; Rec."Last Audit Date")
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the date on which the last audit was conducted';
                    Enabled = Rec."Certification Class" <> Rec."Certificate Class"::Religous;
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the date on which the certification will expire';
                    Enabled = Rec."Certification Class" <> Rec."Certificate Class"::Religous;

                    trigger OnValidate()

                    begin
                        DaysToExpiry := QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
                        CalculatedStatus := QualityCU.GetCurrentStatus(Rec);
                        IsCertificateAvailable := CheckIfCertificateExists();
                        CalculatedEmoticonStatus := QualityCU.GetStatusEmoticon(CalculatedStatus);
                    end;
                }
                field("Days To Expiry"; DaysToExpiry)
                {
                    ApplicationArea = All;
                    Editable = false;
                    BlankZero = true;
                    Caption = 'Days to Expiry';
                    Tooltip = 'Specifies the number of days until the certification expires';
                }
                field(CertificateExists; CheckIfCertificateExists())
                {
                    ApplicationArea = All;
                    Caption = 'Attach.';
                    ShowCaption = true;
                    Editable = False;
                    tooltip = 'Specifies if an attachment exists';
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

            action("Send to Contact")
            {
                ApplicationArea = All;
                Visible = True;
                Promoted = true;
                promotedCategory = Process;
                PromotedOnly = true;
                Image = SendEmailPDF;
                ToolTip = 'Send one or more selected vendor certificates based on a prompt for a contact';

                trigger OnAction()

                begin
                    SendSelectedDocs();
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

    local procedure SendSelectedDocs()

    var
        VendorCerts: Record "TFB Vendor Certification";
        Contact: Record Contact;
        ContactList: Page "Contact List";
        Recipients: List of [Text];

        CLib: CodeUnit "TFB Common Library";
        QLib: CodeUnit "TFB Quality Mgmt";

        Result: Boolean;
        SubTitleTxt: Label '';
        Text001Msg: Label 'Sending Vendor Certifications';
        TitleTxt: Label 'Vendor Certifications Email';



    begin

        //Determine if multiple items have been selected

        CurrPage.SetSelectionFilter(VendorCerts);

        If VendorCerts.Count() = 0 then exit;
        Contact.SetFilter("E-Mail", '>%1', '');
        ContactList.LookupMode(true);
        ContactList.SetTableView(Contact);

        If ContactList.RunModal() = Action::LookupOK then begin
            ContactList.getrecord(Contact);
            Contact.SetFilter("No.", ContactList.GetSelectionFilter());

            If Contact.FindSet(false, false) then
                repeat
                    If Contact."E-Mail" <> '' then
                        If not Recipients.Contains(Contact."E-Mail") then
                            Recipients.Add(Contact."E-Mail");

                until Contact.Next() = 0;

            If Recipients.Count > 0 then begin

                QLib.SendVendorCertificationEmail(VendorCerts, Recipients, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));

            end;
        end;


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