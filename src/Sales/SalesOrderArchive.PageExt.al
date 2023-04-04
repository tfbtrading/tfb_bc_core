pageextension 50140 "TFB Sales Order Archive" extends "Sales Order Archive"
{
    layout
    {
        addafter("Payment Terms Code")
        {
            field("Price Group Code"; Rec."Price Group Code")
            {
                ApplicationArea = All;
                Visible = true;
                Importance = Promoted;
                ToolTip = 'Specifies customer price group';
            }
        }

        addfirst(factboxes)
        {
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Links; Links)
            {

                ApplicationArea = All;
            }

        }

        addlast(Shipping)
        {
            field("TFB Instructions"; Rec."TFB Instructions")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies instructions that were specific to this order';

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}