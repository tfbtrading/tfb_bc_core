pageextension 50205 "TFB Purchase Price List" extends "Purchase Price List"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(factbox; "TFB Purch. Price List Factbox")
            {
                Provider = Lines;
                SubPageLink = SystemId = field(SystemId);
                ApplicationArea = all;
                Caption = 'Additional context';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

}