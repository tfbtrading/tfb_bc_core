pageextension 50110 "TFB Customer Card" extends "Customer Card"
{


    layout
    {
        modify("Address & Contact")
        {
            Caption = 'Address & Primary Contact';
        }
        addlast(Shipping)
        {
            field("TFB Reservation Strategy"; Rec."TFB Reservation Strategy")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the type of reservation strategy that will be used by the customer';
            }
            field("TFB Delivery Instructions"; Rec."Delivery Instructions")
            {
                ApplicationArea = All;
                MultiLine = True;
                ToolTip = 'Specifies special delivery instructions non-specific to ship-to address';
            }
            field("TFB CoA Required"; Rec."TFB CoA Required")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the customer requires a Certificate of Analysis with shipment notice';
            }
            group(CoADetails)
            {
                Visible = Rec."TFB CoA Required";
                ShowCaption = false;
                field("TFB CoA Alt. Email"; Rec."TFB CoA Alt. Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if there is an alternative email to receive certificates of analysis';
                }
            }
            field("TFB PalletExchange"; Rec.PalletExchange)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if customer does a pallet exchange';
            }
            group(PalletDetails)
            {
                Visible = not Rec.PalletExchange;
                ShowCaption = false;
                field("TFB PalletAccountType"; Rec."TFB Pallet Acct Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if customer has a pallet account';
                }

                field("TFB PalletAccountNo"; Rec.PalletAccountNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies pallet account number for specific account type';

                }
            }
        }
        addafter("Address & Contact")
        {

            part(IndividualContacts; "TFB Company Contacts Subform")
            {
                Caption = 'All Contacts';

                ApplicationArea = All;
                SubPageLink = "Company No." = field("TFB Primary Contact Company ID");
                SubPageView = where(Type = const(Person));
            }

        }
        addafter("Bill-to Customer No.")
        {
            field("TFB Parent Company"; Rec."TFB Parent Company")
            {
                ApplicationArea = All;
                ToolTip = 'Specify the parent company to track consolidated sales for a group';

            }
        }

        addafter("Customer Disc. Group")
        {
            field("TFB Show Per Kg Only"; Rec."TFB Show Per Kg Only")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if customer only wants to see per kilogram pricing';
            }

        }
        addafter("Last Date Modified")
        {
            field("Last Modified Date Time"; Rec.SystemModifiedAt)
            {
                ApplicationArea = All;
                Importance = Additional;
                ToolTip = 'Shows the date a customer record was  last modified';
            }
        }
        addafter("Disable Search by Name")
        {
            field("TFB External No. Req."; Rec."TFB External No. Req.")
            {
                ApplicationArea = All;
                Importance = Standard;
                Description = 'Indicates whether a sales order should have a PO reference in order to be released.';
                ToolTip = 'Specifies if a customer purchase order reference is required prior to release of the order';

            }
            field("TFB Lead Mgmt System"; Rec."TFB Lead Mgmt System")
            {
                ApplicationArea = All;
                Importance = Standard;
                Tooltip = 'Specifies if the customer is now activately managed in a separate lead management system';

            }
            group(CommunicationPreferences)
            {
                ShowCaption = true;
                Caption = 'Relationship and Communication Details';
                InstructionalText = 'Indicates how and when customers receive notifications';

                group(Status)
                {
                    ShowCaption = false;

                    field("TFB Contact Status"; Rec."TFB Contact Status")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the contact status';
                    }

                }

                field("TFB Stock Update Recipient"; Rec."TFB Stock Update Recipient")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    Description = 'Indicates if they receive a daily stock update';
                    ToolTip = 'Specifies if customer receives a daily stock update';
                }
                field("TFB Order Update Preference"; Rec."TFB Order Update Preference")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies if customer receives mass order updates';
                }
                field("TFB Enable Online Access"; Rec."TFB Enable Online Access")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies if contacts for this customer can be enabled for digital access';
                }
                field("TFB Price List Recipient"; Rec."TFB Price List Recipient")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies if customer is eligible to receive a price list';
                }
                field("TFB Price List Partial"; Rec."TFB Price List Partial")
                {
                    ApplicationArea = All;
                    Importance = standard;
                    Tooltip = 'Specifies if customer price list only shows favourite and recently purchased items';
                }
                field("TFB Price List Hide Vendor"; Rec."TFB Price List Hide Vendor")
                {
                    ApplicationArea = All;
                    Importance = standard;
                    ToolTip = 'Specifies if the vendor for the goods should be displayed on their price list';
                }
            }
        }

        addbefore(Statistics)
        {
            part(CustProfile; "Contact Card Subform")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Profile Questionnaire';
                SubPageLink = "Contact No." = field("TFB Primary Contact Company ID");
                UpdatePropagation = SubPart;
            }
        }

        addbefore(CustomerStatisticsFactBox)
        {
            part(ContactStatistics; "Contact Statistics FactBox")
            {
                ApplicationArea = RelationshipMgmt;
                SubPageLink = "No." = FIELD("TFB Primary Contact Company ID"),
                              "Date Filter" = FIELD("Date Filter");
            }
        }
    }


    actions
    {
        addlast(creation)
        {
            action("Create Opportunity")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Opportunity';
                Image = NewOpportunity;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Opportunity Card";
                RunPageLink = "Contact No." = FIELD("TFB Primary Contact Company ID"),
                              "Contact Company No." = FIELD("TFB Primary Contact Company ID");
                RunPageMode = Create;
                ToolTip = 'Register a sales opportunity for the customer';
            }

        }
        addlast("F&unctions")
        {
            action(AutoPopulate)
            {
                ApplicationArea = All;
                Promoted = True;
                PromotedCategory = Process;
                Image = Item;
                Caption = 'Auto Populate Favourites';
                ToolTip = 'Populates items in the favourites for customer';

                trigger OnAction()

                var
                    CU: CodeUnit "TFB Cust. Fav. Items";
                begin

                    CU.PopulateOneCustomer(Rec."No.");
                end;
            }



            action(UpdateContactID)
            {
                ApplicationArea = All;
                Image = UpdateDescription;
                Caption = 'Update Contact ID';
                ToolTip = 'Update the contact link for this customer';

                trigger OnAction()

                var
                    ContBusRel: Record "Contact Business Relation";
                begin
                    ContBusRel.SetCurrentKey("Link to Table", "No.");
                    ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                    ContBusRel.SetRange("No.", Rec."No.");
                    if ContBusRel.FindFirst() then begin

                        Rec."TFB Primary Contact Company ID" := ContBusRel."Contact No.";
                        Rec.Modify();
                    end;
                end;
            }
        }
        addafter("Co&mments")
        {
            Action(FavouriteItems)
            {
                Caption = 'Favourite Items';
                Promoted = true;
                PromotedCategory = Category8;
                PromotedOnly = false;
                Image = List;
                ApplicationArea = All;
                ToolTip = 'Managed list of favourite items';

                RunObject = page "TFB Cust. Fav. Items";
                RunPageLink = "Customer No." = field("No."), "List No." = filter('DEFAULT');


            }
        }
        addafter(PaymentRegistration)
        {
            action(SendStatementsByEmail)
            {
                Caption = 'Send Statement';
                Promoted = True;
                PromotedCategory = Process;
                Image = Email;
                ApplicationArea = All;
                ToolTip = 'Sends an account statement to the customer';

                trigger OnAction()
                var
                    CustomerCU: CodeUnit "TFB Customer Mgmt";
                begin

                    CustomerCU.SendStatementToOneCustomer(Rec."No.");

                end;
            }
            action(SendOrderUpdateByEmail)
            {
                Caption = 'Send Order Update';
                Promoted = True;
                PromotedCategory = Process;
                Image = Email;
                ApplicationArea = All;
                ToolTip = 'Sends a update on outstanding orders and recently invoiced orders';

                trigger OnAction()

                var
                    CustomerCU: Codeunit "TFB Customer Mgmt";

                begin
                    CustomerCU.SendOneCustomerStatusEmail(Rec."No.");
                end;
            }
            action(SendQualityDocumentsByEmail)
            {
                Caption = 'Send Quality Certifications';
                Promoted = True;
                PromotedCategory = Process;
                Image = Email;
                ApplicationArea = All;
                ToolTip = 'Sends any relevant quality certifications for vendors to customer';

                trigger OnAction()

                var
                    QualityCU: Codeunit "TFB Quality Mgmt";

                begin
                    QualityCU.SendQualityDocumentsToCustomer(Rec."No.", false);
                end;
            }

        }
    }



}