tableextension 50129 "TFB Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        field(50100; "TFB MSDS Word Template"; Code[30])
        {
            DataClassification = CustomerContent;
            TableRelation = "Word Template" where("Table ID" = const(27));
            ValidateTableRelation = true;
            Caption = 'MSDS Word Template';

        }
    }

}