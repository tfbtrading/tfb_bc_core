pageextension 50197 "TFB Transfer Shipment" extends "Posted Transfer Shipment"
{
    layout
    {
        modify("Transfer Order No.")
        {
            Style = Strong;
            StyleExpr = Rec."Transfer Order No." <> '';
        }
    }

    actions
    {
        addfirst("&Shipment")
        {
            action(ActionName)
            {
                ApplicationArea = All;
                Caption = 'Transfer Order';
                RunObject = page "Transfer Order";
                RunPageLink = "No." = field("Transfer Order No.");
                Enabled = TransferOrderExists;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

            }
        }
    }

    var
        TransferOrderExists: Boolean;

    trigger OnAfterGetRecord()

    var
        TransferOrder: Record "Transfer Header";

    begin

        TransferOrder.SetRange("No.", Rec."Transfer Order No.");

        TransferOrderExists := not TransferOrder.IsEmpty();

    end;
}