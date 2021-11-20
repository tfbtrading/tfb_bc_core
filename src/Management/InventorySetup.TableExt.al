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
        field(55110; "TFB ABS Lot Sample Account"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Account Name for Lot Samples';
        }
        field(55120; "TFB ABS Lot Sample Access Key"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Shared Access Key for Lot Samples';
        }
        field(55130; "TFB ABS Lot Sample Container"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'ABS Container Name for Lot Samples';
        }

    }

}