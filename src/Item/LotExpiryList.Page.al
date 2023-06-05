page 50176 "TFB Lot Expiry List"
{
    ApplicationArea = All;
    Caption = 'Lot Expiry List';
    PageType = List;
    SourceTable = "TFB Lot Expiry Buffer";
    SourceTableView = sorting("Expiry Date", "Item No.", "Lot No.", "Variant Code") order(ascending);
    SourceTableTemporary = true;
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field(Description; Description)
                {
                    ToolTip = 'Specifies the description of the Item';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ToolTip = 'Specifies the value of the Lot No. field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowLotInfoIntelligently(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
                    end;
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ToolTip = 'Specifies the value of the Expiry Date field.';
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ToolTip = 'Specifies the value of the Qty. (Base) field.';
                }
            }
        }
    }

    local procedure ShowLotInfoIntelligently(ItemNo: Code[20]; VariantCode: Code[20]; LotNo: Code[50])

    var
        LotInfo: record "Lot No. Information";

    begin

        if LotInfo.Get(ItemNo, VariantCode, LotNo) then
            Page.Run(Page::"Lot No. Information Card", LotInfo);
    end;

    internal procedure InitExpiredData()
    begin
        TFBActivitiesMgt.PopulateExpiredData(Rec);
    end;

    internal procedure InitExpiringData()
    begin
        TFBActivitiesMgt.PopulateExpiringData(Rec);
    end;

    var
        TFBActivitiesMgt: CodeUnit "TFB Activities Mgt.";
}
