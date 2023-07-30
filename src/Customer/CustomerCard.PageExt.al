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
            field("TFB Delivery Instructions"; Rec."TFB Delivery Instructions")
            {
                ApplicationArea = All;
                MultiLine = true;
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
            field("TFB PalletExchange"; Rec."TFB Pallet Exchange")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if customer does a pallet exchange';
            }
            group(PalletDetails)
            {
                Visible = not Rec."TFB Pallet Exchange";
                ShowCaption = false;
                field("TFB PalletAccountType"; Rec."TFB Pallet Acct Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if customer has a pallet account';
                }

                field("TFB PalletAccountNo"; Rec."TFB Pallet Account No")
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
        addbefore("Shipping Agent Code")
        {
            label(Info)
            {
                ApplicationArea = All;
                MultiLine = true;
                Style = AttentionAccent;
                StyleExpr = true;
                Caption = 'Only relevant if override location shipping enabled';
            }
        }

        modify("Shipping Agent Code")
        {
            Enabled = Rec."TFB Override Location Shipping";
        }
        modify("Shipping Agent Service Code")
        {
            Enabled = Rec."TFB Override Location Shipping";
        }
        modify("Shipping Time")
        {
            Enabled = Rec."TFB Override Location Shipping";
        }

        addafter("Location Code")
        {
            field("TFB Override Location Shipping"; Rec."TFB Override Location Shipping")
            {
                Caption = 'Override Location Shipping';
                ApplicationArea = All;
                ToolTip = 'Specifies that details used on customer form should supercede that of location';
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
                group(OrderUpdate)
                {
                    Visible = Rec."TFB Stock Update Recipient";
                    ShowCaption = false;
                    field("TFB Order Update Preference"; Rec."TFB Order Update Preference")
                    {
                        ApplicationArea = All;
                        Caption = 'Stock update preference';
                        Importance = Standard;
                        ToolTip = 'Specifies if customer receives mass order updates';
                    }
                }
                field("TFB Quality Docs Recipient"; Rec."TFB Quality Docs Recipient")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies if the customer receives relevant updates to related quality documents';
                    AboutText = 'Can be used to automate communication of updates, rather than waiting until an audit';
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

                group(PriceList)
                {
                    Visible = Rec."TFB Price List Recipient";
                    ShowCaption = false;
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
                SubPageLink = "No." = field("TFB Primary Contact Company ID"),
                              "Date Filter" = field("Date Filter");
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

                RunObject = Page "Opportunity Card";
                RunPageLink = "Contact No." = field("TFB Primary Contact Company ID"),
                              "Contact Company No." = field("TFB Primary Contact Company ID");
                RunPageMode = Create;
                ToolTip = 'Register a sales opportunity for the customer';
            }

        }
        addlast("F&unctions")
        {
            action(AutoPopulate)
            {
                ApplicationArea = All;

                Image = Item;
                Caption = 'Refresh Favourites';
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
            action(TFBFavouriteItems)
            {
                Caption = 'Favourite Items';

                Image = List;
                ApplicationArea = All;
                ToolTip = 'Managed list of favourite items';

                RunObject = page "TFB Cust. Fav. Items";
                RunPageLink = "Customer No." = field("No."), "List No." = filter('DEFAULT');


            }
        }
        addafter(PaymentRegistration)
        {
            action(TFBSendStatementByEmail)
            {
                Caption = 'Send Statement';

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
            action(TFBSendOrderUpdateByEmail)
            {
                Caption = 'Send Order Update';

                Image = Email;
                ApplicationArea = All;
                ToolTip = 'Sends a update on outstanding orders and recently invoiced orders';

                trigger OnAction()

                var
                    CustomerCU: Codeunit "TFB Customer Mgmt";

                begin
                    CustomerCU.SendOneCustomerStatusEmail(Rec."No.", '', '');
                end;
            }
            action(TFBSendQualityDocumentsByEmail)
            {
                Caption = 'Send Quality Certifications';

                Image = Email;
                ApplicationArea = All;
                ToolTip = 'Sends any relevant quality certifications for vendors to customer';

                trigger OnAction()

                var
                    QualityCU: Codeunit "TFB Quality Mgmt";
                    ConfirmMgt: CodeUnit "Confirm Management";

                begin
                    QualityCU.SendQualityDocumentsToCustomer(Rec."No.", ConfirmMgt.GetResponseOrDefault('Get only quality documents or full set', true));
                end;
            }



        }
        addlast(Category_Process)
        {
            actionref(TFBSendStatementByEmail_Promoted; TFBSendStatementByEmail)
            {

            }
            actionref(TFBSendQualityDocumentsByEmail_Promoted; TFBSendQualityDocumentsByEmail)
            {

            }
            actionref(TFBSendOrderUpdateByEmail_Promoted; TFBSendOrderUpdateByEmail)
            {

            }

        }
        addlast(Category_Category9)
        {
            actionref(ActionRefName; TFBFavouriteItems)
            {

            }
        }



    }



}