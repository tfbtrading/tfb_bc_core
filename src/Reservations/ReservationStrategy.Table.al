table 50110 "TFB Reservation Strategy"
{
    DataClassification = CustomerContent;
    Caption = 'Reservation Strategy';
    LookupPageId = "TFB Resveration Strategy List";

    fields
    {
        field(1; Code; Code[20])
        {

        }
        field(5; Name; Text[60])
        {

        }

        field(10; "Future Inventory"; Boolean)
        {

        }

        field(20; "Limit Res. Period Before"; Boolean)
        {

        }
        field(25; "Limit Before Days"; Integer)
        {

        }

        field(30; "Limit Res. Period After"; Boolean)
        {

        }

        field(35; "Limit After Days"; Integer)
        {

        }
        field(40; "Reservation Method"; Enum "TFB Reservation Method")
        {

        }
        field(50; "Reservation Quantity"; Enum "TFB Reservation Quantity")
        {

        }
        field(60; "Reservation Type"; Enum "TFB Reservation Type")
        {

        }
        field(100; "No. of Customers"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Customer where("TFB Reservation Strategy" = field(Code)));

        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Name; Name)
        {

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