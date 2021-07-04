tableextension 50220 "TFB Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(51010; "TFB Brokerage Contract Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Brokerage Contract Nos.';
            TableRelation = "No. Series";
            ValidateTableRelation = true;

        }
        field(51011; "TFB Brokerage Shipment Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Caption = 'Brokerage Shipment Nos.';
            ValidateTableRelation = true;

        }
        field(51012; "Brokerage Default %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Brokerage Default %';

        }
        field(51075; "TFB Brokerage Shipment"; Enum "Report Selection Usage")
        {
            DataClassification = CustomerContent;
            Caption = 'Brokerage Shipment';
            ObsoleteState = Pending;
            ObsoleteReason = 'Incorrect field';
        }
        field(51020; "TFB Auto Shipment Notification"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Notify Customer on Shipment';
        }
        field(51025; "TFB ASN Def. Job Resp. Rec."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Job Responsibility";
            ValidateTableRelation = true;
            Caption = 'Shipment Notification Job Resp.';

        }
        field(51030; "TFB Price List Def. Job Resp."; Boolean)
        {
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by job responsibility code';

            TableRelation = "Job Responsibility";
            ValidateTableRelation = true;

        }

        field(51040; "TFB PL Def. Job Resp. Rec."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Job Responsibility";
            ValidateTableRelation = true;
            Caption = 'Price List Job Resp.';
        }
        field(51050; "TFB Def. Customer Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
            Caption = 'Def. Cust. Price Group';
        }
        field(51055; "TFB Item Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
            Caption = 'Item Unit Price Group';

        }
        field(51060; "TFB Brokerage Service Item"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item where(Type = const(Service));
            ValidateTableRelation = true;
            Caption = 'Brokerage Service Item';
        }
        field(51070; "TFB Credit Tolerance"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10000;
            Caption = 'Credit Tolerance';

        }

        field(51080; "TFB Lead Status"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Lead));
            ValidateTableRelation = true;
            Caption = 'Lead Status Default';
        }

        field(51090; "TFB Prospect Status - New"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Prospect));
            ValidateTableRelation = true;
            Caption = 'Prospect (New) Status Default';
        }
        field(51100; "TFB Prospect Status - Opp"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Prospect));
            ValidateTableRelation = true;
            Caption = 'Prospect (Opportunity) Status Default';
        }
        field(51110; "TFB Prospect Status - Quote"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Prospect));
            ValidateTableRelation = true;
            Caption = 'Prospect (Quote) Status Default';
        }
        field(51120; "TFB Converted Status"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Converted));
            ValidateTableRelation = true;
            Caption = 'Customer/Vendor Status Default';
        }

        field(51130; "TFB Sample Request Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Caption = 'Sample Request Nos.';
            ValidateTableRelation = true;

        }

        field(51140; "TFB Posted Sample Request Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Caption = 'Pstd. Sample Request Nos.';
            ValidateTableRelation = true;

        }

        field(51150; "TFB Specification URL Pattern"; Text[240])
        {
            DataClassification = CustomerContent;
            Caption = 'Specification URL Pattern';

        }

    }


}