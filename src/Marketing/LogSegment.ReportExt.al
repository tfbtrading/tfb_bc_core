reportextension 50100 "TFB Log Segment" extends "Log Segment"
{
    dataset
    {
        // Add changes to dataitems and columns here
    }

    requestpage
    {
        layout
        {
            modify(Deliver)
            {
                Caption = 'Deliver mail merge using template';
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'mylayout.rdl';
        }
    }
}