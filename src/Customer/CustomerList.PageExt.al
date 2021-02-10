pageextension 50111 "TFB Customer List" extends "Customer List"
{
    layout
    {
        addbefore(Name)
        {
            Field(ToDoExists; GetTaskSymbol())
            {
                Caption = '';
                Width = 1;
                ShowCaption = false;
                ToolTip = 'Specifies if a task exists';
                DrillDown = false;
                ApplicationArea = All;

            }
        }
        addafter("Customer Price Group")
        {
            field("TFB Price List Recipient"; Rec."TFB Price List Recipient")
            {
                Caption = 'Recipient';
                Editable = true;
                ApplicationArea = All;
                ToolTip = 'Specifies if customer is a price list recipient';
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
        addafter("Co&mments")
        {
            Action(FavouriteItems)
            {
                Caption = 'Favourite Items';
                Promoted = true;
                PromotedCategory = Category7;
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
                Caption = 'Send Statements';
                Promoted = True;
                PromotedCategory = Process;
                Image = Email;
                ApplicationArea = All;
                ToolTip = 'Sends statements to all customers';

                trigger OnAction()
                var
                    CustomerCU: CodeUnit "TFB Customer Mgmt";
                    TextMsg: Label 'Are you sure you want to send to all customers?';
                begin
                    If Dialog.Confirm(TextMsg) then
                        CustomerCU.SendCustomerStatementBatch();

                end;
            }
            action(SendOrderUpdateByEmail)
            {
                Caption = 'Send Order Update';
                Promoted = True;
                PromotedCategory = Process;
                Image = Email;
                ApplicationArea = All;
                ToolTip = 'Send order update for the customer who is currently selected';

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
                ToolTip = 'Send quality certifications for the customer who is currently selected';

                trigger OnAction()

                var
                    QualityCU: Codeunit "TFB Quality Mgmt";

                begin
                    QualityCU.SendQualityDocumentsToCustomer(Rec."No.", false);
                end;
            }


        }

        addlast(processing)
        {
            action(UpdateContactID)
            {
                ApplicationArea = All;
                Image = UpdateDescription;
                Caption = 'Update Contact IDs';

                trigger OnAction()

                var
                    ContBusRel: Record "Contact Business Relation";
                    Customer: Record Customer;
                begin


                    Customer.SetLoadFields("No.", "TFB Primary Contact Company ID");
                    Customer.FindSet(true, false);
                    repeat begin
                        ContBusRel.SetCurrentKey("Link to Table", "No.");
                        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
                        ContBusRel.SetRange("No.", Customer."No.");
                        if ContBusRel.FindFirst then begin
                            Customer."TFB Primary Contact Company ID" := ContBusRel."Contact No.";
                            Customer.Modify();
                        end;

                    end until Customer.Next() = 0;

                end;
            }
        }



    }

    local procedure GetTaskSymbol(): Text

    var
        Contact: Record Contact;

    begin

        Contact.SetLoadFields("TFB No. Of Company Tasks", "No.");
        Contact.SetAutoCalcFields("TFB No. Of Company Tasks");

        If Contact.Get(Rec."TFB Primary Contact Company ID") then
            If Contact."TFB No. Of Company Tasks" > 0 then
                Exit('📋')
            else
                Exit('');


    end;
}