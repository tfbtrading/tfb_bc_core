/// <summary>
/// Page TFB Item Costing (ID 50348).
/// </summary>
page 50348 "TFB Item Costing"
{
    PageType = Card;
    SourceTable = "TFB Item Costing";
    DelayedInsert = true;
    Caption = 'Item Costing';

    layout
    {
        area(Content)
        {
            group("General")
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies item number being costed';
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies description of item being costed';
                }
                field("Item Category"; Rec."Item Category")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies item category of item being costed';
                }
                field("Costing Type"; Rec."Costing Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies type of costing - is it for specific customer or general';
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies initial effective date on which costing is created';
                }
                field(Current; Rec.Current)
                {
                    ApplicationArea = All;
                    Editable = true;
                    Tooltip = 'Specifies whether item costing is current and effective';

                }
                field(HasLines; Rec.HasLines)
                {
                    Caption = 'Valid - Lines Generated';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if lines have been calculated';

                }

                field("Landed Cost Profile"; Rec."Landed Cost Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies landed cost profile used to generate item costing';


                }
                field("Landed Cost Scenario"; "LandedCostScenarioCode")
                {
                    ApplicationArea = All;
                    Caption = 'Landed cost scenario';

                    Visible = false;
                    ToolTip = 'Specifies landed cost scenario if overriden';

                }
                field("Scenario Override"; Rec."Scenario Override")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies if scenario used in landed cost profile is overriden on item costing';
                }
                field("Vendor No.";
                Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies vendor for used for calculating item costing';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies name of vendor';
                }
                field("Fix Exch. Rate"; Rec."Fix Exch. Rate")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Ensures that the exchange rate is not updated when the related scenario exchange rate changes or during automated processes';
                }
            }

            group("Costing Detail")
            {
                group("Pricing")
                {
                    Caption = 'Pricing and Margin';
                    field("Purchase Price Unit"; Rec."Purchase Price Unit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies purchase price unit in which prices are expressed';
                    }
                    field("Est. Current Cost"; Rec."Average Cost")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies current average cost for item being costed';
                    }

                    field("Market Cost"; Rec."Market Price")
                    {
                        ApplicationArea = All;
                        Tooltip = 'Specifies latest replacement or market cost for item';
                    }

                    field("Pricing Margin %"; Rec."Pricing Margin %")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies pricing margin based on current average cost';
                    }
                    field("Market Cost Margin %"; Rec."Market Price Margin %")
                    {
                        ApplicationArea = All;
                        Tooltip = 'Specifies pricing market for projected market cost. Based on prevailing market margins projected.';

                    }
                    field("Full Load Margin %"; Rec."Full Load Margin %")
                    {
                        ApplicationArea = All;
                        Tooltip = 'Specifies discount on full pallet load';
                    }

                }
                group("Drivers")
                {
                    field("Pallet Qty"; Rec."Pallet Qty")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies pallet qty for item costing';


                    }

                    field("Vendor Currency"; Rec."Vendor Currency")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies currency used for goods purchased';


                    }
                    group(ForeignCurrency)
                    {
                        ShowCaption = false;
                        Visible = Rec."Vendor Currency" <> '';

                        field("Exch. Rate"; Rec."Exch. Rate")
                        {
                            ApplicationArea = All;
                            enabled = Rec."Vendor Currency" <> '';
                            ToolTip = 'Specifies exch. rate. used to calculate when foreign currency is used';
                        }
                    }
                    field("Days Financed"; Rec."Days Financed")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies number of days financed';
                    }
                    field("Dropship"; Rec."Dropship")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies if load is drop shipped directly to customer';
                    }
                    group(dropShipItems)
                    {
                        ShowCaption = false;
                        Visible = not Rec.Dropship;
                        field("Est. Item Storage"; Rec."Est. Storage Duration")
                        {
                            ApplicationArea = All;
                            BlankZero = false;
                            ToolTip = 'Specifies item duration for storage in days';
                        }
                    }



                }

            }

            part("Lines"; "TFB Item Costing Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Item No." = field("Item No."), "Costing Type" = field("Costing Type"), "Effective Date" = field("Effective Date");
                UpdatePropagation = SubPart;
                Visible = true;
                Caption = 'Lines';

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
        area(Navigation)
        {
            action("Cost Scenario")
            {
                ApplicationArea = all;
                image = Cost;
                RunObject = Page "TFB Landed Cost Profile";
                RunPageLink = Code = field("Landed Cost Profile");
                RunPageMode = View;
                ToolTip = 'Open landed cost profile';



            }
            action("Item ")
            {
                ApplicationArea = all;
                image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = field("Item No.");
                RunPageMode = View;
                Tooltip = 'Open item';

            }
            action("Vendor")
            {
                ApplicationArea = All;
                image = Vendor;
                RunObject = Page "Vendor Card";
                RunPageLink = "No." = field("Vendor No.");
                RunPageMode = View;
                Tooltip = 'Open vendor';

            }


        }

        area(Processing)
        {
            action("CopyToWorksheet")
            {
                ApplicationArea = All;
                Image = Copy;
                ToolTip = 'Copies the current item costing to the sales price worksheet';
                Caption = 'Copy to Sales Price Worksheet';

                trigger OnAction()

                var
                    CostingCU: CodeUnit "TFB Costing Mgmt";
                    SalesPriceWS: Page "Sales Price Worksheet";
                begin
                    If CostingCU.CopyCurrentCostingToSalesWorkSheet(Rec."Item No.") then
                        If Confirm('Sales Price Worksheet modified - do you want to open it', true) then
                            SalesPriceWS.Run();

                end;
            }
            action("Refresh")
            {
                ApplicationArea = All;
                image = RefreshLines;
                ToolTip = 'Refresh all costing lines';

                trigger OnAction()
                begin
                    rec.CalcCostings(Rec);
                    CurrPage.Lines.Page.Update();

                end;
            }
        }
    }
    var
        LandedCostScenarioCode: code[20];
        isDropShipVisible: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        recScenario: record "TFB Costing Scenario";
        recProfile: record "TFB Landed Cost Profile";
    begin
        if recProfile.get(Rec."Landed Cost Profile") then
            if recScenario.get(recProfile.Scenario) then
                LandedCostScenarioCode := recScenario.Code;

        if Rec.Dropship then isDropShipVisible := false else isDropShipVisible := true;
        ;
    end;
}