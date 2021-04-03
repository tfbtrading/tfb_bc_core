page 50101 "TFB Ops Mgr Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "TFB Ops Mgr Activities Cue";
    ShowFilter = false;

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
            cuegroup(Control54)
            {
                CueGroupLayout = Wide;
                ShowCaption = false;
                field("Sales This Month"; Rec."Sales This Month")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Sales Invoice List";
                    ToolTip = 'Specifies the sum of sales in the current month excluding taxes.';

                    trigger OnDrillDown()
                    begin
                        ActivitiesMgt.DrillDownSalesThisMonth();
                    end;
                }
                field("Overdue Sales Invoice Amount"; Rec."Overdue Sales Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of overdue payments from customers.';

                    trigger OnDrillDown()
                    begin
                        ActivitiesMgt.DrillDownCalcOverdueSalesInvoiceAmount();
                    end;
                }
                field("Overdue Purch. Invoice Amount"; Rec."Overdue Purch. Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of your overdue payments to vendors.';

                    trigger OnDrillDown()
                    begin
                        ActivitiesMgt.DrillDownOverduePurchaseInvoiceAmount();
                    end;
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
            cuegroup("VendorInvoices")
            {
                Caption = 'Vendor Invoices';
                field("Incoming Documents"; Rec."Incoming Documents")
                {
                    ApplicationArea = Suite;
                    Caption = 'Incoming Documents';
                    DrillDownPageId = "Incoming Documents";
                    DrillDown = true;
                    ToolTip = 'Incoming documents not posted';
                }
                field("Purch. Invoice - This Week"; Rec."Purch. Invoice - This Week")
                {
                    ApplicationArea = Suite;
                    Caption = 'Purch. Invoice This Week';
                    DrillDownPageId = "Vendor Ledger Entries";
                    DrillDown = true;
                    ToolTip = 'Vendor ledger entries due this week';
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


            cuegroup("My User Tasks")
            {
                Caption = 'My User Tasks';
                field("UserTaskManagement.GetMyPendingUserTasksCount"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending User Tasks';
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
                    Rec."Last Date/Time Modified" := 0DT;
                    Rec.Modify();

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

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin

        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial();
    end;

    trigger OnAfterGetRecord()
    begin
        SetActivityGroupVisibility();
    end;

    trigger OnInit()
    begin

    end;

    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        NewRecord: Boolean;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
            Commit();
            NewRecord := true;
        end;

        Rec.SetFilter("User ID Filter", UserId());
        Rec.SetFilter("Due This Week Filter", 'm..f');
        Rec.SetFilter("Due Next Week Filter", '-cw+1w..+cw+1w');
        Rec.SetFilter("Overdue Filter", '..w');
        Rec.SetFilter("Workday Filter", 'w');

      
        RoleCenterNotificationMgt.ShowNotifications();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
   
    end;

    var
        ActivitiesMgt: Codeunit "Activities Mgt.";

        CuesAndKpis: Codeunit "Cues And KPIs";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        ClientTypeManagement: Codeunit "Client Type Management";

        UserTaskManagement: Codeunit "User Task Management";

      
        TileGettingStartedVisible: Boolean;

        //IsAddInReady: Boolean;

    


    

    

    local procedure SetActivityGroupVisibility()
    var

    begin

    end;










}