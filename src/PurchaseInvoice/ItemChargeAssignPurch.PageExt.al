pageextension 50106 "TFB Item Charge Assign.(Purch)" extends "Item Charge Assignment (Purch)" //5805
{
    layout
    {
        modify("Applies-to Doc. No.")

        {
            trigger OnDrillDown()

            begin

                NavToAppliesToDoc();
            end;

        }

    }

    actions
    {
        addlast(Navigation)
        {
            action("TFBSource Document")
            {
                Image = GetSourceDoc;
                Caption = 'Get source document';
                Enabled = LineExists;
                ApplicationArea = All;
                ToolTip = 'Open source document';
                trigger OnAction()


                begin
                    NavToAppliesToDoc();
                end;
            }
        }
    }

    var

        LineExists: Boolean;

    trigger OnAfterGetRecord()

    begin
        If Rec."Applies-to Doc. No." <> '' then
            LineExists := true
        else
            LineExists := false;
    end;

    local procedure NavToAppliesToDoc();

    var
        Shipment: Record "Sales Shipment Header";
        Receipt: Record "Purch. Rcpt. Header";
        ShipmentPage: Page "Posted Sales Shipment";
        ReceiptPage: Page "Posted Purchase Receipt";

    begin

        case Rec."Applies-to Doc. Type" of
            Rec."Applies-to Doc. Type"::"Sales Shipment":
                begin
                    Shipment.Get(Rec."Applies-to Doc. No.");
                    ShipmentPage.SetRecord(Shipment);
                    ShipmentPage.Run();

                end;

            Rec."Applies-to Doc. Type"::Receipt:
                begin
                    Receipt.Get(Rec."Applies-to Doc. No.");
                    ReceiptPage.SetRecord(Receipt);
                    ReceiptPage.Run();

                end;

        end;
    end;
}