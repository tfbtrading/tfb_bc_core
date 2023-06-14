pageextension 50195 "TFB Purch. Cr. Memo Subform" extends "Purch. Cr. Memo Subform" //MyTargetPageId
{
    layout
    {
        modify("Unit Price (LCY)")
        {
            Visible = false;
        }
        modify("Job No.")
        {
            Visible = false;
        }
        modify("Deferral Code")
        {
            Visible = false;
        }

        addafter("Direct Unit Cost")
        {
            field("TFB Price By Price Unit"; Rec."TFB Price By Price Unit")
            {
                ApplicationArea = All;
                Caption = 'Price By Price Unit';
                Tooltip = 'Specifies price in the vendors default weight unit';
                Editable = InventoryItem;
                Visible = not InventoryItem;
                BlankNumbers = BlankZero;
            }
            field(VendorPriceUnit; VendorPriceUnitEnum)
            {
                ApplicationArea = All;
                Visible = not InventoryItem;
                Enabled = not InventoryItem;
                Caption = 'Vendor Price Unit';
                Tooltip = 'Specifies the default price unit used by the vendor';
                Editable = false;
            }


        }
        addafter(Description)
        {
            field(AIIndicator; AIIndicatorVar)
            {
                Caption = 'AI';
                Visible = true;
                Width = 1;
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies whether AI has been applied to the purchase invoice';
            }
        }

       

        modify(Description)
        {
            trigger OnAfterValidate()

            begin

                CheckAndRetrieveAssignmentLines();
            end;
        }

        modify(Quantity)
        {
            trigger OnAfterValidate()

            begin
                CheckAndRetrieveAssignmentLines();
            end;
        }



    }

    actions
    {

    }



    var

        VendorPriceUnitEnum: Enum "TFB Price Unit";
        InventoryItem: Boolean;
        AIIndicatorVar: Text;


    trigger OnAfterGetRecord()

    begin
        UpdatePriceUnitCalcs();
        if Rec."Qty. to Assign" = 0 then
            AIIndicatorVar := '';
    end;

    local procedure UpdatePriceUnitCalcs(): Decimal

    var
        Vendor: Record Vendor;
        Item: Record Item;


    begin



        InventoryItem := false;
        VendorPriceUnitEnum := VendorPriceUnitEnum::"N/A";

        if rec.Type = rec.Type::Item then
            if Item.Get(rec."No.") then
                if item.type = item.type::Inventory then begin
                    InventoryItem := true;
                    Vendor.Get(rec."Buy-from Vendor No.");
                    VendorPriceUnitEnum := Vendor."TFB Vendor Price Unit";
                end;
    end;



    local procedure CheckAndRetrieveAssignmentLines(): Boolean

    var
        PurchInvCU: Codeunit "TFB Purch. Inv. Mgmt";

    begin
        CurrPage.SaveRecord();
        if PurchInvCU.CheckAndRetrieveAssignmentLines(Rec, false) then
            AIIndicatorVar := '⚡'
        else
            AIIndicatorVar := '';

    end;


}