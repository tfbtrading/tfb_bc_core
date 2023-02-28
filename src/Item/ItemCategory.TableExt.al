tableextension 50138 "TFB Item Category" extends "Item Category"
{
    fields
    {
        field(50100; "TFB Catalogue Priority"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Catalogue Priority';
        }
    }

    keys
    {
        key(CataloguePriority; "TFB Catalogue Priority")
        {

        }
    }


}