pageextension 50203 "TFB Sales & Rel. Mgr RC" extends "Sales & Relationship Mgr. RC"
{
    layout
    {
        addlast(rolecenter)
        {
            part(LastRecords; "DYCE LastRecordsPart")
            {
                ApplicationArea = All;
                Visible = true;
            }

            part(FavouriteRecods; "DYCE FavoriteRecordsPart")
            {
                ApplicationArea = All;
                Visible = true;

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}