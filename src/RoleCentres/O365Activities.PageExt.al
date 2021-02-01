pageextension 50450 "TFB O365 Activities" extends "O365 Activities" //MyTargetPageId
{
    layout
    {
        addafter("Ongoing Sales Orders")
        {
            field("TFB Ongoing Sales Lines"; Rec."TFB Ongoing Sales Lines")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Pending Sales Lines";
                ToolTip = 'Specifies number of ongoing sales lines';
            }
            field("TFB Ongoing Whse. Shipments"; Rec."TFB Ongoing Whse. Shipments")
            {
                ApplicationArea = All;
                DrillDown = True;
                DrillDownPageId = "Warehouse Shipment List";
                tooltip = 'Specifies number of ongoing warehouse shipments';
            }


        }

        addafter("Purchase Orders")
        {
            field("TFBContainers In Progress"; Rec."TFB Containers In Progress")
            {
                ApplicationArea = All;
                DrillDown = True;
                DrillDownPageId = "TFB Container Entry List";
                ToolTip = 'Specifies number of containers in progress';
            }
        }

        modify("Outstanding Vendor Invoices")
        {
            Visible = false;

        }



    }

    actions
    {
    }
}