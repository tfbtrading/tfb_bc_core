table 50170 "TFB Landed Cost Lines"
{
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteReason = 'Duplicate of Item Costing';

    fields
    {
        field(1; "Template Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Landed Cost Template".Code;

        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            NotBlank = true;
        }
        field(3; "Item Charge No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Charge"."No.";
            NotBlank = true;

        }
        field(4; "Landed Cost Description"; Text[60])
        {
            DataClassification = CustomerContent;
            NotBlank = true;


        }
        field(5; "Allocation Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Weight","Value","Equally";
            NotBlank = true;

        }
        field(6; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = true;
            trigger OnValidate()
            var
                VendorRec: Record Vendor;
            begin
                VendorRec.Get("Vendor No.");
                "Vendor Name" := VendorRec.Name;
            end;

        }
        field(7; "Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;

        }

        field(8; "Estimated Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 10000;
            DecimalPlaces = 2;

            trigger OnValidate()

            var
                LandedCostTemplate: Record "TFB Landed Cost Template";
                EstimatedCostLCY: Decimal;

            begin
                LandedCostTemplate.Get("Template Code");
                if "Overseas Charge" = true then begin

                    EstimatedCostLCY := "Estimated Cost" / LandedCostTemplate."Estimated Exch. Rate";
                    "Estimated Cost LCY" := EstimatedCostLCY;

                end else begin

                    EstimatedCostLCY := "Estimated Cost";
                    "Estimated Cost LCY" := EstimatedCostLCY;
                end;
                If LandedCostTemplate."Estimated Weight" > 0 then
                    "Allocated Cost LCY" := EstimatedCostLCY / LandedCostTemplate."Estimated Weight"
                else
                    "Allocated Cost LCY" := 0;
            end;

        }
        field(9; "Overseas Charge"; Boolean)
        {
            DataClassification = CustomerContent;

        }
        field(10; "Estimated Cost LCY"; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 10000;
            DecimalPlaces = 2;
            Editable = false;

        }
        field(11; "Allocated Cost LCY"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Template Code", "Line No.")
        {
            Clustered = true;
        }
    }






    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
