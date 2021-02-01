page 50112 "TFB Sales POD FactBox"
{

    PageType = CardPart;
    SourceTable = "Sales Invoice Header";
    Caption = 'Sales Invoice POD Info';

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                field(PODInfo; _PODInfo)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    Caption = 'POD Info';
                    Editable = false;
                    ToolTip = 'Specifies POD information for sales invoice';
                    MultiLine = true;
                }


            }
        }
    }


    trigger OnAfterGetRecord()

    var

    begin

        GetPODInfo();

    end;

    local procedure GetPODInfo()

    var
        Shipment: Record "Sales Shipment Header";
        ShipmentCU: CodeUnit "TFB Sales Shipment Mgmt";


    begin
        If ShipmentCU.GetRelatedShipmentInvoice(rec, Shipment) then
            _PODInfo := ShipmentCU.GetShipmentStatusQueryText(Shipment)
        else
            _PODInfo := '';
    end;

    var
        _PODInfo: Text;
}
