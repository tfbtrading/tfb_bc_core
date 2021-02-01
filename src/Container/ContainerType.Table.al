table 50131 "TFB ContainerType"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Container Types";
    DataCaptionFields = Code, Description;

    fields
    {
        field(50132; "Code"; Text[10]) { DataClassification = CustomerContent; }
        field(50133; "Description"; Text[100]) { DataClassification = CustomerContent; }
        field(50134; "Length"; Decimal) { DataClassification = CustomerContent; }
        field(50135; "Width"; Decimal) { DataClassification = CustomerContent; }
        field(50136; "Height"; Decimal) { DataClassification = CustomerContent; }

        field(50137; "Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Dry Storage","Insulated","Refridgerated";
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
            Enabled = true;
        }

    }

    var


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