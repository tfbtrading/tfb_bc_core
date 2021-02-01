tableextension 50108 "TFB Sales Line Archive" extends "Sales Line Archive"
{
    fields
    {

        field(50121; "TFB Price Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Per Kg Price';
            DecimalPlaces = 2 :;

        }


        field(50123; "TFB Line Total Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Weight';
            DecimalPlaces = 2;
            Editable = false;
            BlankZero = true;


        }




        field(50126; "TFB Pre-Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Pre-Order';
            Editable = true;


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


}