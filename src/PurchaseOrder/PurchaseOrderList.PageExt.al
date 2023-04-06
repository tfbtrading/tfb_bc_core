pageextension 50218 "TFB Purchase Order List" extends "Purchase Order List"
{
    layout
    {
        modify("Vendor Order No.")
        {
            Visible = true;
        }
        addbefore("Document Date")
        {
            field("Order Date"; Rec."Order Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date on which the order was placed';

            }
        }
        addafter("Requested Receipt Date")
        {


            field("Promised Receipt Date"; Rec."Promised Receipt Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the promised receipt date for the order';
                Visible = true;
            }
            field("TFB Container Entry Exists"; Rec."TFB Container Entry Exists")
            {
                ApplicationArea = All;

                Caption = 'Container Exists';
                ToolTip = 'Specifies if container exists for the purchase order';
                DrillDown = true;
                DrillDownPageId = "TFB Container Entry List";
                Visible = true;
            }
            field("TFB Est. Sailing Date"; Rec."TFB Est. Sailing Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date if container is being shipped';
                Visible = true;
            }

        }
        addafter(Status)
        {
            Field("No. Printed"; Rec."No. Printed")
            {
                ApplicationArea = All;
                Caption = 'No. Printed or Emailed';
                ToolTip = 'Specifies the number of times document has been printed or emailed';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}