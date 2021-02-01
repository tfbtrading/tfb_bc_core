pageextension 50167 "TFB Avail. Item Tracking Lines" extends "Avail. - Item Tracking Lines"
{
    layout
    {
        addafter("Source ID")
        {
            field("TFB Source Desc"; _CreateForExtended)
            {
                ApplicationArea = All;
                Caption = 'Created for';
                ToolTip = 'Description for the Source ID';
            }
        }

        
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()

    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";

    begin

        Clear(_CreateForExtended);
        Clear(_SalesLineSystemId);
        Clear(_SalesHeaderSystemId);

        If ReservationCU.GetSaleLineForItemResEntry(Rec, SalesLine, SalesHeader) then begin
            _CreateForExtended := SalesHeader."Sell-to Customer Name";
            _SalesLineSystemId := SalesLine.SystemId;
            _SalesHeaderSystemId := SalesHeader.SystemId;

        end;




    end;

    var
        ReservationCU: Codeunit "TFB Reservations Mgmt";

        _CreateForExtended: Text;
        _SalesLineSystemId: Guid;
        _SalesHeaderSystemId: Guid;
}