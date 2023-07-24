page 50347 "TFB Item Costing List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Item Costing Revised";
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
                    Editable = false;
                    ToolTip = 'Specifies unique item code';
                }
                field("Description"; Rec."Description")
                {
                    Editable = false;
                    Tooltip = 'Specifies description of item';
                }
                field("Item Category"; Rec."Item Category")
                {
                    Editable = false;
                    DrillDown = false;
                    Tooltip = 'Specifies product category of item';
                }
                field("Sale Blocked"; Rec."Sale Blocked")
                {
                    Editable = false;
                    DrillDown = false;
                    ToolTip = 'Specifies if sales are blocked for item';
                }
                field("Publishing Blocked"; Rec."Publishing Blocked")
                {
                    Editable = false;
                    DrillDown = false;
                    Tooltip = 'Specifies if item is blocked from inclusion on publishd price list';
                }
                field("Costing Type"; Rec."Costing Type")
                {
                    Editable = false;
                    Tooltip = 'Specifies if costing is general or specific for customer';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the Customer No.';
                }
                field("Purchase Price Unit"; Rec."Purchase Price Unit")
                {
                    Editable = false;
                    ToolTip = 'Specifies purchase price unit basis for costing';
                }
                field("Average Cost"; Rec."Average Cost")
                {
                    Editable = true;
                    ToolTip = 'Specifies current average purchase cost of item, excluded landed costs';

                    trigger OnValidate()

                    begin

                        CurrPage.Update();
                    end;
                }
                field("Market Price"; Rec."Market Price")
                {
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
                    Editable = true;
                    Tooltip = 'Specifies pricing margin projected based on future market replacement cost';

                    trigger OnValidate()

                    begin

                        CurrPage.Update();
                    end;

                }
                field("Last Modified Date Time"; Rec.SystemModifiedAt)
                {
                    Editable = false;
                    ToolTip = 'Specifies date item costing was last modified';
                }
                field("HasLines"; Rec."HasLines")
                {
                    Editable = false;
                    ToolTip = 'Specifies if costing lines have been calculated';

                }

                field("Exw Kg"; Rec."Exw Kg")
                {
                    BlankZero = true;
                    Caption = 'Ex Warehouse Kg';
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    Tooltip = 'Specifies exwarehouse costs';

                }
                field("Mel Metro Kg"; Rec."Mel Metro Kg")
                {
                    BlankZero = true;
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    ToolTip = 'Specifies melbourne metro per kg price';
                }
                field("Syd Metro Kg"; Rec."Syd Metro Kg")
                {
                    BlankZero = true;
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    ToolTip = 'Specifices sydney metro per kg price';
                }
                field("Adl Metro Kg"; Rec."Adl Metro Kg")
                {
                    BlankZero = true;
                    Editable = false;
                    DrillDownPageId = "TFB Item Costing Subform";
                    DrillDown = true;
                    ToolTip = 'Specifices adelaide metro per kg price';
                }

                field("Brs Metro Kg"; Rec."Brs Metro Kg")
                {
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
                SubPageLink = "No." = field("Item No.");

            }
            part(ItemPlan; "TFB Item Costing Factbox")
            {
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

                ToolTip = 'Recalculates all item costings based on specifies scenarios and landed cost profiles';

                trigger OnAction()

                var
                    CodeUnitCosting: Codeunit "TFB Costing Mgmt";
                    UpdateExchRate: Boolean;
                    UpdateMargins: Boolean;
                    UpdatePrices: Boolean;

                begin

                    UpdateExchRate := true;
                    UpdateMargins := false;
                    UpdatePrices := false;
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
            Filters = where("Costing Type" = const(Standard));
            OrderBy = ascending("Item Category", Description);
        }
        view("Export")
        {
            Filters = where("Costing Type" = const(Standard), "Publishing Blocked" = const(false));
            OrderBy = ascending("Item Category", Description);



        }

    }

}