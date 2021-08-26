page 50149 "TFB Company Certification List"
{
    PageType = List;
    Caption = 'Company Certification List';
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Company Certification";
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
                field("Location Specific"; Rec."Location Specific")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the certification is for a specific location';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Location Specific";
                    ToolTip = 'Specifies the location if the certificaton is location specific';
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
                field(EmoticonStatus; CalculatedEmoticonStatus)
                {

                    ShowCaption = false;
                    Width = 1;
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies status of vendor certification';
                }
                field(Inherent; Rec.Inherent)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the claimed certification is inherent to the product rather than requiring an external authority. Only available for religious type of certification';
                    Enabled = Rec."Certificate Class" = Rec."Certificate Class"::Religous;

                    trigger OnValidate()
                    begin
                        _DaysToExpiry := QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
                        CalculatedStatus := QualityCU.GetCurrentStatus(Rec.Archived, Rec.Inherent, Rec."Expiry Date");
                        AttachmentExists := CheckIfAttachmentExists();

                    end;
                }
                field(Auditor; Rec.Auditor)
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies who audited the site and granted certification';
                    Enabled = not ((Rec."Certificate Class" = Rec."Certificate Class"::Religous) and Rec.Inherent);
                }
                field("Last Audit Date"; Rec."Last Audit Date")
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the date on which the last audit was conducted';
                    Enabled = not ((Rec."Certificate Class" = Rec."Certificate Class"::Religous) and Rec.Inherent);
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = All;
                    tooltip = 'Specifies the date on which the certification will expire';
                    Enabled = not ((Rec."Certificate Class" = Rec."Certificate Class"::Religous) and Rec.Inherent);
                    Style = Unfavorable;
                    StyleExpr = (_DaysToExpiry < 30) and (not Rec.Archived);

                    trigger OnValidate()

                    begin

                        CalculatedStatus := QualityCU.GetCurrentStatus(Rec.Archived, Rec.Inherent, Rec."Expiry Date");
                        AttachmentExists := CheckIfAttachmentExists();
                        CurrPage.Update();
                    end;
                }
                field("Days To Expiry"; _DaysToExpiry)
                {
                    ApplicationArea = All;
                    Editable = false;
                    BlankZero = true;
                    Caption = 'Days to Expiry';
                    Tooltip = 'Specifies the number of days until the certification expires';
                    Style = Unfavorable;
                    StyleExpr = (_DaysToExpiry < 30) and (not Rec.Archived);
                }
                field(CertificateExists; AttachmentExists)
                {
                    ApplicationArea = All;
                    Caption = 'Attach.';
                    ShowCaption = true;
                    Editable = False;
                    tooltip = 'Specifies if an attachment exists';
                    Style = Unfavorable;
                    StyleExpr = (AttachmentExists = false);
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

            action("Upload Attachment")
            {

                ApplicationArea = All;
                Visible = True;
                Promoted = True;
                PromotedCategory = Process;
                Image = Import;
                Enabled = (AttachmentExists = false);
                PromotedOnly = true;
                Tooltip = 'Attaches a certificate (in pdf form) to vendor certfication record';

                trigger OnAction()

                begin
                    AttachFile();
                end;

            }
            action("Download Attachment(s)")
            {
                ApplicationArea = All;
                Visible = True;
                Promoted = True;
                PromotedCategory = Process;
                Image = SendAsPDF;
                Enabled = AttachmentExists;
                PromotedOnly = true;

                tooltip = 'Download one or more attachments (in pdf form) from certification record';
                trigger OnAction()

                begin
                    DownloadFile();
                end;
            }

            action("Send to Contact(s)")
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
            action("Replace File")
            {
                ApplicationArea = All;
                Visible = True;
                Image = DocumentEdit;
                Enabled = AttachmentExists;
                ToolTip = 'Remove current attachment and replace with new file';

                trigger OnAction()

                begin
                    ReplaceFile();
                end;

            }
            action("Remove File")
            {
                ApplicationArea = All;
                Visible = True;
                Image = Delete;
                Enabled = AttachmentExists;
                ToolTip = 'Remove current attachment';

                trigger OnAction()

                begin
                    RemoveFile();
                end;

            }

            action("Toggle Archived")
            {
                ApplicationArea = All;
                Visible = True;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;


                ToolTip = 'Set current vendor certificate to be archived';

                trigger OnAction()

                begin
                    ToggleArchiveStatus();
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
        AttachmentExists: Boolean;
        _DaysToExpiry: Integer;
        CalculatedStatus: Enum "TFB Quality Certificate Status";
        CalculatedEmoticonStatus: Text;


    trigger OnAfterGetRecord()

    begin

        _DaysToExpiry := QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
        CalculatedStatus := QualityCU.GetCurrentStatus(Rec.Archived, Rec.Inherent, Rec."Expiry Date");
        AttachmentExists := CheckIfAttachmentExists();
        CalculatedEmoticonStatus := QualityCU.GetStatusEmoticon(CalculatedStatus);

    end;


    local procedure GetExpiryDays(): Integer

    begin
        If Rec.Archived then
            Exit(0)
        else
            QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
    end;

    local procedure ToggleArchiveStatus()

    var

    begin

        If (CalculatedStatus = CalculatedStatus::Expired) or (CalculatedStatus = CalculatedStatus::Inherent) or (Rec.Archived) then begin


            If rec.Archived then begin
                if confirm('Are you sure you want to restore to non-archived status?', true) then
                    rec.Archived := false;
            end
            else
                if confirm('Are you sure you want to archive this vendor certificate?', false) then begin
                    rec.Archived := true;
                    rec.Modify(false);
                    CurrPage.Update(true);
                end;

        end
        else
            Message('Only valid for expired or expired, inherent or archived certificates');

        CalculatedStatus := QualityCU.GetCurrentStatus(Rec.Archived, Rec.Inherent, Rec."Expiry Date");
        CalculatedEmoticonStatus := QualityCU.GetStatusEmoticon(CalculatedStatus);
    end;

    local Procedure CheckIfAttachmentExists(): Boolean

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
        Contact: Record Contact;
        CompanyCerts: Record "TFB Company Certification";
        CLib: CodeUnit "TFB Common Library";
        QLib: CodeUnit "TFB Quality Mgmt";
        ContactList: Page "Contact List";
        Recipients: List of [Text];
        SubTitleTxt: Label '';
        TitleTxt: Label 'Company Certifications Email';


    begin

        //Determine if multiple items have been selected

        CurrPage.SetSelectionFilter(CompanyCerts);

        If CompanyCerts.Count() = 0 then exit;
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

            If Recipients.Count > 0 then
                QLib.SendCompanyCertificationEmail(CompanyCerts, Recipients, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));

        end;


    end;

    local procedure ReplaceFile()

    var
        FileManagement: CodeUnit "File Management";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        BlobKey: BigInteger;
        FileDialogTxt: Label 'Select Certificate File to Upload';
        FileFilterTxt: Label 'All files (*.pdf)|*.pdf';
        ExtFilterTxt: Label 'pdf';


    begin

        PersBlobCU.Delete(Rec."Certificate Attach.");


        FileManagement.BLOBImportWithFilter(TempBlob, FileDialogTxt, '', FileFilterTxt, ExtFilterTxt);
        If TempBlob.HasValue() then begin

            BlobKey := PersBlobCU.Create();
            TempBlob.CreateInStream(InStream);
            If PersBlobCU.CopyFromInStream(BlobKey, InStream) then begin
                Rec."Certificate Attach." := BlobKey;
                rec.Modify();
                AttachmentExists := true;
            end;

        end;

    end;

    local procedure AttachFile()

    var
        FileManagement: CodeUnit "File Management";
        PersistentBlob: CodeUnit "Persistent Blob";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        BlobKey: BigInteger;

        FileDialogTxt: Label 'Select Certificate File to Upload';
        FileFilterTxt: Label 'All files (*.pdf)|*.pdf';
        ExtFilterTxt: Label 'pdf';


    begin



        FileManagement.BLOBImportWithFilter(TempBlob, FileDialogTxt, '', FileFilterTxt, ExtFilterTxt);

        If TempBlob.HasValue() then begin

            BlobKey := PersistentBlob.Create();
            TempBlob.CreateInStream(InStream);
            If PersistentBlob.CopyFromInStream(BlobKey, InStream) then begin
                Rec."Certificate Attach." := BlobKey;
                rec.Modify();
                AttachmentExists := true;
            end;

        end;
    end;


    local procedure DownloadFile()

    var
        SelRecs: Record "TFB Company Certification";
        DataCompCU: CodeUnit "Data Compression";
        PersBlobCU: CodeUnit "Persistent Blob";
        TempBlobCU: Codeunit "Temp Blob";
        TempBlobList: CodeUnit "Temp Blob List";
        ZipTempBlob: CodeUnit "Temp Blob";
        InStream: InStream;
        OutStream: Outstream;
        i: integer;
        FileName: Text;
        FileNameList: List of [Text];


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
        CheckIfAttachmentExists();

    end;


}