table 50330 "TFB Costings Setup"
{
    Caption = 'Item Costings Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }

        field(2; "Port Cartage Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(3; "Unpack Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }

        field(4; "Cust. Decl. Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(5; "Ocean Freight Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = true;
        }
        field(6; "Port Documents"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = True;
        }
        //You might want to add fields here
        field(7; "Fumigation Fees Item Charge"; code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = True;
        }
        field(8; "Quarantine Fees Item Charge"; Code[20])
        {
            TableRelation = "Item Charge";
            ValidateTableRelation = True;
        }
        field(9; "Default Postal Zone"; code[20])
        {
            TableRelation = "TFB Postcode Zone";
            ValidateTableRelation = True;

        }
        field(10; ExWarehouseEnabled; Boolean)
        {
            Caption = 'Ex Warehouse Customer Price Group Enabled?';
            trigger OnValidate()

            begin
                If ExWarehouseEnabled then
                    if ExWarehousePricingGroup = '' then
                        FieldError(ExWarehousePricingGroup, 'Enabled Ex Warehouse Group must be selected');

            end;
        }
        field(11; ExWarehousePricingGroup; Code[20])
        {
            TableRelation = "Customer Price Group";
            ValidateTableRelation = True;

            trigger OnValidate()

            begin
                If ExWarehouseEnabled then
                    if ExWarehousePricingGroup = '' then
                        FieldError(ExWarehousePricingGroup, 'Enabled Ex Warehouse Group must be selected');

            end;
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