page 50341 "TFB Landed Cost Profile"
{
    PageType = Card;
    Caption = 'Landed Cost Profile';
    PromotedActionCategories = 'Navigate,Process';

    SourceTable = "TFB Landed Cost Profile";

    layout
    {
        area(Content)
        {
            group("General")
            {

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies unique code for record';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies description for landed cost profile';

                }
                field("Scenario"; Rec."Scenario")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies default scenario for landed cost profile';

                }
                field("Purchase Type"; Rec."Purchase Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies type of purchase';
                }
                field("Est. Net Weight"; Rec."Est. Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies total weight for container used in landed cost profile';
                }
                grid(Standard)
                {
                    GridLayout = Columns;

                    group("Options")
                    {
                        field("Pallets"; Rec."Pallets")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies number of pallets after goods resulting from container. Can be palletised in container or palletised upon unpack';
                        }
                        field("Demurrage Days"; Rec."Demurrage Days")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies number of days demurrage negotiated with vendor';
                        }
                        field("Palletised"; Rec."Palletised")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies whether container is palletised or not';
                        }
                        field("Fumigated"; Rec."Fumigated")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies if container requires fumigation';
                        }
                        field(Inspected; Rec.Inspected)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies whether container requires inspection';
                        }
                        field("Heat Treated"; Rec."Heat Treated")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies whether container requires heat treatment';
                        }

                        field("Financed"; Rec."Financed")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies if container requires specific financing using import financing that can be broken out';
                        }
                        field("Apply Contingency"; Rec."Apply Contingency")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies whether container has a likelihood of requiring contingency allocation';
                        }
                    }
                    group("Costs")
                    {
                        field("Port Documents"; Rec."Port Documents")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies port documentation fees for container';
                        }
                        field("Quarantine Fees"; Rec."Quarantine Fees")
                        {
                            ApplicationArea = All;
                            Tooltip = 'Specifies quarantine and government fees, including testing for container';

                        }
                        Group(Freight)
                        {
                            Caption = 'Freight';
                            InstructionalText = 'Ocean freight can be expressed in local currency, or the currency is specified for the scenario';
                            field("Freight Currency"; Rec."Freight Currency")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specify the currency in which the ocean freight is budgeted';
                            }
                            field("Ocean Freight"; Rec."Ocean Freight")
                            {
                                ApplicationArea = All;
                                Tooltip = 'Specifies ocean freight rate for goods where quote does not include freight';
                            }

                            group(LocalCurr)
                            {
                                ShowCaption = false;
                                field("Freight (LCY)"; Rec."Freight (LCY)")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies freight cost in local currency';
                                    Editable = false;
                                    BlankZero = true;
                                }
                            }
                        }
                    }
                }
            }

            group("Totals")
            {
                field("Container Cost"; Rec."Container Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated total of landed costs calculated for container';
                }
                field("Pallet Cost"; Rec."Pallet Cost")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the calculated total of landed costs per pallet';
                }
                field("Per Weight Cost"; Rec."Per Weight Cost")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the calculated total of landed costs per weight unit';
                }

            }
        }
    }

    actions
    {

        area(Navigation)
        {


            action("Cost Scenario")
            {
                ApplicationArea = all;
                image = CostBudget;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "TFB Costing Scenario";
                RunPageLink = Code = field(Scenario);
                RunPageMode = View;
                Caption = 'Cost scenario';
                ToolTip = 'Opens the default scenario for the landed cost profile';

            }


        }

        area(Processing)
        {
            action("Refresh")
            {
                ApplicationArea = All;
                Image = Refresh;

                PromotedOnly = true;
                PromotedCategory = Process;
                Promoted = True;
                ToolTip = 'Refresh the calculated costs based on change in scenario';

                trigger OnAction()
                var
                    CostingScenarioRec: record "TFB Costing Scenario";
                begin
                    if CostingScenarioRec.get(Rec.Scenario) then
                        rec.Validate("Pallet Cost");

                end;
            }
        }
    }
}