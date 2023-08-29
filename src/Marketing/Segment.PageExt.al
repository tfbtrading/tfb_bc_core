pageextension 50223 "TFB Segment" extends Segment
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Category_Process)
        {
            actionref(TFBModifyPromoted; "Modify Word Template")
            {
                Visible = true;
            }
        }
    }

    var
        myInt: Integer;
}