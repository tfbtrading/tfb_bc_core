pageextension 50139 "TFB Pstd. Sales Ship. - Update" extends "Posted Sales Shipment - Update"
{
    layout
    {
        addbefore("Package Tracking No.")
        {
            //TODO Reimplement when using background codeunit
            /*  field("TFB 3PL Booking No."; Rec."TFB 3PL Booking No.")
             {
                 ApplicationArea = All;
                 Editable = true;
                 Visible = true;
                 ToolTip = 'please update this field value';

                 trigger OnValidate()

                 begin


                 end;
             } */
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}