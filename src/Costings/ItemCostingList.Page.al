page 50347 "TFB Item Costing List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Item Costing";
    CardPageId = "TFB Item Costing";
    Editable = true;
    Caption = 'Item Costing List';


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies unique item code';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Tooltip = 'Specifies description of item';
                }
                field("Item Category"; Rec."Item Category")
                {
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = false;
                    Tooltip = 'Specifies product category of item';
                }
                field("Sale Blocked"; Rec."Sale Blocked")
                {
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = false;
                    ToolTip = 'Specifies if sales are blocked for item';
                }
                field("Publishing Blocked"; Rec."Publishing Blocked")
                {
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = false;
                    Tooltip = 'Specifies if item is blocked from inclusion on publishd price list';
                }
                field("Costing Type"; Rec."Costing Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Tooltip = 'Specifies if costing is general or specific for customer';
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Tooltip = 'Specifies effective initial date for item costing';
                    Visible = false;
                }
                field("Purchase Price Unit"; Rec."Purchase Price Unit")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies purchase price unit basis for costing';
                }
                field("Average Cost"; Rec."Average Cost")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies current average purchase cost of item, excluded landed costs';

                    trigger OnValidate()

                    begin

                        CurrPage.Update();
                    end;
                }
                field("Market Price"; Rec."Market Price")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Caption = 'Market Cost';
                    ToolTip = 'Specifies projected market cost for item';

                    trigger OnValidate()

                    begin

                        CurrPage.Update();
                    end;
                }
                field(pricingMargin; Rec."Pricing Margin %")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Visible = true;
                    ToolTip = 'Specifies pricing margin to use for use based on current average cost';

                    trigger OnValidate();

                    begin
                        CurrPage.Update();
                    end;
                }

                field("Market Price Margin %"; Rec."Market Price Margin %")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Tooltip = 'Specifies pricing margin projected based on future market replacement cost';

                    trigger OnValidate()

                    begin

                        CurrPage.Update();
                    end;

                }
                field("Last Modified Date Time"; Rec."Last Modified Date Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies date item costing was last modified';
                }
                field("HasLines"; Rec."HasLines")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if costing lines have been calculated';

                }

                field("Exw Kg"; Rec."Exw Kg")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Ex Warehouse Kg';
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    Tooltip = 'Specifies exwarehouse costs';

                }
                field("Mel Metro Kg"; Rec."Mel Metro Kg")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    ToolTip = 'Specifies melbourne metro per kg price';
                }
                field("Syd Metro Kg"; Rec."Syd Metro Kg")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    ToolTip = 'Specifices sydney metro per kg price';
                }
                field("Adl Metro Kg"; Rec."Adl Metro Kg")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    ToolTip = 'Specifices adelaide metro per kg price';
                }

                field("Brs Metro Kg"; Rec."Brs Metro Kg")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    ToolTip = 'Specifices brisbane metro per kg price';
                }


            }
        }



        area(Factboxes)
        {
            part(ItemDet; "Item Picture")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Item No.");

            }
            part(ItemPlan; "TFB Item Costing Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Item No.");

            }

        }

    }




    actions
    {


        area(Processing)
        {
            action(UpdateCostings)
            {
                Caption = 'Update Costings';
                Image = UpdateUnitCost;
                ApplicationArea = All;

                ToolTip = 'Recalculates all item costings based on specifies scenarios and landed cost profiles';

                trigger OnAction()

                var
                    CodeUnitCosting: Codeunit "TFB Costing Mgmt";
                    UpdateExchRate: Boolean;
                    UpdateMargins: Boolean;
                    UpdatePrices: Boolean;

                begin

                    UpdateExchRate := True;
                    UpdateMargins := False;
                    UpdatePrices := False;
                    CodeUnitCosting.UpdateCurrentCostingsDetails(UpdateExchRate, UpdateMargins, UpdatePrices);

                end;
            }

        }

        area(Promoted)
        {
            group(Category_Home)
            {
                Caption = 'Home';
                actionref(UpdateCostingsRef; UpdateCostings)
                {

                }
            }
        }

    }
    views
    {

        view(ViewName)
        {
            Caption = 'Locked';
            Filters = where("Automatically Updated" = const(false));
            OrderBy = ascending(Description);
            SharedLayout = true;

        }
        view(FixedExchange)
        {
            Caption = 'Fixed Exch. Rates';
            Filters = where("Fix Exch. Rate" = const(true));
            OrderBy = ascending(Description);
            SharedLayout = true;
        }
        view("Current / Standard")
        {
            Filters = where("Costing Type" = const(Standard), Current = const(true));
            OrderBy = ascending("Item Category", Description);
        }
        view("Export")
        {
            Filters = where("Costing Type" = const(Standard), Current = const(true), "Publishing Blocked" = const(false));
            OrderBy = ascending("Item Category", Description);



        }

    }

}