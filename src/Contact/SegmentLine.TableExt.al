tableextension 50117 "TFB Segment Line" extends "Segment Line"
{
    fields
    {
           field(50100; "TFB Further Details"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Further details';
        }
    }
    
   
}