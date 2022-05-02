table 50300 "TFB Costing Scenario"
{
    DataClassification = CustomerContent;
    DataPerCompany = true;
    Caption = 'Costing Scenario';
    LookupPageId = "TFB Costing Scenario List";
    DrillDownPageId = "TFB Brokerage Contract List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Planning Scenario Code';
            DataClassification = CustomerContent;
        }
        field(2; "Effective Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Exchange Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Exch. Rate';
        }
        field(4; "Finance Rate"; Decimal)
        {
            DataClassification = CustomerContent;

        }
        field(5; "Storage"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(19; "Finance Duration"; Duration)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Bank Charge"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Port Cartage"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(20; "Order Handling"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; "Fuel Surcharge %"; Decimal)
        {
            DataClassification = CustomerContent;
            FieldClass = Normal;

            trigger OnValidate()

            var
                recPostCodeZoneRate: record "TFB Postcode Zone Rate";

            begin
                recPostCodeZoneRate.setrange("Costing Scenario Code", Code);
                if recPostCodeZoneRate.FindSet(true, false) then
                    repeat
                        if "Fuel Surcharge %" > 0 then begin
                            recPostCodeZoneRate.OnUpdateBaseRate(recPostCodeZoneRate."Base Rate", "Fuel Surcharge %");
                            recPostCodeZoneRate.Modify()
                        end;
                    until recPostCodeZoneRate.Next() = 0;



            end;
        }
        field(8; "Shrink Wrapping"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Labelling"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Unpack Loose"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Unpack Standard"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(12; "Customs Declaration"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Fumigation"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(40; "Heat Treatment"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Pallet In Charge"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Pallet Out Charge"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(16; "Def. Storage Duration"; Duration)
        {
            DataClassification = CustomerContent;
        }
        field(17; "Container Contingency"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(18; "Pallet Putaway Charge"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(32; "Pallet Package Bundle"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(22; "Pricing Margin %"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(23; "Market Price Margin %"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(24; "Full Load Margin %"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(30; "Inspection Charge"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
        }

    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, "Effective Date", "Exchange Rate") { }
    }



}