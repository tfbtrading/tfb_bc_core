tableextension 50132 "TFB Item Ledger Entry" extends "Item Ledger Entry"
{


    fields
    {
        field(50100; "TFB No. Of Lot Images"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("TFB Lot Image" where("Item Ledger Entry ID" = field(systemid)));

            Caption = 'No. of Lot Images';

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