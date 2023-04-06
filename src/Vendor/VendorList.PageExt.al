pageextension 50127 "TFB Vendor List" extends "Vendor List" //27
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

        addafter(Name)
        {
            field("TFB Vendor Type"; Rec."TFB Vendor Type")
            {
                Editable = true;
                ApplicationArea = All;
                Tooltip = 'Specifies the type of vendor';
            }
        }

    }

    actions
    {
        addafter(PayVendor)
        {
            action(TFBSendOrderUpdateByEmail)
            {
                Caption = 'Send order update';
                Tooltip = 'Sends an order update to the selected vendor';

                Image = Email;
                ApplicationArea = All;

                trigger OnAction()

                var
                    VendorCU: Codeunit "TFB Vendor Mgmt";

                begin
                    VendorCU.SendOneVendorStatusEmail(Rec."No.");
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
                ToolTip = 'Updates all of the contact IDs against related Vendors';

                trigger OnAction()

                var
                    ContBusRel: Record "Contact Business Relation";
                    Vendor: Record Vendor;
                begin


                    Vendor.SetLoadFields("No.", "TFB Primary Contact Company ID");
                    Vendor.Findset(true);
                    repeat
                        ContBusRel.SetCurrentKey("Link to Table", "No.");
                        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Vendor);
                        ContBusRel.SetRange("No.", Vendor."No.");
                        if ContBusRel.FindFirst() then begin
                            Vendor."TFB Primary Contact Company ID" := ContBusRel."Contact No.";
                            Vendor.Modify();
                        end;

                    until Vendor.Next() = 0;

                end;
            }
        }

        addlast(Category_Process)
        {
            actionref(TFBSendOrderUpdateByEmail_Promoted; TFBSendOrderUpdateByEmail)
            {

            }
        }
    }

    views
    {


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