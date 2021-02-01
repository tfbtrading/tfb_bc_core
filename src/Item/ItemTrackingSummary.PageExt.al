pageextension 50143 "TFB Item Tracking Summary" extends "Item Tracking Summary"
{
    layout
    {
        addafter("Total Available Quantity")
        {
            field("TFB Lot Blocked"; _LotBlocked)
            {
                Caption = 'Lot Blocked';
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Specifies if the lot is blocked from being sold';

                trigger OnDrillDown()

                var
                    LotInfo: Record "Lot No. Information";
                    Entry: Record "Item Ledger Entry";
                    LotInfoPage: Page "Lot No. Information Card";

                begin

                    Entry.SetRange("Entry No.", Rec."Entry No.");
                    Entry.SetRange(Positive, true);
                    If Entry.FindFirst() then begin
                        LotInfo.SetRange("Item No.", Entry."Item No.");
                        LotInfo.SetRange("Variant Code", Entry."Variant Code");
                        LotInfo.SetRange("Lot No.", Entry."Lot No.");

                        If LotInfo.FindFirst() then begin
                            LotInfoPage.SetRecord(LotInfo);
                            LotInfoPage.Editable := false;
                            LotInfoPage.Run();

                        end;
                    end;
                end;
            }

        }
    }



    trigger OnAfterGetRecord()

    var
        LotInfo: Record "Lot No. Information";
        Entry: Record "Reservation Entry";

    begin

        Entry.SetRange("Entry No.", Rec."Entry No.");
        Entry.SetRange(Positive, true);
        If Entry.FindFirst() then begin
            LotInfo.SetRange("Item No.", Entry."Item No.");
            LotInfo.SetRange("Variant Code", Entry."Variant Code");
            LotInfo.SetRange("Lot No.", Entry."Lot No.");

            If LotInfo.FindFirst() then
                _LotBlocked := LotInfo.Blocked;
        end;

    end;

    var
        _LotBlocked: Boolean;
}