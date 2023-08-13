page 50181 "TFB Quality Docs Dialog"
{
    PageType = StandardDialog;
    Caption = 'Quality Docs Dialog';
    ApplicationArea = All;
    UsageCategory = Administration;


    layout
    {
        area(Content)
        {
            group(Choices)
            {
                grid(GridLayout)
                {
                    GridLayout = Rows;
                    ShowCaption = false;
                    field(_CompanyCertifications; _CompanyCertifications)
                    {
                        ToolTip = 'Specifies whether download/email should include our own certifications';
                        Caption = 'Our own certifications';
                    }
                    field(VendorCertifications; _VendorCertifications)
                    {
                        ToolTip = 'Specifies whether download/email should include vendor certifications';
                        Caption = 'Vendor certifications';
                    }
                    group(CompanyCertificationChoice)
                    {
                        Visible = _VendorCertifications;
                        ShowCaption = false;
                        field(_ReligiousCertifications; _ReligiousCertifications)
                        {
                            ToolTip = 'Specifies whether religious certifications should be included';
                            Caption = 'Religious certifications';
                        }
                    }
                    group(Action)
                    {
                        InstructionalText = 'Choose what should happen after certifications gathered';
                        ShowCaption = false;
                        field(_DownLoad; _DownLoad)
                        {
                            ToolTip = 'Specifies if you want to download instead of emailing';
                            Caption = 'Download only';
                        }

                        group(GatherContact)
                        {
                            ShowCaption = false;
                            Visible = not _DownLoad;

                            field(_CompressFilesInEmail; _CompressFilesInEmail)
                            {
                                ToolTip = 'Specifies if all files should be placed in a ZIP file in email';
                                Caption = 'Use single zip archive';
                            }
                            field(_RecipientsText; _RecipientsText)
                            {
                                ToolTip = 'Specifies the list of contacts who should receive the email';
                                Caption = 'Recipients';
                                AssistEdit = true;
                                Editable = false;

                                trigger OnAssistEdit()

                                var
                                    Contact: Record Contact;
                                    Customer: Record Customer;
                                    ContactList: Page "Contact List";
                                    token: text;
                                    Recipients: List of [Text];


                                begin
                                    _RecipientsText := '';
                                    if Customer.get(_CustomerNo) then begin
                                        Contact.SetRange("Company No.", Customer."TFB Primary Contact Company ID");
                                        Contact.SetFilter("E-Mail", '>%1', '');
                                        ContactList.SetTableView(Contact);
                                        ContactList.LookupMode(true);

                                        if ContactList.RunModal() = Action::LookupOK then begin

                                            Contact.SetFilter("No.", ContactList.GetSelectionFilter());

                                            if Contact.Findset(false) then
                                                repeat
                                                    if Contact."E-Mail" <> '' then
                                                        if not Recipients.Contains(Contact."E-Mail") then
                                                            Recipients.Add(Contact."E-Mail");

                                                until Contact.Next() = 0;

                                            if Recipients.Count > 0 then
                                                foreach token in Recipients do
                                                    _RecipientsText += token + ';'

                                        end;
                                    end;
                                end;
                            }
                        }
                    }
                }

            }
        }
    }



    var
        _VendorCertifications: Boolean;
        _CompanyCertifications: Boolean;
        _ReligiousCertifications: Boolean;
        _RecipientsText: Text;
        _CompressFilesInEmail: Boolean;
        _DownLoad: Boolean;
        Recipients: List of [Text];

        _CustomerNo: Code[20];

    procedure SetCustomerNo(CustomerNo: COde[20])

    begin
        _CustomerNo := CustomerNo;
    end;

    procedure getVendCertSel(): Boolean

    begin
        exit(_VendorCertifications)
    end;

    procedure getCompCertSel(): Boolean
    begin
        exit(_CompanyCertifications)
    end;

    procedure getCompressSel(): Boolean

    begin
        exit(_CompressFilesInEmail)
    end;

    procedure getReligCertSel(): Boolean
    begin
        exit(_ReligiousCertifications)
    end;

    procedure getDownloadSel(): Boolean

    begin
        exit(_DownLoad);
    end;

    procedure getRecipients(): List of [Text]

    begin
        exit(Recipients);
    end;

}