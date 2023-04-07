pageextension 50141 "TFB Reservation Entries" extends "Reservation Entries"
{
    layout
    {
        addafter("ReservEngineMgt.CreateForText(Rec)")
        {

            field("TFB Create For Extended"; _CreateForExtended)
            {
                ApplicationArea = All;
                Width = 30;
                Caption = 'Customer (Applicable)';
                ToolTip = 'Specifies customer if applicable for reservation entry';


            }
        }

        modify("ReservEngineMgt.CreateForText(Rec)")
        {

            trigger OnDrillDown()
            var

                SalesHeader: Record "Sales Header";
                SalesOrder: Page "Sales Order";

            begin

                if IsNullGuid(_SalesHeaderSystemId) then exit;

                SalesHeader.GetBySystemId(_SalesHeaderSystemId);

                SalesOrder.SetRecord(SalesHeader);
                SalesOrder.Editable(true);
                SalesOrder.Run();

            end;

        }

        modify("Shipment Date")
        {
            Visible = true;
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

        if ReservationCU.GetSaleLineForItemResEntry(Rec, SalesLine, SalesHeader) then begin
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