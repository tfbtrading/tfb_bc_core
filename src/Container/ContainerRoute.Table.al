table 50152 "TFB Container Route"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Container Routes";

    fields
    {
        field(59158; "Code"; Text[10]) { DataClassification = CustomerContent; }
        field(50153; "Ship Via"; Text[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
            Caption = 'Ship From';
        }
        field(50160; "Ship To"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(50154; "Route Description"; Text[100]) { DataClassification = CustomerContent; }
        field(50155; "Days to Port"; Duration) { DataClassification = CustomerContent; Caption = 'Avg. Days in Transit'; Description = 'Enter number of days in transit from bill of lading until arrival'; }
        field(50156; "Days to Clear"; Duration) { DataClassification = CustomerContent; Caption = 'Avg. Days to Pickup'; Description = 'Enter number of days between arrival and container being available for pickup'; }
        field(50159; "Days to Warehouse"; Duration) { DataClassification = CustomerContent; ObsoleteState = Pending; ObsoleteReason = 'Shifted to Scenario'; }
        field(50157; "Transhipment"; Boolean) { DataClassification = CustomerContent; }
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
        fieldgroup(DropDown; Code, "Route Description", "Ship Via")
        {

        }
        fieldgroup(Brick; Code, "Route Description")
        {

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