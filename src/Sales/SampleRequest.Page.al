page 50142 "TFB Sample Request"
{
    Caption = 'Sample Request';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Order,Request Approval,History,Print/Send,Navigate';
    RefreshOnActivate = true;
    SourceTable = "TFB Sample Request";


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }

                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    Caption = 'Contact';
                    Editable = true;
                    ToolTip = 'Specifies the name of the person to contact at the customer.';


                }
                field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact No.';
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the contact person that the sales document will be sent to.';
                    editable = false;


                    trigger OnValidate()

                    begin
                        SellToContact.Get(Rec."Sell-to Contact No.");
                        CurrPage.Update();
                    end;
                }
                group(HideCustomer)
                {
                    Visible = Rec."Sell-to Customer No." <> '';
                    ShowCaption = false;

                    field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer No.';
                        Importance = Additional;
                        Editable = false;

                        ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';

                        trigger OnValidate()
                        begin

                            CurrPage.Update();
                        end;
                    }
                    field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer Name';
                        Editable = false;

                        ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';

                        trigger OnValidate()
                        begin

                            CurrPage.Update();
                        end;


                    }
                }
                group(HideContact)
                {
                    ShowCaption = false;
                    Visible = Rec."Sell-to Customer No." = '';

                    field(IsLeadOnly; true)
                    {
                        Caption = 'Lead only (not customer)';
                        ToolTip = 'Indicates that this is not a customer';
                        ApplicationArea = All;
                    }
                }

                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the date the order was created. The order date is also used to determine the prices and discounts on the document.';
                }

                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date that the customer has asked for the sample(s) to be delivered.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }


                group("Ship-to")
                {
                    Caption = 'Sell-to';
                    field("Sell-to Address"; Rec."Address")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Address';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address where the customer is located.';
                    }
                    field("Sell-to Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Address 2';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Sell-to City"; Rec."City")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'City';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the customer on the sales document.';
                    }
                    group(Control123)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                        field("Sell-to County"; Rec."County")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'County';
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Sell-to Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Sell-to Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country or region of the address.';

                        trigger OnValidate()
                        begin
                            IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
                        end;
                    }

                    field("Sell-to Phone No."; SellToContact."Phone No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ToolTip = 'Specifies the telephone number of the contact person that the sales document will be sent to.';
                    }
                    field(SellToMobilePhoneNo; SellToContact."Mobile Phone No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Mobile Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the mobile telephone number of the contact person that the sales document will be sent to.';
                    }
                    field("Sell-to E-Mail"; SellToContact."E-Mail")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Email';
                        Importance = Additional;
                        Editable = false;
                        ToolTip = 'Specifies the email address of the contact person that the sales document will be sent to.';
                    }
                }




                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';


                }
                field("Campaign No."; Rec."Campaign No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the campaign that the document is linked to.';
                }
                field("Opportunity No."; Rec."Opportunity No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the opportunity that the sales quote is assigned to.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    StyleExpr = StatusStyleTxt;
                    QuickEntry = false;
                    ToolTip = 'Specifies whether the document is open, waiting to be approved, has been invoiced for prepayment, or has been released to the next stage of processing.';
                }
                group("Work Description")
                {
                    Caption = 'Request context';
                    field(WorkDescription; WorkDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the products or service being offered.';

                        trigger OnValidate()
                        begin
                            Rec.SetWorkDescription(WorkDescription);
                        end;
                    }
                }
            }
            part(Lines; "TFB Sample Request Subform")
            {
                ApplicationArea = Basic, Suite;
                Editable = DynamicEditable;
                Enabled = (Rec."Sell-to Contact No." <> '') and (not (Rec.Status = Rec.Status::Sent));
                SubPageLink = "Document No." = FIELD("No.");
                UpdatePropagation = Both;


            }

            group("Transport Options")
            {
                Caption = 'Shipping and Billing';
                group(Control91)
                {
                    ShowCaption = false;
                    group(Control90)
                    {
                        ShowCaption = false;

                        group("Shipment Method")
                        {
                            Caption = 'Shipment Method';

                            field("Shipping Agent Code"; rec."Shipping Agent Code")
                            {
                                ApplicationArea = Suite;
                                Caption = 'Agent';
                                Importance = Promoted;
                                ToolTip = 'Specifies which shipping agent is used to transport the items on the sales document to the customer.';
                            }

                            field("Package Tracking No."; Rec."Package Tracking No.")
                            {
                                ApplicationArea = Suite;
                                Importance = Promoted;
                                ToolTip = 'Specifies the shipping agent''s package number.';
                            }
                        }
                    }

                }
            }
        }
        area(factboxes)
        {

            part(ContactDetails; "Contact Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Sell-to Contact No.");
                Visible = Rec."Sell-to Contact No." = '';
            }
            part(SalesHistory; "Sales Hist. Sell-to FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Sell-to Customer No.");
                Visible = Rec."Sell-to Customer No." <> '';
            }

            part(CustomerDetails; "Customer Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Sell-to Customer No.");
                Visible = Rec."Sell-to Customer No." <> '';
            }
            part(ItemDetails; "Item Picture")
            {
                ApplicationArea = Basic, Suite;
                Provider = Lines;
                SubPageLink = "No." = field("No.");
                Visible = Rec.LinesExist = true;
                Caption = '';
            }
            part(ItemWarehouse; "Item Warehouse FactBox")
            {
                ApplicationArea = Basic, Suite;
                Provider = Lines;
                SubPageLink = "No." = field("No.");
                Visible = Rec.LinesExist = true;
                Caption = '';
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Print)
            {
                ApplicationArea = All;
                Image = Print;
                Caption = 'Print Packing Slip';
                ToolTip = 'Print a packing slip';
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ReportSelection: Record "Report Selections";
                    ReportUsage: Enum "Report Selection Usage";
                begin

                    Rec.SetRecFilter();

                    ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Sample.Request");
                    ReportSelection.SetRange("Use for Email Attachment", true);
                    If ReportSelection.findfirst() then
                        ReportSelection.PrintWithDialogForCust(
                           ReportUsage, Rec, GuiAllowed, Rec.FieldNo("Sell-to Customer No."));

                end;
            }

            action(EmailRequest)
            {
                ApplicationArea = All;
                Image = Print;
                Caption = 'Email Requests';
                ToolTip = 'Email requests where required to warehouse and suppliers';
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ReportSelection: Record "Report Selections";

                begin

                    Rec.SetRecFilter();

                    ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Sample.Request.Warehouse");
                    ReportSelection.SetRange("Use for Email Attachment", true);
                    If ReportSelection.findfirst() then begin
                            //TODO Need to add functionality here


                    end;




                end;
            }
        }
    }

    var
        SellToContact: Record Contact;
        FormatAddress: Codeunit "Format Address";
        DocNoVisible: Boolean;
        DynamicEditable: Boolean;
        IsSellToCountyVisible: Boolean;
        WorkDescription: Text;
        [InDataSet]
        StatusStyleTxt: Text;

    trigger OnOpenPage()

    var
    begin
        SetDocNoVisible();
        IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
    end;

    local procedure SetDocNoVisible()
    var
   

    begin
        DocNoVisible := false;
    end;

    trigger OnAfterGetRecord()

    begin
        If Rec."Sell-to Contact No." <> '' then
            SellToContact.Get(Rec."Sell-to Contact No.")
        else
            Clear(SellToContact);
    end;

    trigger OnAfterGetCurrRecord()

    begin
        StatusStyleTxt := Rec.GetStatusStyleText();
        DynamicEditable := CurrPage.Editable;

    end;


}