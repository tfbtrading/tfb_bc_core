page 50110 "TFB Sales Admin Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "TFB Sales Admin Activities Cue";
    ShowFilter = false;
    ApplicationArea = All;


    layout
    {
        area(content)
        {

            cuegroup(Welcome)
            {
                Caption = 'Welcome';
                Visible = TileGettingStartedVisible;

                actions
                {
                    action(GettingStartedTile)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Return to Getting Started';
                        Image = TileVideo;
                        ToolTip = 'Learn how to get started with Dynamics 365.';

                        trigger OnAction()
                        begin
                            O365GettingStartedMgt.LaunchWizard(true, false);
                        end;
                    }
                }
            }
            cuegroup("Ongoing Sales")
            {
                Caption = 'Ongoing Sales';
                field("Ongoing Sales Quotes"; Rec.Quotes)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open Quotes';
                    DrillDownPageID = "Sales Quotes";
                    ToolTip = 'Specifies sales quotes that have not yet been converted to invoices or orders.';
                }
                field("Sales Line - Created Today"; Rec."Sales Line - Created Today")
                {
                    ApplicationArea = Suite;
                    Caption = 'Created Today';
                    DrillDownPageID = "TFB Pending Sales Lines";
                    ToolTip = 'Sales lines created today';
                }
                field("Sales Lines - Overdue"; Rec."Sales Lines - Overdue")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Past Due';
                    DrillDownPageID = "TFB Pending Sales Lines";
                    ToolTip = 'All sales lines that should have already shipped';
                }
                field("Sales Lines - This Week"; Rec."Sales Lines - This Week")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'This Week';
                    DrillDownPageID = "TFB Pending Sales Lines";
                    ToolTip = 'All sales lines due to be shipped this week';
                }
                field("Sales Lines - Next Week"; Rec."Sales Lines - Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Next Week';
                    DrillDownPageID = "TFB Pending Sales Lines";
                    ToolTip = 'All sales lines due to be shipped next week';
                }
                field("Sales Lines - All"; Rec."Sales Lines - All")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'All';
                    DrillDownPageID = "TFB Pending Sales Lines";
                    ToolTip = 'All sales lines that are not yet shipped';
                }
            }

            cuegroup("Logistics")
            {
                Caption = 'Ongoing Logistics';
                field("Warehouse Shipments"; Rec."Warehouse Shipments")
                {
                    ApplicationArea = Suite;
                    Caption = 'Warehouse Shipments';
                    DrillDownPageID = "Warehouse Shipment List";
                    ToolTip = 'Open warehouse shipments to be processed';
                }
                field("Containers In Progress"; Rec."Containers In Progress")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "TFB Container Entry List";
                    Caption = 'Inbound Shipments - Active';
                    ToolTip = 'Containers that have been shipped, but not closed';
                }

            }

            cuegroup("Ongoing Purchases")
            {
                Caption = 'Ongoing Purchases';

                field("Purchase Lines - Created Today"; Rec."Purchase Lines - Created Today")
                {
                    ApplicationArea = Suite;
                    Caption = 'Created Today';
                    DrillDownPageID = "TFB Pending Purch. Order Lines";
                    ToolTip = 'Purchase lines created today';
                }
                field("Purchase Lines - Past Due"; Rec."Purchase Lines - Past Due")
                {
                    ApplicationArea = Suite;
                    Caption = 'Past Due';
                    DrillDownPageID = "TFB Pending Purch. Order Lines";
                    ToolTip = 'Pending purchase lines whose planned shipment date has past.';
                }
                field("Purchase Lines - This Week"; Rec."Purchase Lines - This Week")
                {
                    ApplicationArea = Suite;
                    Caption = 'Due This Week';
                    DrillDownPageID = "TFB Pending Purch. Order Lines";
                    ToolTip = 'Pending purchase lines due to be received this week.';
                }
                field("Purchase Lines - Next Week"; Rec."Purchase Lines - Next Week")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Due Next Week';
                    DrillDownPageID = "TFB Pending Purch. Order Lines";
                    ToolTip = 'Pending purchase lines due to be received next week.';
                }
                field("Purchase Lines - All"; Rec."Purchase Lines - All")
                {
                    ApplicationArea = Suite;
                    Caption = 'All';
                    DrillDownPageID = "TFB Pending Purch. Order Lines";
                    ToolTip = 'All purchase lines not yet received';
                }
            }

            cuegroup("Quality")
            {
                Caption = 'Quality';
                field("Vendor Certificates Expired"; Rec."Vendor Certificates Expired")
                {
                    ApplicationArea = Suite;
                    Caption = 'Expired Certificates';
                    DrillDownPageID = "TFB Vendor Certification List";
                    ToolTip = 'Pending purchase lines due to be received this week.';
                }
                field("Lot's without CoA"; Rec."Lot's without CoA")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Lots with Issues';
                    DrillDownPageID = "Lot No. Information List";
                    ToolTip = 'Pending purchase lines due to be received next week.';
                }


            }


            cuegroup("TasksAndInteractions")
            {
                Caption = 'My Tasks and Interactions';
                field("TFB My Tasks"; Rec."TFB My Tasks")
                {
                    ApplicationArea = RelationshipMgmt;
                    DrillDownPageID = "TFB Active Task List";
                    Style = Favorable;
                    StyleExpr = true;
                    Caption = 'Relationship Tasks';
                    ToolTip = 'Specifies tasks that are open.';
                }
                field("TFB My Interactions"; Rec."TFB My Interactions")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Interactions';
                    DrillDownPageID = "Interaction Log Entries";

                    ToolTip = 'Specifies recent interactions opportunities.';


                }
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Recurring Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks();
                        UserTaskList.Run();
                    end;
                }

                field("TFB No. Open Sample Requests";Rec."TFB No. Open Sample Requests")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Sample Requests';
                    ToolTip = 'Specifies the number of open sample requests';
                    DrillDown  = true;
                    DrillDownPageId = "TFB Sample Request List";
                }
            }



        }
    }
    actions
    {
        area(processing)
        {
            action(RefreshData)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Data';
                Image = Refresh;
                ToolTip = 'Refreshes the data needed to make complex calculations.';

                trigger OnAction()
                begin
             
                    CODEUNIT.Run(CODEUNIT::"Activities Mgt.");
                    CurrPage.Update(false);
                end;
            }
            action("Set Up Cues")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number());
                end;
            }
        }
    }



    trigger OnAfterGetRecord()
    begin
        SetActivityGroupVisibility();
    end;

    trigger OnInit()
    begin

    end;

    trigger OnOpenPage()
    var

        UserSetup: Record "User Setup";
        User: record User;
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        UserName: code[50];
        USID: Guid;
        ExpressionTxt: Label '<-14D>';

    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
            Commit();

        end;

        Rec.SetFilter("User ID Filter", UserId());
        Rec.SetFilter("Due This Week Filter", 'm..f');
        Rec.SetFilter("Due Next Week Filter", '-cw+1w..+cw+1w');
        Rec.SetFilter("Overdue Filter", '..w');
        Rec.SetFilter("Workday Filter", 'w');

        USID := Database.UserSecurityId();



        User.SetRange("User Security ID", USID);

        if User.FindFirst() then begin
            UserName := User."User Name";
            if UserSetup.Get(UserName) then
                Rec.SetRange("TFB SalesPerson Filter", UserSetup."Salespers./Purch. Code");


        end;

        Rec.SetRange("Recent DateTime Filter", CreateDateTime(CalcDate(ExpressionTxt), 0T), CurrentDateTime);


        RoleCenterNotificationMgt.ShowNotifications();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();

    end;

    var

        CuesAndKpis: Codeunit "Cues And KPIs";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        UserTaskManagement: Codeunit "User Task Management";


        TileGettingStartedVisible: Boolean;

    //IsAddInReady: Boolean;






    local procedure SetActivityGroupVisibility()
    var

    begin

    end;










}