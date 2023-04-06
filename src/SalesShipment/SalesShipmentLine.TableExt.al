tableextension 50137 "TFB Sales Shipment Line" extends "Sales Shipment Line" //111
{

    fields
    {
        field(50122; "TFB Customer Name"; Text[100])
        {

            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup ("Sales Shipment Header"."Sell-to Customer Name" where("Sell-to Customer No." = field("Sell-to Customer No.")));
            Editable = false;

        }
        field(50200; "TFB CoA Sent"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'CoA Sent';
            Editable = false;
        }
        field(50210; "TFB 3PL Booking No"; Text[30])
        {
            Caption = '3PL Booking No';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'Handled by page lookup';

        }

        field(50220; "TFB 3PL Booking No Lookup"; Text[30])
        {
            Caption = '3PL Booking No';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("Sales Shipment Header"."TFB 3PL Booking No." where("No." = field("Document No.")));

        }

    }

    keys
    {


    }

}