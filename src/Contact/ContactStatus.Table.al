table 50109 "TFB Contact Status"
{
    DataClassification = CustomerContent;
    TableType = Normal;
    LookupPageId = "TFB Contact Status List";

    fields
    {
        field(1; Stage; Enum "TFB Contact Stage")
        {
            Caption = 'Stage';
        }

        field(10; Status; Code[20])
        {
            Caption = 'Customer Status';
        }
        field(20; Probability; Decimal)
        {
            Caption = 'Probability';
            AutoFormatType = 10;
            AutoFormatExpression = '<precision, 1:1><standard format,0>%';
            DecimalPlaces = 0 : 1;
        }
        field(30; "Description"; Text[256])
        {
            Caption = 'Description';
        }
        field(40; "IncludeInLeads"; Boolean)
        {
            Caption = 'Include in Lead Reports';
        }
        field(50; "SortOrder"; Integer)
        {
            Caption = 'Order';
        }
        field(60; "Inactive"; Boolean)
        {
            Caption = 'Inactive';
        }
        field(100; NoOfActiveContacts; Integer)
        {
            Caption = 'No. Of Active Contacts';
            FieldClass = FlowField;
            CalcFormula = count(Contact where("TFB Contact Status" = field(Status)));
        }

    }

    keys
    {
        key(PK; Stage, Status)
        {
            Clustered = true;
        }
        key(SortOrder; SortOrder)
        {
            Unique = true;
        }
        key(Status; Status)
        {
            Unique = true;
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