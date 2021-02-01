pageextension 50486 "TFB SO Processor Activities" extends "SO Processor Activities" //9060
{
    layout
    {
        addafter("Sales Orders - Open")
        {


            field("TFB Ongoing Sales Lines"; Rec."TFB Ongoing Sales Lines")
            {

                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Pending Sales Lines";
                Caption = 'Ongoing Sales order Lines';
                ToolTip = 'Specifies number of ongoing sales lines';
            }
            field("TFB Ongoing Whse. Shipments"; Rec."TFB Ongoing Whse. Shipments")
            {
                ApplicationArea = All;
                DrillDown = True;
                DrillDownPageId = "Warehouse Shipment List";
                Caption = 'Open Whse. Shipments';
                Tooltip = 'Specifies number of ongoing whse. shipments';
            }
            field("TFB Purchase Orders"; Rec."TFB Purchase Orders")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "Purchase Order List";
                Tooltip ='Specifies number of ongoing purchase orders';
            }
            field("TFB Containers In Progress"; Rec."TFB Containers In Progress")
            {
                ApplicationArea = All;
                DrillDown = true;
                DrillDownPageId = "TFB Container Entry List";
                Tooltip ='Specifies number of containers in progress';
            }


        }




    }

    actions
    {
    }
}