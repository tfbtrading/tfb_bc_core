pageextension 50215 "TFB Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("TFB MSDS Word Template"; Rec."TFB MSDS Word Template")
            {
                Importance = Promoted;
                ApplicationArea = All;
                ToolTip = 'Specifies the word template to use when generating an MSDS material sheet for an item';
            }
        }
        addlast(content)
        {
            group("LotSampleImages")
            {
                Caption = 'Lot Sample Images';
                group("Azure Blob Storage (ABS)")
                {
                    InstructionalText = 'These fields are all required to be completed to activate mirroring of lot sample images to designated blob storage account';
                    field("TFB ABS Lot Sample Account"; Rec."TFB ABS Lot Sample Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ABS Account Name.';
                    }
                    field("TFB ABS Lot Sample Access Key"; Rec."TFB ABS Lot Sample Access Key")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ABS Shared Access Key.';
                    }
                    field("TFB ABS Lot Sample Container"; Rec."TFB ABS Lot Sample Container")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ABS Container Name.';
                    }
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}