tableextension 50100 "TFB Location" extends Location
{
    fields
    {

        field(50100; "TFB Fumigation Time Delay"; Duration)
        {
            Caption = 'Fumigation Handling Time';
            DataClassification = CustomerContent;
        }
        field(50110; "TFB Inspection Time Delay"; Duration)
        {
            Caption = 'Inspection Time Delay';
            DataClassification = CustomerContent;
        }
        field(50120; "TFB X-Ray Time Delay"; Duration)
        {
            Caption = 'X-Ray Time Delay';
            DataClassification = CustomerContent;
        }

        field(50130; "TFB Heat Treat. Time Delay"; Duration)
        {
            Caption = 'Heat Treat. Time Delay';
            DataClassification = CustomerContent;
        }

        field(50140; "TFB Quarantine Location"; Boolean)
        {
            Caption = 'Quarantine Location';
            DataClassification = CustomerContent;
        }
        field(50150; "TFB AA No."; Text[35])
        {
            Caption = 'Approved Arrangement No.';
            DataClassification = CustomerContent;
        }

        field(50160; "TFB Location Type"; Enum "TFB Location Type")
        {
            Caption = 'Location Type';
            DataClassification = CustomerContent;
        }

        field(50170; "TFB Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            InitValue = true;
        }

        field(50180; "TFB Lcl Shipping Agent Code"; Code[10])
        {
            Caption = 'Local Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
            ValidateTableRelation = true;
        }

        field(50190; "TFB Lcl Agent Service Code"; Code[10])
        {

            Caption = 'Local Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("TFB Lcl Shipping Agent Code"));
            ValidateTableRelation = true;
        }

        field(50200; "TFB Insta Shipping Agent Code"; Code[10])
        {
            Caption = 'Default Interstate Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
            ValidateTableRelation = true;
        }

        field(50210; "TFB Insta Agent Service Code"; Code[10])
        {

            Caption = 'Default Interstate Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("TFB Insta Shipping Agent Code"));
            ValidateTableRelation = true;
        }
        field(50220; "TFB Location Check First"; Boolean)
        {
            Caption = 'Location Check First';

            trigger OnValidate()
            var
                Location: Record Location;

            begin

                if not xRec."TFB Location Check First" and Rec."TFB Location Check First" then begin
                    Location.SetRange(County, Rec.County);
                    Location.SetRange("TFB Location Check First", true);

                    if not Location.IsEmpty() then
                        FieldError("TFB Location Check First", 'Another location already has this priority for the same state');

                end

            end;
        }
        field(50222; "TFB Use for ILA"; Boolean)
        {
            Caption = 'Use for Intelligent Location Assignment';
            InitValue = true;
        }

        field(50230; "TFB Outbound Order Deadline"; Time)
        {
            Caption = 'Outbound Order Deadline';
            trigger OnValidate()

            var
                Text001Msg: Label 'Time must be between 10am and 8pm';

            begin
                if ("TFB Outbound Order Deadline" < 100000T) or ("TFB Outbound Order Deadline" > 200000T) then
                    FieldError("TFB Outbound Order Deadline", Text001Msg);

            end;
        }

        field(50102; "PalletExchange"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Pallet Exchange';
        }
        field(50105; "TFB Pallet Acct Type"; Enum "TFB Pallet Acct Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Account Type';
        }
        field(50103; PalletAccountNo; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Pallet Account No';

        }
    }

}