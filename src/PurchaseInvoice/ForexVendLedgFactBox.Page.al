page 50158 "TFB Forex Vend.Ledg. Factbox"
{
    PageType = CardPart;

    SourceTable = "Vendor Ledger Entry";
    Caption = 'Ledger entry';
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            group(General)

            {
                showCaption = false;

                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the date the ledger entry was created';
                }
                field("Document No."; Rec."Document No.")
                {

                    Tooltip = 'Specifies the document number';

                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    Tooltip = 'Specifies the vendors names';
                }
                field("Original Currency Factor"; Rec."Original Currency Factor")
                {
                    ToolTip = 'Specifies the original currency factor';
                }



            }
        }
    }

    actions
    {

    }



}