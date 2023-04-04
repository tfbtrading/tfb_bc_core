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
            action("&TransferOrder")
            {
                ApplicationArea = All;
                Caption = 'Transfer Order';
                ToolTip = 'Opens the related transfer order';
                RunObject = page "Transfer Order";
                RunPageLink = "No." = field("Transfer Order No.");
                Enabled = TransferOrderExists;

                Image = TransferOrder;

            }
        }

        addlast(Category_Category4)
        {
            actionref(TransferOrder_Promoted; "&TransferOrder")
            {

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