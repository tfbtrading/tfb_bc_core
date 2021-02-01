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
            action(SendOrderUpdateByEmail)
            {
                Caption = 'Send order update';
                Tooltip = 'Sends an order update to the selected vendor';
                Promoted = True;
                PromotedCategory = Process;
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

                trigger OnAction()

                var
                    ContBusRel: Record "Contact Business Relation";
                    Vendor: Record Vendor;
                begin


                    Vendor.SetLoadFields("No.", "TFB Primary Contact Company ID");
                    Vendor.FindSet(true, false);
                    repeat begin
                        ContBusRel.SetCurrentKey("Link to Table", "No.");
                        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Vendor);
                        ContBusRel.SetRange("No.", Vendor."No.");
                        if ContBusRel.FindFirst then begin
                            Vendor."TFB Primary Contact Company ID" := ContBusRel."Contact No.";
                            Vendor.Modify();
                        end;

                    end until Vendor.Next() = 0;

                end;
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

        Contact.SetLoadFields("TFB No. Of Tasks", "No.");
        Contact.SetAutoCalcFields("TFB No. Of Tasks");

        If Contact.Get(Rec."TFB Primary Contact Company ID") then
            If Contact."TFB No. Of Tasks" > 0 then
                Exit('📋')
            else
                Exit('');


    end;
}