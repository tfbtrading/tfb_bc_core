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


    layout
    {
        area(Content)
        {
            repeater(Group)
            {


                field("Vendor Name"; Rec."Vendor Name")
                {
                    Tooltip = 'Specifies vendors name';

                    Style = Subordinate;
                    StyleExpr = Rec.Archived;


                    trigger OnValidate()

                    begin
                        OrderAddressExists := CheckIfOrderAddressExists();
                    end;
                }
                field(Site; Rec.Site)
                {
                    Tooltip = 'Specifies vendors facility that is certified';
                    Style = Subordinate;
                    StyleExpr = Rec.Archived;
                }
                field("Vendor Order Address"; Rec."Vendor Order Address")
                {
                    ToolTip = 'Specifies vendors specific order address if one exists';
                    Enabled = OrderAddressExists;
                    Style = StandardAccent;
                    StyleExpr = Rec.Archived;
                }
                field("Certification Type"; Rec."Certification Type")
                {
                    Tooltip = 'Specifies the certification type';
                    Caption = 'Certification';
                    Style = Subordinate;
                    StyleExpr = Rec.Archived;

                    trigger OnValidate()

                    begin
                        Rec.CalcFields("Certificate Class");
                    end;
                }
                field("Certification Class"; Rec."Certificate Class")
                {
                    DrillDown = false;
                    Style = Subordinate;
                    StyleExpr = Rec.Archived;
                    lookup = false;
                    tooltip = 'Specifies the class of certification';
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
                    Style = Subordinate;
                    StyleExpr = Rec.Archived;
                }
                field("Last Audit Date"; Rec."Last Audit Date")
                {
                    tooltip = 'Specifies the date on which the last audit was conducted';
                    Enabled = not ((Rec."Certificate Class" = Rec."Certificate Class"::Religous) and Rec.Inherent);
                    Style = Subordinate;
                    StyleExpr = Rec.Archived;
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

                    end;
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
                field("No. Of Items"; Rec."No. Of Items")
                {
                    Editable = false;
                    ApplicationArea = all;
                    ToolTip = 'Specifies how many items are covered by this quality certification';
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

            action("UploadAttach")
            {
                Caption = 'Upload Attachment';
                Visible = (AttachmentExists = false);
                Image = Import;
                Enabled = (AttachmentExists = false);
                Tooltip = 'Attaches a certificate (in pdf form) to vendor certfication record';

                trigger OnAction()

                begin
                    AttachFile();
                end;

            }
            action("DownloadAttach")
            {
                Caption = 'Download Attachment';
                Visible = (AttachmentExists = true);
                Image = SendAsPDF;
                Enabled = AttachmentExists;

                tooltip = 'Download one or more attachments (in pdf form) from certification record';
                trigger OnAction()

                begin
                    DownloadFile();
                end;
            }

            action("SendToContact")
            {
                Caption = 'Send to Contacts';
                Visible = true;
                Image = SendEmailPDF;
                ToolTip = 'Send one or more selected vendor certificates based on a prompt for a contact';

                trigger OnAction()

                begin
                    SendSelectedDocs();
                end;
            }

            action("ToggleArchived")
            {
                Caption = 'Toggle Archived';
                Visible = true;
                Image = Archive;

                ToolTip = 'Set current vendor certificate to be archived';

                trigger OnAction()

                begin
                    ToggleArchiveStatus();
                end;

            }

            action("ReplaceFile")
            {
                Visible = (AttachmentExists = true);
                Image = DocumentEdit;
                Caption = 'Replace Attachment';
                Enabled = AttachmentExists;
                ToolTip = 'Removes current attachment and replace with new file';

                trigger OnAction()

                begin
                    HandleReplaceFile();
                end;

            }
            action("RemoveFile")
            {
                Visible = (AttachmentExists = true);
                Image = Delete;
                Caption = 'Remove Attachment';
                Enabled = AttachmentExists;
                ToolTip = 'Remove current attachment';

                trigger OnAction()

                begin
                    HandleRemoveFile();
                end;

            }


        }
        area(Promoted)
        {
            group(Upload)
            {
                ShowAs = SplitButton;
                actionref(UploadAttach_Promoted; UploadAttach)
                {

                }
                actionref(DownloadAttach_Promoted; DownloadAttach)
                {

                }
                actionref(ReplaceFile_Promoted; ReplaceFile)
                {

                }
            }

            actionref(SendToContact_Promoted; SendToContact)
            {

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
        OrderAddressExists: Boolean;


    trigger OnAfterGetRecord()

    begin

        _DaysToExpiry := QualityCU.CalcDaysToExpiry(Rec."Expiry Date");
        CalculatedStatus := QualityCU.GetCurrentStatus(Rec.Archived, Rec.Inherent, Rec."Expiry Date");
        AttachmentExists := CheckIfAttachmentExists();
        CalculatedEmoticonStatus := QualityCU.GetStatusEmoticon(CalculatedStatus);
        OrderAddressExists := CheckIfOrderAddressExists();

    end;

    local procedure CheckIfOrderAddressExists(): Boolean

    var
        OrderAddress: Record "Order Address";
    begin

        OrderAddress.SetRange("Vendor No.", Rec."Vendor No.");

        exit(not OrderAddress.IsEmpty())

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
        VendorCerts: Record "TFB Vendor Certification";
        CLib: CodeUnit "TFB Common Library";
        QLib: CodeUnit "TFB Quality Mgmt";
        ContactList: Page "Contact List";
        Recipients: List of [Text];
        SubTitleTxt: Label '';
        TitleTxt: Label 'Vendor Certifications Email';


    begin

        //Determine if multiple items have been selected

        CurrPage.SetSelectionFilter(VendorCerts);

        if VendorCerts.Count() = 0 then exit;
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
                QLib.SendVendorCertificationEmail(VendorCerts, Recipients, CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));

        end;


    end;

    local procedure HandleReplaceFile()

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
        if TempBlob.HasValue() then begin

            BlobKey := PersBlobCU.Create();
            TempBlob.CreateInStream(InStream);
            if PersBlobCU.CopyFromInStream(BlobKey, InStream) then begin
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
        SelRecs: Record "TFB Vendor Certification";
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

    local procedure HandleRemoveFile()

    var
        PersBlobCU: CodeUnit "Persistent Blob";

    begin

        PersBlobCU.Delete(Rec."Certificate Attach.");
        CheckIfAttachmentExists();

    end;


}