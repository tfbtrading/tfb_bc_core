pageextension 50175 "TFB Sales Line Factbox" extends "Sales Line FactBox"
{
    layout
    {
        // Add changes to page layout here
        addlast(Item)
        {
            field(TFBItemCostingSystemID; GetStandardItemCostingDescription(ItemCostingSystemID))
            {
                Caption = 'Costing calculation';
                ToolTip = 'Specifies if an item costings exists and links  to it';
                ApplicationArea = All;
                DrillDown = true;

                trigger OnDrillDown()

                var
                    ItemCosting: record "TFB Item Costing";
                    ItemCostingPage: page "TFB Item Costing";
                begin

                    if ItemCosting.GetBySystemId(ItemCostingSystemID) then begin
                        ItemCostingPage.SetRecord(ItemCosting);
                        ItemCostingPage.Run();
                    end
                    else begin
                        ItemCosting.Init();
                        ItemCosting.Validate("Item No.", Rec."No.");
                        ItemCosting.Validate("Costing Type", ItemCosting."Costing Type"::Standard);
                        ItemCosting.Validate("Effective Date", WorkDate());
                        ItemCostingPage.SetRecord(ItemCosting);
                        ItemCostingPage.Run();
                    end;
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        ItemCostingSystemID: Guid;


    trigger OnAfterGetRecord()

    var
        ItemCosting: Record "TFB Item Costing";

    begin
        clear(ItemCostingSystemID);


        ItemCosting.SetRange("Item No.", Rec."No.");
        ItemCosting.SetRange("Costing Type", ItemCosting."Costing Type"::Standard);
        If ItemCosting.Findlast() then
            ItemCostingSystemID := ItemCosting.SystemId;

    end;

    local procedure GetStandardItemCostingDescription(Ref: Guid): Text[50]

    begin

        if not IsNullGuid(ItemCostingSystemID) then
            Exit('Exists')
        else
            Exit('Create Item Costing...');

    end;
}