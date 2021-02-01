tableextension 50320 "TFB PostCode" extends "Post Code" //225
{
    fields
    {
        field(50321; "TFB Postcode Zone"; Code[20])
        {

            DataClassification = CustomerContent;
            TableRelation = "TFB Postcode Zone";
        }

    }

}