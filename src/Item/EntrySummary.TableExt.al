tableextension 50133 "TFB Entry Summary" extends "Entry Summary"
{
    fields
    {
        field(50100; "TFB Lot Blocked"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50040; "TFB Date Available"; Date)
        {
            Editable = True;
            Caption = 'Est. Date Available';
            DataClassification = CustomerContent;
        }
    }


}