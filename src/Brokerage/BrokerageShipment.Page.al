page 50229 "TFB Brokerage Shipment"
{
    PageType = Document;
    SourceTable = "TFB Brokerage Shipment";
    UsageCategory = None;
    Caption = 'Brokerage Shipment';
    DataCaptionFields = "No.", "Customer Name";
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            group("General")
            {

                field("No."; Rec."No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the no. sequence for the document';

                }
                field("Contract No."; Rec."Contract No.")
                {
                    TableRelation = "TFB Brokerage Contract";
                    ToolTip = 'Specifies the related contract no. for brokerage shipment';


                }
                field("Customer No."; Rec."Customer No.")
                {
                    Importance = Additional;
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'Specifies the customer no';

                }
                field("Customer Name"; Rec."Customer Name")
                {
                    Importance = Promoted;
                    Editable = false;
                    ToolTip = 'Specifies the customer name';

                }
                field("Sell-to Address"; Rec."Sell-to Address")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the customer sell-to address. Automatically filled in.';
                }
                field("Sell-to City"; Rec."Sell-to City")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the sell-to city';
                }
                field("Sell-to County"; Rec."Sell-to County")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the county';
                }
                field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the country/region code';
                }
                field("Sell-to Phone No."; Rec."Sell-to Phone No.")
                {
                    Importance = Additional;
                    Tooltip = 'Specifies the customer phone no';
                }
                field("Vendor No."; Rec."Buy From Vendor No.")
                {
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'Specifies the vendor no';

                }
                field("Vendor Name"; Rec."Buy From Vendor Name")
                {
                    Importance = Promoted;
                    Editable = false;
                    Lookup = true;
                    ToolTip = 'Specifies the vendor name';
                }
                field("Customer Reference"; Rec."Customer Reference")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the customer reference';
                }
                field("Document Date"; Rec."Document Date")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the document date';
                }
                field("Est. Sailing Date"; Rec."Est. Sailing Date")
                {
                    Caption = 'Required Sailing Date';
                    ToolTip = 'Specifies the estimated date the vessel departs origin';
                }
                field("Required Arrival Date"; Rec."Required Arrival Date")
                {
                    ToolTip = 'Specifies the approximate date the goods should arrive at destination';
                }
                field("Container Route"; Rec."Container Route")
                {
                    ToolTip = 'Specifies the container route';
                }

                field("Vendor Reference"; Rec."Vendor Reference")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the vendor reference for the shipment';

                }
                field(Bulkers; Rec.Bulkers)
                {
                    Importance = Additional;
                    Caption = 'Use Bulker Bags';
                    ToolTip = 'Specifies whether bulkers are supplied for the shipment';

                    trigger OnValidate()

                    begin

                        CurrPage.Lines.Page.Update(false);
                    end;
                }

                group(BulkersWeight)
                {
                    Visible = Rec.Bulkers;
                    ShowCaption = false;

                    field("Bulker Weight (mt)"; Rec."Bulker Weight (mt)")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies weight in metric tonnes for bulkers';
                    }
                }

                field("Special Instructions"; Rec."Special Instructions")
                {
                    Importance = Additional;
                    MultiLine = true;
                    ToolTip = 'Specifies the special instructions required for the brokerage shipment from the customer';
                }



            }
            group(Tracking)
            {

                field("Status"; Rec."Status")
                {
                    Editable = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies the status of the brokerage shipment';


                }
                field(Printed; Rec.Printed)
                {
                    Editable = false;
                    Importance = Standard;
                    ToolTip = 'Specifies how many times document has been emailed or printed';
                    Style = Favorable;
                    StyleExpr = Rec.Printed > 0;
                }
                field(Closed; Rec.Closed)
                {
                    Editable = false;
                    Tooltip = 'Specifies if the shipment is closed';
                }

                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies the shipping agent used by the vendor on this shipment';
                }


                group(ASN)
                {
                    Visible = (Rec.status = Rec.status::"In Progress") or (Rec.status = Rec.status::"Supplier Invoiced");
                    ShowCaption = false;
                    field("Booking Reference"; Rec."Booking Reference")
                    {
                        ToolTip = 'Specifies the booking reference';
                    }
                    field("Vessel Details"; Rec."Vessel Details")
                    {
                        Tooltip = 'Specifies vessel details for shipment';
                    }
                    field("Est. Departure Date"; Rec."Est. Departure Date")
                    {
                        Tooltip = 'Specifies est. departure date of vessel booked';
                    }
                    field("Est. Arrival Date"; Rec."Est. Arrival Date")
                    {
                        ToolTip = 'Specifies est. arrival date of vessel booked';
                    }

                    field("Container No."; Rec."Container No.")
                    {
                        Importance = Promoted;
                        Tooltip = 'Specifies container number for shipment';
                    }
                }

            }

            group(Financials)
            {


                field(Amount; Rec.Amount)
                {
                    DrillDown = false;
                    ToolTip = 'Specifies total amount of shipment';
                }
                field("Brokerage Fee"; Rec."Brokerage Fee")
                {
                    DrillDown = false;
                    ToolTip = 'Specifies brokerage fee for shipment';
                }
                field("Applied Invoice"; Rec."Applied Invoice")
                {
                    Editable = false;
                    Tooltip = 'Specifies invoice applied to brokerage shipment';

                    trigger OnDrillDown()

                    var
                        PstdInv: Record "Sales Invoice Header";
                        Inv: Record "Sales Header";

                        PstdInvPage: Page "Posted Sales Invoice";
                        InvPage: Page "Sales Invoice";

                    begin
                        if Rec."Applied Invoice" <> '' then begin

                            Inv.SetRange("Document Type", Inv."Document Type"::Invoice);
                            Inv.SetRange("No.", Rec."Applied Invoice");

                            if Inv.FindFirst() then begin
                                InvPage.SetRecord(Inv);
                                InvPage.Run();
                            end else begin
                                PstdInv.SetRange("No.", Rec."Applied Invoice");

                                if PstdInv.FindFirst() then begin
                                    PstdInvPage.SetRecord(PstdInv);
                                    PstdInvPage.Run();
                                end;
                            end;


                        end;

                    end;
                }

                group("VendorInvoice")
                {
                    Caption = 'Vendor Invoice Details';
                    Visible = (Rec.status = Rec.status::"In Progress") or (Rec.status = Rec.status::"Supplier Invoiced");
                    ShowCaption = true;

                    field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                    {
                        Caption = 'No.';
                        ToolTip = 'Specifies the vendor invoice no.';
                    }
                    field("Vendor Invoice Date"; Rec."Vendor Invoice Date")
                    {
                        Importance = Standard;
                        Caption = 'Issued Date';
                        Tooltip = 'Specifies the vendor invoice date';

                        trigger OnValidate()

                        begin
                            Rec."Vendor Invoice Due Date" := BrokerageCU.CalcInvDueDate(Rec."Buy From Vendor No.", Rec."Vendor Invoice Date");
                        end;

                    }
                    field("Vendor Invoice Due Date"; Rec."Vendor Invoice Due Date")
                    {
                        Importance = Additional;
                        Caption = 'Due Date';
                        ToolTip = 'Specifies the vendor invoice date';
                    }

                }
            }
            part(Lines; "TFB Brokerage Shipment Subform")
            {
                Caption = 'Lines';
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
                Visible = true;
            }



        }

        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }

        }

    }
    actions
    {
        area(Navigation)
        {
            action("RelatedContract")
            {
                Caption = 'Related contract';
                RunObject = Page "TFB Brokerage Contract";
                RunPageLink = "No." = field("Contract No.");
                RunPageMode = Edit;
                Image = FileContract;

                ToolTip = 'Opens related contract';
            }
        }
        area(Processing)
        {
            action("Email Supplier")
            {


                Image = SendConfirmation;
                Caption = 'Send to Supplier';
                ToolTip = 'Sends confirmation for brokerage shipment';

                trigger OnAction()

                begin
                    SendEmail();
                end;
            }

            action("Email Customer")
            {


                Image = SendConfirmation;
                Enabled = Rec.Status = Rec.Status::"In Progress";
                Caption = 'Send Update to Customer';
                ToolTip = 'Sends update for brokerage shipment to customer';

                trigger OnAction()

                begin
                    BrokerageCU.SendOneBrokerageUpdateEmail(Rec."No.");
                end;
            }
            action("Sent Emails")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sent Emails';
                Image = ShowList;
                ToolTip = 'View a list of emails that you have sent to related to this shipment.';


                trigger OnAction()
                var
                    Email: Codeunit Email;
                begin
                    Email.OpenSentEmails(Database::"TFB Brokerage Shipment", Rec.SystemId);
                end;
            }
            action("NewDraftInvoice")
            {

                Image = Invoice;
                Enabled = (Rec.Status = Rec.Status::"In Progress") and (Rec."Vendor Invoice No." <> '');
                Caption = 'Make invoice';
                ToolTip = 'Creates a new draft invoice for brokerage shipment';

                trigger OnAction()

                var
                    Inv: Record "Sales Header";
                    InvPage: Page "Sales Invoice";


                begin

                    Clear(Inv);

                    if BrokerageCU.RaiseInvoiceFromShipment(Rec, Inv) then begin
                        CurrPage.Update(false);


                        if Dialog.Confirm('Draft invoice %1 created - would you like to open it?', true, Inv."No.") then begin
                            InvPage.SetRecord(Inv);
                            InvPage.Run();

                        end;

                    end;
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';

                actionref(NewDraftInvoiceRef; NewDraftInvoice)
                {

                }
            }
            group(Category_PrintSend)
            {
                Caption = 'Print/Send';

                actionref(EmailSupplierRef; "Email Supplier")
                {

                }
                actionref(EmailCustomerRef; "Email Customer")
                {

                }
            }
            group(Category_Shipment)
            {
                Caption = 'Shipment';

                actionref(RelatedContractRef; RelatedContract)
                {

                }
                actionref(SentEmailRef; "Sent Emails")
                {

                }
            }
        }
    }


    trigger OnAfterGetRecord()

    begin

    end;


    var
        BrokerageCU: CodeUnit "TFB Brokerage Mgmt";

    /// <summary> 
    /// Embedded procedureused by action to send email 
    /// </summary>
    local procedure SendEmail()

    var
        RepSel: Record "Report Selections";
        CommEntry: Record "TFB Comm. Log Entry";
        CompanyInfo: Record "Company Information";
        Contract: record "TFB Brokerage Contract";
        Contact: record Contact;
        Vendor: Record Vendor;
        Email: CodeUnit Email;
        EmailMessage: CodeUnit "Email Message";

        TempBlob: CodeUnit "Temp Blob";

        CLib: CodeUnit "TFB Common Library";
        DocumentRef: RecordRef;
        OutStream: OutStream;
        InStream: InStream;

        Window: Dialog;
        Text001Msg: Label 'Sending Brokerage Shipment:\#1############################', Comment = '%1=Brokerage Shipment Number';
        TitleTxt: Label 'Brokerage Shipment Instruction';
        SubTitleTxt: Label '';
        Recipients: List of [Text];
        HTMLBuilder: TextBuilder;
        SubjectNameBuilder: TextBuilder;
        EmailScenEnum: Enum "Email Scenario";
        EmailAction: enum "Email Action";

    begin

        if not Vendor.Get(Rec."Buy From Vendor No.") then
            Error('No Vendor Record Found');

        if contract.get(rec."Contract No.") and contact.get(contract."Buy-from Contact No.") and (contact."E-Mail" <> '') then
            Recipients.Add(contact."E-Mail")
        else
            if Vendor."E-Mail" = '' then
                Error('No Vendor Email Found')
            else
                Recipients.Add(Vendor."E-Mail");



        CompanyInfo.Get();

        SubjectNameBuilder.Append(StrSubstNo('Brokerage Shipment Instruction %1 from TFB Trading', Rec."No."));


        Rec.SetRecFilter();
        DocumentRef.GetTable(Rec);
        TempBlob.CreateOutStream(OutStream);

        RepSel.SetRange(Usage, RepSel.Usage::"S.Brok.Shipment");
        RepSel.SetRange("Use for Email Attachment", true);
        Window.Open(Text001Msg);
        Window.Update(1, STRSUBSTNO(Text001Msg, Rec."No."));
        HTMLBuilder.Append(CLib.GetHTMLTemplateActive(TitleTxt, SubTitleTxt));
        if RepSel.FindFirst() then
            if REPORT.SaveAs(RepSel."Report ID", '', ReportFormat::Pdf, OutStream, DocumentRef) and GenerateBrokerageContent(HTMLBuilder) then begin


                EmailMessage.Create(Recipients, SubjectNameBuilder.ToText(), HTMLBuilder.ToText(), true);

                TempBlob.CreateInStream(InStream);
                EmailMessage.AddAttachment(StrSubstNo('Brokerage Shipment %1.pdf', Rec."No."), 'application/pdf', InStream);
                Email.AddRelation(EmailMessage, Database::"TFB Brokerage Shipment", Rec.SystemId, Enum::"Email Relation Type"::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
                Email.AddRelation(EmailMessage, Database::Vendor, Vendor.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

                if not (Email.OpenInEditorModally(EmailMessage, EmailScenEnum::Logistics) = EmailAction::Discarded) then begin
                    CommEntry.Init();
                    CommEntry."Source Type" := CommEntry."Source Type"::Vendor;
                    CommEntry."Source ID" := Vendor."No.";
                    CommEntry."Source Name" := Vendor.Name;
                    CommEntry."Record Type" := commEntry."Record Type"::SOC;
                    CommEntry."Record Table No." := Database::"TFB Brokerage Shipment";
                    CommEntry."Record No." := Rec."No.";
                    CommEntry.Direction := CommEntry.Direction::Outbound;
                    CommEntry.Method := CommEntry.Method::EMAIL;
                    CommEntry.Insert();
                    Rec.Printed += 1;
                end;


            end;

    end;

    /// <summary> 
    /// Generates template content for transaction email introduction
    /// </summary>
    /// <param name="Shipment">Parameter of type Record "TFB Brokerage Shipment".</param>
    /// <param name="HTMLBuilder">Parameter of type TextBuilder.</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure GenerateBrokerageContent(var HTMLBuilder: TextBuilder): Boolean

    var

        BodyBuilder: TextBuilder;
        ReferenceBuilder: TextBuilder;

    begin
        HTMLBuilder.Replace('%{ExplanationCaption}', 'Notification type');
        HTMLBuilder.Replace('%{ExplanationValue}', 'Brokerage Shipment');
        HTMLBuilder.Replace('%{DateCaption}', 'Requested Shipment Date');
        HTMLBuilder.Replace('%{DateValue}', Format(Rec."Est. Sailing Date", 0, 4));
        HTMLBuilder.Replace('%{ReferenceCaption}', 'Order References');
        ReferenceBuilder.Append(StrSubstNo('Our order %1', Rec."No."));
        if Rec."Customer Reference" <> '' then
            ReferenceBuilder.Append(StrSubstNo(' and customer ref no. is %1', Rec."Customer Reference"));
        HTMLBuilder.Replace('%{ReferenceValue}', ReferenceBuilder.ToText());
        HTMLBuilder.Replace('%{AlertText}', '');
        HTMLBuilder.Replace('%{EmailContent}', BodyBuilder.ToText());
        exit(true);
    end;
}