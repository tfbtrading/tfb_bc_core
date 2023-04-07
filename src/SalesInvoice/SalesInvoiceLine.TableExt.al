tableextension 50139 "TFB Sales Invoice Line" extends "Sales Invoice Line" //113
{
    fields
    {
        field(50122; "TFB Customer Name"; Text[100])
        {

            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Sales Invoice Header"."Sell-to Customer Name" where("Sell-to Customer No." = field("Sell-to Customer No.")));
            Editable = false;

        }

        field(50126; "TFB Pre-Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order';
            Editable = false;

        }
        field(50127; "TFB Pre-Order Currency"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Currency';
            Editable = false;

        }
        field(50128; "TFB Pre-Order Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Exch. Rate';
            Editable = false;
        }
        field(50129; "TFB Pre-Order Eff. Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Eff. Date';
            Editable = false;
        }

        field(50130; "TFB Drop Ship PO No."; Code[20])
        {
            Caption = 'Drop Ship PO No.';
            Editable = false;

        }

        field(50140; "TFB Pre-Order Adj. Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Adj. Exch. Rate';
            Editable = false;
        }
        field(50142; "TFB Pre-Order Unit Price Adj."; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Unit Price Adj.';
            Editable = false;
        }
        field(50146; "TFB Pre-Order Adj. Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order Adj. Date';
            Editable = false;
        }



    }

    fieldgroups
    {
        addlast(Brick; Quantity, "TFB Customer Name")
        {

        }

    }

}