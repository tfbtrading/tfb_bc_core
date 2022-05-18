pageextension 50158 "TFB Pstd. Transfer Rcpt. Lines" extends "Posted Transfer Receipt Lines"
{
    layout
    {
        moveafter("Document No."; "Receipt Date")

        addafter("Unit of Measure")
        {
            field(TFBLocation; _locationDetails)
            {
                ApplicationArea = all;
                Caption = 'Location Details';
                ToolTip = 'Specifies the location details of the transfer';

            }
            field("TFB Container Entry No."; Rec."TFB Container Entry No.")
            {
                ApplicationArea = All;
                Caption = 'Container Entry';
                TableRelation = "TFB Container Entry";
                ToolTip = 'Specifies the container entry';
            }
            field("TFB Container No."; Rec."TFB Container No.")
            {
                ApplicationArea = All;
                Caption = 'Container No.';
                ToolTip = 'Specifies the container number';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


    trigger OnAfterGetRecord()

    var
        Header: Record "Transfer Receipt Header";

    begin

        _locationDetails := '';
        Header.get(Rec."Document No.");
        _locationDetails := StrSubstNo('From %1 to %2', Header."Transfer-from Code", Header."Transfer-to Code");

    end;

    var
        _locationDetails: Text;

}