table 50125 "TFB Core Setup"
{
    Caption = 'TFB Core Functionality Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }

        field(10; "Port Cartage Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(20; "Unpack Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }

        field(30; "Cust. Decl. Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(40; "Ocean Freight Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(50; "Port Documents"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        //You might want to add fields here
        field(60; "Fumigation Fees Item Charge"; code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(70; "Quarantine Fees Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(80; "Default Postal Zone"; code[20])
        {
            TableRelation = "TFB Postcode Zone";
            ValidateTableRelation = true;

        }
        field(90; ExWarehouseEnabled; Boolean)
        {
            Caption = 'Ex Warehouse Customer Price Group Enabled?';
            trigger OnValidate()

            begin
                if ExWarehouseEnabled then
                    if ExWarehousePricingGroup = '' then
                        FieldError(ExWarehousePricingGroup, 'Enabled Ex Warehouse Group must be selected');

            end;
        }
        field(100; ExWarehousePricingGroup; Code[20])
        {
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;

            trigger OnValidate()

            begin
                if ExWarehouseEnabled then
                    if ExWarehousePricingGroup = '' then
                        FieldError(ExWarehousePricingGroup, 'Enabled Ex Warehouse Group must be selected');

            end;
        }
        field(110; "Import Duty Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Import Duty Rate';
            AutoFormatType = 10;
            AutoFormatExpression = '<precision, 1:2><standard format,0>%';
        }



        field(150; "MSDS Word Template"; Code[30])
        {
            DataClassification = CustomerContent;
            TableRelation = "Word Template" where("Table ID" = const(27));
            ValidateTableRelation = true;
            Caption = 'MSDS Word Template';

        }
        field(160; "ABS Lot Sample Account"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Account Name for Lot Samples';
        }
        field(170; ABSLotSampleAccessKey; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Shared Access Key for Lot Samples';
        }
        field(180; "ABS Lot Sample Container"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Container Name for Lot Samples';
        }
        field(190; "Container Entry Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ValidateTableRelation = true;

        }
        field(200; "Email Template Active"; Text[256])
        {
            Caption = 'Email Template Active URL';
            ExtendedDatatype = url;

        }
        field(210; "Email Template Test"; Text[256])
        {
            Caption = 'Email Template Test URL';
            ExtendedDatatype = url;
        }
        field(220; "Test Table"; Integer)
        {
            Caption = 'Test Table';
            TableRelation = "Table Information";
            //You might want to add fields here

        }

        field(230; "Brokerage Contract Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Brokerage Contract Nos.';
            TableRelation = "No. Series";
            ValidateTableRelation = true;

        }
        field(240; "Brokerage Shipment Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Caption = 'Brokerage Shipment Nos.';
            ValidateTableRelation = true;

        }
        field(250; "Brokerage Default %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Brokerage Default %';

        }

        field(270; "Auto Shipment Notification"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Notify Customer on Shipment';
        }
        field(280; "ASN Def. Job Resp. Rec."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Job Responsibility";
            ValidateTableRelation = true;
            Caption = 'Shipment Notification Job Resp.';

        }
        field(290; "Price List Def. Job Resp."; Boolean)
        {
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by job responsibility code';

            TableRelation = "Job Responsibility";
            ValidateTableRelation = true;

        }


        field(300; "PL Def. Job Resp. Rec."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Job Responsibility";
            ValidateTableRelation = true;
            Caption = 'Price List Job Resp.';
        }

        field(310; "QDS Def. Job Resp."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Job Responsibility";
            ValidateTableRelation = true;
            Caption = 'Quality Docs Subs. Job Resp.';
        }
        field(320; "Def. Customer Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
            Caption = 'Def. Cust. Price Group';
        }
        field(330; "Item Price Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
            Caption = 'Item Unit Price Group';

        }
        field(340; "Brokerage Service Item"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item where(Type = const(Service));
            ValidateTableRelation = true;
            Caption = 'Brokerage Service Item';
        }
        field(350; "Credit Tolerance"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10000;
            Caption = 'Credit Tolerance';

        }

        field(360; "Lead Status"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Lead));
            ValidateTableRelation = true;
            Caption = 'Lead Status Default';
        }

        field(370; "Prospect Status - New"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Prospect));
            ValidateTableRelation = true;
            Caption = 'Prospect (New) Status Default';
        }
        field(380; "Prospect Status - Opp"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Prospect));
            ValidateTableRelation = true;
            Caption = 'Prospect (Opportunity) Status Default';
        }
        field(390; "Prospect Status - Quote"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Prospect));
            ValidateTableRelation = true;
            Caption = 'Prospect (Quote) Status Default';
        }
        field(400; "Converted Status"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Contact Status".Status where(Stage = const(Converted));
            ValidateTableRelation = true;
            Caption = 'Customer/Vendor Status Default';
        }

        field(410; "Sample Request Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Caption = 'Sample Request Nos.';
            ValidateTableRelation = true;

        }

        field(420; "Posted Sample Request Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Caption = 'Pstd. Sample Request Nos.';
            ValidateTableRelation = true;

        }

        field(430; "Specification URL Pattern"; Text[240])
        {
            DataClassification = CustomerContent;
            Caption = 'Specification URL Pattern';
        }
        field(440; "Image URL Pattern"; Text[240])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Image URL Pattern';
        }

        field(450; "ABS POD Account"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Account Name';
        }
        field(460; "ABS POD Access Key"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Shared Access Key';
        }
        field(470; "ABS POD Container"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Container Name';
        }

    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure InsertIfNotExists()
    var
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;


}