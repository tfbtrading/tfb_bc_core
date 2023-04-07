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


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Certification Type"; Rec."Certification Type")
                {
                    Tooltip = 'Specifies the certification type';
                    Caption = 'Certification';

                    trigger OnValidate()

                    begin
                        Rec.CalcFields("Certificate Class");
                    end;
                }
                field("Certification Class"; Rec."Certificate Class")
                {
                    DrillDown = false;
                    lookup = false;
                    tooltip = 'Specifies the class of certification';
                }
                field("Location Specific"; Rec."Location Specific")
                {
                    ToolTip = 'Specifies whether the certification is for a specific location';
                }
                field("Location Code"; Rec."Location Code")
                {
                    Enabled = Rec."Location Specific";
                    ToolTip = 'Specifies the location if the certificaton is location specific';
                }
                field(Status; CalculatedStatus)
                {
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
                    ToolTip = 'Specifies status of vendor certification';
                }
                field(Inherent; Rec.Inherent)
                {
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
                    tooltip = 'Specifies who audited the site and granted certification';
                    Enabled = not ((Rec."Certificate Class" = Rec."Certificate Class"::Religous) and Rec.Inherent);
                }
                field("Last Audit Date"; Rec."Last Audit Date")
                {
                    tooltip = 'Specifies the date on which the last audit was conducted';
                    Enabled = not ((Rec."Certificate Class" = Rec."Certificate Class"::Religous) and Rec.Inherent);
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
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
                field("Certification No."; Rec."Certification No.")
                {
                    Editable = true;
                    Caption = 'Certification No.';
                    ToolTip = 'Specifies the unique certification number for organisation if provided';

                }
                field("Days To Expiry"; _DaysToExpiry)
                {
                    Editable = false;
                    BlankZero = true;
                    Caption = 'Days to Expiry';
                    Tooltip = 'Specifies the number of days until the certification expires';
                    Style = Unfavorable;
                    StyleExpr = (_DaysToExpiry < 30) and (not Rec.Archived);
                }
                field(CertificateExists; AttachmentExists)
                {
                    Caption = 'Attach.';
                    ShowCaption = true;
                    Editable = false;
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
            }
            systempart(Notes; Notes)
            {
            }


        }





    }



    actions
    {
        area(Processing)
        {

            action(UploadAttach)
            {
                Visible = true;
                Caption = 'Upload Attachment';
                Enabled = not AttachmentExists;
                Image = Import;


                Tooltip = 'Attaches a certificate (in pdf form) to vendor certfication record';

                trigger OnAction()

                begin
                    AttachFile();
                end;

            }
            action(ReplaceAttach)
            {
                Visible = true;
                Caption = 'Replace Attachment';
                Enabled = AttachmentExists;
                Image = Import;


                Tooltip = 'Replaces existing ertificate (in pdf form) to vendor certfication record';

                trigger OnAction()

                begin
                    ReplaceFile();
                end;

            }
            action(RemoveAttach)
            {
                Visible = true;
                Caption = 'Remove Attachment';
                Enabled = AttachmentExists;
                Image = Import;

                Tooltip = 'Removes existing certificate (in pdf form) to vendor certfication record';

                trigger OnAction()

                begin
                    RemoveFile();
                end;

            }
            action(DownloadAttach)
            {
                Visible = true;
                Caption = 'Download Attachment';
                Image = SendAsPDF;
                Enabled = AttachmentExists;


                tooltip = 'Download one or more attachments (in pdf form) from certification record';
                trigger OnAction()

                begin
                    DownloadFile();
                end;
            }

            action(SendToContact)
            {
                Visible = true;
                Caption = 'Send to Contacts';
                Image = SendEmailPDF;
                ToolTip = 'Send one or more selected vendor certificates based on a prompt for a contact';

                trigger OnAction()

                begin
                    SendSelectedDocs();
                end;
            }


            action("ToggleArchived")
            {
                Visible = true;
                Image = Archive;


                ToolTip = 'Set current vendor certificate to be archived';

                trigger OnAction()

                begin
                    ToggleArchiveStatus();
                end;

            }


        }
        area(Promoted)
        {
            group(Certificate)
            {
                ShowAs = SplitButton;
                actionref(UploadAttach_Promoted; UploadAttach)
                {

                }
                actionref(SendToContact_Promoted; SendToContact)
                {

                }
                actionref(ReplaceAttach_Promoted; ReplaceAttach)
                {

                }
            }
            actionref(ToggleArchived_Promoted; ToggleArchived)
            {

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



    local procedure ToggleArchiveStatus()

    var

    begin

        if (CalculatedStatus = CalculatedStatus::Expired) or (CalculatedStatus = CalculatedStatus::Inherent) or (Rec.Archived) then begin


            if rec.Archived then begin
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

    local procedure CheckIfAttachmentExists(): Boolean

    var
        PersBlobCU: CodeUnit "Persistent Blob";

    begin

        if PersBlobCU.Exists(Rec."Certificate Attach.") then
            exit(true)
        else
            exit(false);

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

        if CompanyCerts.Count() = 0 then exit;
        Contact.SetFilter("E-Mail", '>%1', '');
        ContactList.LookupMode(true);
        ContactList.SetTableView(Contact);

        if ContactList.RunModal() = Action::LookupOK then begin
            ContactList.getrecord(Contact);
            Contact.SetFilter("No.", ContactList.GetSelectionFilter());

            if Contact.Findset(false) then
                repeat
                    if Contact."E-Mail" <> '' then
                        if not Recipients.Contains(Contact."E-Mail") then
                            Recipients.Add(Contact."E-Mail");

                until Contact.Next() = 0;

            if Recipients.Count > 0 then
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




        FileManagement.BLOBImportWithFilter(TempBlob, FileDialogTxt, '', FileFilterTxt, ExtFilterTxt);
        if TempBlob.HasValue() then begin

            BlobKey := PersBlobCU.Create();
            TempBlob.CreateInStream(InStream);
            if PersBlobCU.CopyFromInStream(BlobKey, InStream) then begin
                PersBlobCU.Delete(Rec."Certificate Attach.");
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

        if AttachmentExists then
            if not Confirm('Attachment already exist - replace?', true) then exit;

        FileManagement.BLOBImportWithFilter(TempBlob, FileDialogTxt, '', FileFilterTxt, ExtFilterTxt);

        if TempBlob.HasValue() then begin

            BlobKey := PersistentBlob.Create();
            TempBlob.CreateInStream(InStream);
            if PersistentBlob.CopyFromInStream(BlobKey, InStream) then begin
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
            if SelRecs.Findset(false) then begin
                repeat
                    TempBlobCU.CreateOutStream(OutStream);
                    PersBlobCU.CopyToOutStream(SelRecs."Certificate Attach.", OutStream);
                    TempBlobCU.CreateInStream(InStream);
                    TempBlobList.Add(TempBlobCU);
                    FileNameList.Add(QualityCU.GetCertificateFileName(SelRecs));

                until SelRecs.Next() < 1;

                if TempBlobList.Count() >= 1 then begin
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
                    if not DownloadFromStream(InStream, 'File Download', '', '', FileName) then
                        Error('File %1 not downloaded', FileName);
                end;
            end;
        end
        else
            if (Rec."Certificate Attach." > 0) and (PersBlobCU.Exists(Rec."Certificate Attach.")) then begin

                FileName := QualityCU.GetCertificateFileName(Rec);
                TempBlobCU.CreateOutStream(OutStream);
                PersBlobCU.CopyToOutStream(Rec."Certificate Attach.", OutStream);
                TempBlobCU.CreateInStream(InStream);


                if not DownloadFromStream(InStream, 'Title', 'ToFolder', 'Filter', FileName) then
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