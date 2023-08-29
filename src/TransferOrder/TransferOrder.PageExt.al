pageextension 50176 "TFB Transfer Order" extends "Transfer Order" //MyTargetPageId
{
    layout
    {
        addlast(General)
        {
            field("TFB Instructions"; Rec."TFB Instructions")
            {
                MultiLine = true;
                ApplicationArea = All;
                ToolTip = 'Specifies the specific delivery instructions for the warehouse shipment';
            }
        }
        addafter("In-Transit Code")
        {

        }
        modify("Receipt Date")
        {
            Editable = true;
        }
        modify("Shortcut Dimension 1 Code")
        {
            Visible = false;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Visible = false;
        }

        addbefore(Status)
        {
            field("TFB Transfer Type"; Rec."TFB Transfer Type")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies type of transfer. Standard or specific for a container';
            }

            group(ContainerDetails)
            {
                ShowCaption = false;
                Visible = Rec."TFB Transfer Type" = Rec."TFB Transfer Type"::Container;
                field("TFB Container Entry No."; Rec."TFB Container Entry No.")
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies container entry number to be applied to lines';
                }
                field("TFB Order Reference"; Rec."TFB Order Reference")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies container details';
                }
            }
        }


    }

    actions
    {

        addlast(Navigation)
        {
            action(Container)
            {
                RunObject = Page "TFB Container Entry";
                RunPageLink = "No." = field("TFB Container Entry No.");
                RunPageMode = Edit;
                Image = TransferOrder;
                ApplicationArea = All;
                Enabled = Rec."TFB Container Entry No." <> '';
                ToolTip = 'Opens related container record';
            }
        }



    }
}