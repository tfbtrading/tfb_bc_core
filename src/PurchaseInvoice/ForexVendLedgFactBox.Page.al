page 50158 "TFB Forex Vend.Ledg. Factbox"
{
    PageType = CardPart;

    SourceTable = "Vendor Ledger Entry";
    Caption = 'Ledger entry';

    layout
    {
        area(Content)
        {
            group(General)

            {
                showCaption = false;

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;

                    ToolTip = 'Specifies the date the ledger entry was created';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;

                    Tooltip = 'Specifies the document number';

                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the vendors names';
                }
                field("Original Currency Factor"; Rec."Original Currency Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original currency factor';
                }



            }
        }
    }

    actions
    {

    }



}