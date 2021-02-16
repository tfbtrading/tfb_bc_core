pageextension 50450 "TFB O365 Activities" extends "O365 Activities" //MyTargetPageId
{
    layout
    {
        addbefore("Ongoing Sales")
        {
            cuegroup("Business Development")
            {
                Caption = 'Ongoing Business Development';
                field("TFB Open Opportunities"; Rec."TFB Open Opportunities")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Opportunities';
                    DrillDownPageID = Opportunities;
                    ToolTip = 'Specifies opportunities that are still open.';
                }
                field("TFB Tasks"; Rec."TFB Tasks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tasks';
                    DrillDownPageID = "Task List";
                    ToolTip = 'Specifies tasks that are still open.';
                }
                field("TFB My Tasks"; Rec."TFB My Tasks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'My Tasks';
                    DrillDownPageID = "Task List";
                    ToolTip = 'Specifies tasks that are still open.';
                }
                field("TFB New Contacts"; Rec."TFB New Contacts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New contacts';
                    DrillDownPageID = "Contact List";
                    ToolTip = 'Specifies recently added contacts.';
                }
            }
        }
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

    trigger OnOpenPage()

    var
        SalesPerson: Record "Salesperson/Purchaser";
        UserSetup: Record "User Setup";
        User: record User;
        UserName: code[50];
        USID: Guid;

    begin
        USID := Database.UserSecurityId();

        User.SetRange("User Security ID", USID);

        If User.FindFirst() then begin
            UserName := User."User Name";
            If UserSetup.Get(UserName) then
                Rec."TFB Salesperson Code Filter" := UserSetup."Salespers./Purch. Code";

        end;
    end;

}