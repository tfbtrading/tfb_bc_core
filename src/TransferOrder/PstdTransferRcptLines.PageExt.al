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