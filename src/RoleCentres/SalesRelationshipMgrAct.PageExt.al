pageextension 50186 "TFB Sales Rel. Mgr. Act." extends "Sales & Relationship Mgr. Act."
{
    layout
    {
        // Add changes to page layout here
        modify("Open Sales Orders")
        {
            Visible = false;
        }

        addfirst(Contacts)
        {
            field("TFB My Leads"; Rec."TFB My Leads")
            {
                ToolTip = 'Specifies the number of leads open';
                DrillDownPageId = "Contact List";
                ApplicationArea = RelationshipMgmt;
            }
            field("TFB My Prospects"; Rec."TFB My Prospects")
            {
                ToolTip = 'Specifies the number of prospects open';
                DrillDownPageId = "Contact List";
                ApplicationArea = RelationshipMgmt;
            }
        }

        addafter(Contacts)
        {
            cuegroup(Interactions)
            {
                Caption = 'Interactions & Tasks';
                field("TFB Recent Interactions"; Rec."TFB Recent Interactions")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Last 7 Days Interactions';
                    DrillDownPageID = "Interaction Log Entries";

                    ToolTip = 'Specifies recent interactions opportunities.';


                }
                field("TFB Open Tasks"; Rec."TFB Open Tasks")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "Task List";
                    Style = Favorable;
                    StyleExpr = TRUE;
                    Caption = 'Open Tasks';
                    ToolTip = 'Specifies tasks that are open.';
                }

            }
        }
        modify("Data Integration")
        {
            Visible = false;
        }
        modify("Closed Opportunities")
        {
            Visible = false;
        }
    }

    actions
    {
        // Add changes to page actions here
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
                Rec."TFB SalesPerson Filter" := UserSetup."Salespers./Purch. Code";

        end;
    end;


}