pageextension 50162 "TFB Payment Journal" extends "Payment Journal"
{
    layout
    {
        // Add changes to page layout here

        addlast(factboxes)
        {
                 part(FactBox; "TFB Vend. Ledg. Appl. FactBox")
                 {
                     ApplicationArea = All;
                     SubPageLink = "Applies-to ID" = field("Document No.");
                     UpdatePropagation = Both;
                 }
        }
    }

}